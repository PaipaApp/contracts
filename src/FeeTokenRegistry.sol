// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IFeeTokenRegistry} from "./interfaces/IFeeTokenRegistry.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/console.sol";
 
contract FeeTokenRegistry is IFeeTokenRegistry, Ownable {
    mapping(address => bool) internal allowedFeeTokens;
    mapping(address => AggregatorV3Interface) internal priceFeeds;
    address public defaultFeeToken;

    event ApprovedTokens(FeeToken[] tokens);
    event RevokedTokens(address[] tokens);
    event UpdatedPriceFeeds(FeeToken[] tokens);
    event UpdateDefaultToken(address newToken, address oldToken);

    error InvalidTokensLength();
    error InvalidTokenAddress();
    error InvalidFeeTokenParams(address token, address priceFeed);

    constructor(address _owner, FeeToken[] memory _tokens, address _defaultFeeToken) Ownable(_owner) {
        defaultFeeToken = _defaultFeeToken;
        _approveTokens(_tokens);
    }

    function approveTokens(FeeToken[] memory _tokens) external onlyOwner {
        _approveTokens(_tokens);
    }

    // @dev [`_tokens`] is assigned to memory because it is used by the constructor
    // and constructor cannot assign parameters to calldata
    function _approveTokens(FeeToken[] memory _tokens) internal {
        if (_tokens.length > 10)
            revert InvalidTokensLength();

        for (uint8 i; i < _tokens.length; i++) {
            address token = _tokens[i].token;
            address priceFeed = _tokens[i].priceFeed;

            if (token == address(0) || priceFeed == address(0))
                revert InvalidFeeTokenParams(token, priceFeed);

            allowedFeeTokens[token] = true;
            priceFeeds[token] = AggregatorV3Interface(priceFeed);
        }

        emit ApprovedTokens(_tokens);
    }

    function revokeTokens(address[] memory _tokens) external onlyOwner {
        if (_tokens.length > 10)
            revert InvalidTokensLength();

        for (uint8 i; i < _tokens.length; i++) {
            address token = _tokens[i];

            if (token == address(0))
                revert InvalidTokenAddress();

            allowedFeeTokens[token] = false;
        }

        emit RevokedTokens(_tokens);
    }

    function updatePriceFeeds(FeeToken[] memory _tokens) external onlyOwner {
        if (_tokens.length > 10)
            revert InvalidTokensLength();

        for (uint8 i; i < _tokens.length; i++) {
            address token = _tokens[i].token;
            address priceFeed = _tokens[i].priceFeed;

            if (token == address(0) || priceFeed == address(0))
                revert InvalidFeeTokenParams(token, priceFeed);

            priceFeeds[token] = AggregatorV3Interface(priceFeed);
        }

        emit UpdatedPriceFeeds(_tokens);
    }

    function isTokenAllowed(address _token) external view returns (bool) {
        return allowedFeeTokens[_token];
    }

    function getDefaultFeeToken() external view returns (FeeToken memory) {
        return FeeToken ({
            token: defaultFeeToken,
            priceFeed: defaultFeeToken
        });
    }

    function setDefaultFeeToken(address _defaultFeeTokenInfo) external onlyOwner {
        emit UpdateDefaultToken(_defaultFeeTokenInfo, _defaultFeeTokenInfo);

        defaultFeeToken = _defaultFeeTokenInfo;
    }

    function getPriceFeedForToken(address _token) external view returns (AggregatorV3Interface) {
        return priceFeeds[_token];
    }
}
