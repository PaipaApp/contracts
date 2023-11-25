// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IFeeTokenRegistry} from "./interfaces/IFeeTokenRegistry.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
 
contract FeeTokenRegistry is IFeeTokenRegistry, Ownable {
    mapping(address => bool) internal allowedFeeTokens;
    mapping(address => AggregatorV3Interface) public priceFeeds;
    TokenInfo internal defaultFeeTokenInfo;

    event UpdateTokensPermission(TokenInfo[] tokens, bool permission);
    event UpdateDefaultToken(TokenInfo oldDefaultToken, TokenInfo newDefaultToken);

    constructor(
        address _owner,
        TokenInfo[] memory _tokens,
        TokenInfo memory _defaultFeeTokenInfo
    ) Ownable(_owner) {
        defaultFeeTokenInfo = _defaultFeeTokenInfo;
        batchUpdateTokensPermission(_tokens, true);
    }

    function approveTokens(TokenInfo[] memory _tokens) external onlyOwner {
        batchUpdateTokensPermission(_tokens, true);
    }

    function revokeTokens(TokenInfo[] memory _tokens) external onlyOwner {
        batchUpdateTokensPermission(_tokens, false);
    }

    function batchUpdateTokensPermission(TokenInfo[] memory _tokens, bool _isAllowed) internal {
        for (uint256 i; i < _tokens.length; i++) {
            address token = address(_tokens[i].token);

            allowedFeeTokens[token] = _isAllowed;
            priceFeeds[token] = _tokens[i].priceFeed;
        }

        emit UpdateTokensPermission(_tokens, _isAllowed);
    }

    function isTokenAllowed(address _token) external view returns (bool) {
        return allowedFeeTokens[_token];
    }

    function getDefaultFeeTokenInfo() external view returns (TokenInfo memory) {
        return defaultFeeTokenInfo;
    }

    function setDefaultFeeTokenInfo(TokenInfo memory _defaultFeeTokenInfo) external onlyOwner {
        emit UpdateDefaultToken(defaultFeeTokenInfo, _defaultFeeTokenInfo);

        defaultFeeTokenInfo = _defaultFeeTokenInfo;
    }
}
