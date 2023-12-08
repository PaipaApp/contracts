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

// TODO: transfer fees to a treasury
contract BundleRunner is IBundleRunner, Ownable {
    using SafeERC20 for IERC20;

    IFeeTokenRegistry internal feeTokenRegistry;

    error DisallowedFeeToken(address feeToken);
    error InsufficientFeeToke();
    error FeeTokenPriceCannotBeZero();

    constructor(address _owner, IFeeTokenRegistry _feeTokenRegistry) Ownable(_owner) {
        feeTokenRegistry = _feeTokenRegistry;
    }

    // TODO: add protocol fee on top
    function runBundles(BundleExecutionParams[] calldata _bundleExecutionParams) external onlyOwner {
        for (uint8 i = 0; i < _bundleExecutionParams.length; i++) {
            IBundler bundler = IBundler(_bundleExecutionParams[i].bundle);
            address feeToken = address(bundler.getFeeToken());

            AggregatorV3Interface priceFeed = feeTokenRegistry.getPriceFeedForToken(feeToken);
            (, int256 price, , , ) = priceFeed.latestRoundData();

            if (price < 0)
                revert FeeTokenPriceCannotBeZero();

            // @dev priceFeed returns the price in 8 decimals, need to convert ETH to 8 decimals
            uint256 ethAmountIn8Decimals = _bundleExecutionParams[i].transactionCost / 1e10;
            uint256 tokenAmount = ethAmountIn8Decimals * uint256(price);

            bundler.getFeeToken().safeTransferFrom(
                address(bundler),
                address(this),
                tokenAmount
            );
            bundler.runBundle();
        }
    }
}
