// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IFeeTokenRegistry {
    function approveTokens(address[] memory _tokens) external;

    function revokeTokens(address[] memory _tokens) external;

    function isTokenAllowed(address _token) external view returns (bool);

    function getDefaultFeeToken() external view returns (address);
}
