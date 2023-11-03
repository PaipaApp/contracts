/**
       ███████████             ███                     
      ░░███░░░░░███           ░░░                      
       ░███    ░███  ██████   ████  ████████   ██████  
       ░██████████  ░░░░░███ ░░███ ░░███░░███ ░░░░░███ 
       ░███░░░░░░    ███████  ░███  ░███ ░███  ███████ 
       ░███         ███░░███  ░███  ░███ ░███ ███░░███ 
       █████       ░░████████ █████ ░███████ ░░████████
      ░░░░░         ░░░░░░░░ ░░░░░  ░███░░░   ░░░░░░░░ 
                                    ░███               
                                    █████              
                                   ░░░░░         
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Bundler} from "./Bundler.sol";

contract BundlerFactory is Ownable {
    mapping(address => address[]) internal userBundlers;

    constructor(address _owner) Ownable(_owner) {}

    function deployBundler(uint256 _executionInterval) external returns (address) {
        Bundler bundler = new Bundler(msg.sender, _executionInterval);

        address bundlerAddress = address(bundler);

        userBundlers[msg.sender].push(bundlerAddress);

        return bundlerAddress;
    }

    function getUserBundlers(address user) external view returns (address[] memory) {
        return userBundlers[user];
    }
}