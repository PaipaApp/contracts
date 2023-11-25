// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IFeeTokenRegistry {
    struct TokenInfo {
        IERC20 token;
        AggregatorV3Interface priceFeed;
    }

    function priceFeeds(address) external view returns (AggregatorV3Interface);

    function approveTokens(TokenInfo[] memory _tokens) external;

    function revokeTokens(TokenInfo[] memory _tokens) external;

    function isTokenAllowed(address _token) external view returns (bool);

    function getDefaultFeeTokenInfo() external view returns (TokenInfo memory);

    function setDefaultFeeTokenInfo(TokenInfo memory _defaultTokenInfoData) external;
}
