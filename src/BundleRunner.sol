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
import {IBundleRunner} from "./interfaces/IBundleRunner.sol";
import {IBundler} from "./interfaces/IBundler.sol";

contract BundleRunner is IBundleRunner, Ownable {
    constructor(address _owner) Ownable(_owner) {}

    function runBundles(address[] calldata _bundlers) external onlyOwner {
        for (uint8 i = 0; i < _bundlers.length; i++) {
            IBundler(_bundlers[i]).runBundle();
        }
    }
}
