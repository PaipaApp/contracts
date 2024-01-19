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

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

interface IBundler {
    struct Transaction {
        address target;
        string functionSignature;
        bytes[] args;
    }

    function createBundle(Transaction[] memory _transactions, bool[][] calldata _argTypes) external;

    function runBundle() external;

    function runTransaction(address target, bytes calldata data) external returns (bytes memory);

    function getBundle() external view returns (Transaction[] memory);

    function setExecutionInterval(uint256 _executionInterval) external;

    function getRuns() external view returns (uint256);

    function approveBundleRunner(address _runner) external;

    function revokeBundleRunner(address _runner) external;

    function setFeeToken(address _feeToken) external;

    function getFeeToken() external view returns (IERC20);

    function depositFeeToken(uint256 _amount) external;

    function getMaxFeePerRun() external view returns (uint256);

    function setMaxFeePerRun(uint256 _maxFeePerRun) external;
}
