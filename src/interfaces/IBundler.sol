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

    function withdrawERC20(address _token, uint256 _amount) external;

    function withdraw721(address _token, uint256 _tokenId) external;

    function getRuns() external view returns (uint256);

    function approveRunner(address _runner) external;

    function revokeRunner(address _runner) external;

    function setFeeToken(IERC20 _feeToken) external;

    function getFeeToken() external view returns (IERC20);

}
