// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Bundler} from "./Bundler.sol";

contract BundlerFactory is Ownable {
    mapping(address => address[]) internal userBundlers;

    constructor() {
        transferOwnership(msg.sender);
    }

    function deployBundler(uint256 _executionInterval) external returns (address) {
        Bundler pipe = new Bundler(msg.sender, _executionInterval);

        address pipeAddress = address(pipe);

        userBundlers[msg.sender].push(pipeAddress);

        return pipeAddress;
    }

    function getUserBundlers(address user) external view returns (address[] memory) {
        return userBundlers[user];
    }
}
