/**
 *        ███████████             ███
 *       ░░███░░░░░███           ░░░
 *        ░███    ░███  ██████   ████  ████████   ██████
 *        ░██████████  ░░░░░███ ░░███ ░░███░░███ ░░░░░███
 *        ░███░░░░░░    ███████  ░███  ░███ ░███  ███████
 *        ░███         ███░░███  ░███  ░███ ░███ ███░░███
 *        █████       ░░████████ █████ ░███████ ░░████████
 *       ░░░░░         ░░░░░░░░ ░░░░░  ░███░░░   ░░░░░░░░
 *                                     ░███
 *                                     █████
 *                                    ░░░░░
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IBundleRunner} from "./interfaces/IBundleRunner.sol";
import {IBundler} from "./interfaces/IBundler.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IFeeTokenRegistry} from './interfaces/IFeeTokenRegistry.sol';
import "forge-std/console.sol";

contract BundleRunner is IBundleRunner, Ownable {
    using SafeERC20 for IERC20;

    IFeeTokenRegistry internal feeTokenRegistry;
    address internal treasury;
    uint8 internal bundleLimitPerBlock;

    error DisallowedFeeToken(address feeToken);
    error InsufficientFeeToke();
    error FeeTokenPriceCannotBeZero();
    error BundleTooBig();
    error FeeTooHigh(uint256 feeAmount, uint256 maxFeePerRun);

    constructor(
        address _owner,
        IFeeTokenRegistry _feeTokenRegistry,
        uint8 _bundleLimitPerBlock,
        address _treasury
    ) Ownable(_owner) {
        feeTokenRegistry = _feeTokenRegistry;
        bundleLimitPerBlock =  _bundleLimitPerBlock;
        treasury = _treasury;
    }

    function runBundles(BundleExecutionParams[] calldata _bundleExecutionParams) external onlyOwner {
        if (_bundleExecutionParams.length > bundleLimitPerBlock)
            revert BundleTooBig();

        for (uint8 i = 0; i < _bundleExecutionParams.length; i++) {
            IBundler bundler = IBundler(_bundleExecutionParams[i].bundle);
            IERC20 feeToken = bundler.getFeeToken();

            uint256 maxFeePerRun = bundler.getMaxFeePerRun();
            (uint256 protocolFee, uint256 transactionFee) = getExecutionFees(
                _bundleExecutionParams[i].transactionCost,
                address(feeToken)
            );
            uint256 totalFee = protocolFee + transactionFee;

            if (totalFee > maxFeePerRun)
                revert FeeTooHigh(totalFee, maxFeePerRun);

            feeToken = bundler.getFeeToken();

            bundler.getFeeToken().safeTransferFrom(
                address(bundler),
                treasury,
                protocolFee
            );
            bundler.getFeeToken().safeTransferFrom(
                address(bundler),
                address(this),
                transactionFee
            );
            bundler.runBundle();
        }
    }

    function getExecutionFees(
        uint256 _transactionCost, 
        address _feeToken
    ) internal view returns (uint256 protocolFee, uint256 transactionFee) {
        AggregatorV3Interface priceFeed = feeTokenRegistry.getPriceFeedForToken(_feeToken);
        (, int256 price, , , ) = priceFeed.latestRoundData();

        if (price <= 0)
            revert FeeTokenPriceCannotBeZero();

        // @dev priceFeed returns the price in 8 decimals, price is multiplied 
        // by 1e10 in order to convert to 18 decimals
        transactionFee = _transactionCost * uint256(price * 1e10) / 1e18;
        protocolFee = transactionFee + transactionFee * 1_000 / 10_000;
    }

    function getBundleLimitPerBlock() external view returns (uint8) {
        return bundleLimitPerBlock;
    }

    function getTreasury() external view returns (address) {
        return treasury;
    }
}
