// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IFeeTokenRegistry {
    struct FeeToken {
        address token;
        address priceFeed;
    }

    function priceFeeds(address) external view returns (AggregatorV3Interface);

    function approveTokens(FeeToken[] memory _tokens) external;

    function revokeTokens(address[] memory _tokens) external;

    function isTokenAllowed(address _token) external view returns (bool);

    function getDefaultFeeToken() external view returns (FeeToken memory);

    function getPriceFeedForToken(address _token) external view returns (AggregatorV3Interface);
}
