// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pipe} from "./Pipe.sol";

contract PipeFactory is Ownable {
    mapping(address => address[]) internal userPipes;

    constructor() {
        transferOwnership(msg.sender);
    }

    function deployPipe(uint256 _executionInterval) external returns (address) {
        Pipe pipe = new Pipe(msg.sender, _executionInterval);

        address pipeAddress = address(pipe);

        userPipes[msg.sender].push(pipeAddress);

        return pipeAddress;
    }

    function getUserPipes(address user) external view returns (address[] memory) {
        return userPipes[user];
    }
}
