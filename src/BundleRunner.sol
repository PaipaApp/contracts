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
import {IBundleRunner} from "./interfaces/IBundleRunner.sol";
import {IBundler} from "./interfaces/IBundler.sol";
import {IFeeTokenRegistry} from "./interfaces/IFeeTokenRegistry.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/console.sol";

contract BundleRunner is IBundleRunner, Ownable {
    using SafeERC20 for IERC20;

    IFeeTokenRegistry internal feeTokenRegistry;

    error DisallowedFeeToken(address feeToken);
    error InsufficientFeeToke();

    constructor(address _owner, IFeeTokenRegistry _feeTokenRegistry) Ownable(_owner) {
        feeTokenRegistry = _feeTokenRegistry;
    }

    // TODO: add protocol fee on top
    function runBundles(BundleExecutionParams[] calldata _bundleExecutionParams) external onlyOwner {
        for (uint8 i = 0; i < _bundleExecutionParams.length; i++) {
            IBundler bundler = IBundler(_bundleExecutionParams[i].bundle);
            IERC20 bundleFeeToken = bundler.getFeeToken();

            uint256 feeTokenBalanceBefore = bundleFeeToken.balanceOf(address(this));
            
            uint256 transactionCostInFeeToken = getTransactionCostInFeeToken(
                address(bundleFeeToken),
                _bundleExecutionParams[i].transactionCost
            );

            bundleFeeToken.safeTransferFrom(
                address(bundler),
                address(this),
                transactionCostInFeeToken
            );

            uint256 feeTokenBalanceDelta = bundleFeeToken.balanceOf(address(this)) - feeTokenBalanceBefore;

            if (feeTokenBalanceDelta < transactionCostInFeeToken)
                revert InsufficientFeeToke();

            bundler.runBundle();
        }
    }

    function getTransactionCostInFeeToken(address _feeToken, uint256 _transactionCost) internal view returns (uint256) {
        if (feeTokenRegistry.isTokenAllowed(_feeToken))
            revert DisallowedFeeToken(_feeToken);

        AggregatorV3Interface priceFeed = feeTokenRegistry.priceFeeds(_feeToken);

        (, int256 price, , , ) = priceFeed.latestRoundData();

        // Price from Chainlink is in 8 decimal places
        uint256 priceWith8Decimals = uint256(price);

        // Convert ETH amount (in Wei) to 8 decimal places format
        uint256 ethAmountIn8Decimals = _transactionCost / 1e10; // ETH has 18 decimals, converting to 8

        // Calculate the equivalent token amount
        uint256 tokenAmount = ethAmountIn8Decimals * priceWith8Decimals;

        return tokenAmount;
    }
}
