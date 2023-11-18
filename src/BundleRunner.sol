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
import {IERC20} from 'openzeppelin-contracts/contracts/interfaces/IERC20.sol';
import {IBundleRunner} from "./interfaces/IBundleRunner.sol";
import {IBundler} from "./interfaces/IBundler.sol";
import "forge-std/console.sol";

contract BundleRunner is IBundleRunner, Ownable {
    constructor(address _owner) Ownable(_owner) {}

    // TODO: the fee transfer check needs to live in this contract, otherwise users
    // can try to run bundle in a bootlet bundles. Which it wont be an attack on the users
    // but on the protocol/product/company
    function runBundles(BundleExecutionParams[] calldata _bundleExecutionParams) external onlyOwner {
        for (uint8 i = 0; i < _bundleExecutionParams.length; i++) {
            IBundler bundler = IBundler(_bundleExecutionParams[i].bundle);

            IERC20(bundler);

            bundler.runBundle();
        }
    }
}
