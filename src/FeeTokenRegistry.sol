// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';

contract FeeTokenRegistry is Ownable{
    mapping(address => bool) public allowedFeeTokens;

    event UpdateTokensPermission(address[] tokens, bool permission);

    constructor(address _owner, address[] memory _tokens) Ownable(_owner) {
        batchUpdateTokensPermission(_tokens, true);
    }

    function approveTokens(address[] memory _tokens) external onlyOwner {
        batchUpdateTokensPermission(_tokens, true);
    }

    function revokeTokens(address[] memory _tokens) external onlyOwner {
        batchUpdateTokensPermission(_tokens, false);
    }

    function batchUpdateTokensPermission(address[] memory _tokens, bool _isAllowed) internal {
        for (uint256 i; i < _tokens.length; i++) {
            allowedFeeTokens[_tokens[i]] = _isAllowed;
        }

        emit UpdateTokensPermission(_tokens, _isAllowed);
    }
}
