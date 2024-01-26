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
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Bundler} from "./Bundler.sol";
import {IBundlerFactory} from "./interfaces/IBundlerFactory.sol";
import {IFeeTokenRegistry} from "./interfaces/IFeeTokenRegistry.sol";

contract BundlerFactory is IBundlerFactory, Ownable {
    IFeeTokenRegistry internal feeTokenRegistry;
    mapping(address => address[]) internal userBundlers;

    error BundlerDoesNotExist(address user, uint256 bundlerId);

    constructor(address _owner, IFeeTokenRegistry _feeTokenRegistry) Ownable(_owner) {
        feeTokenRegistry = _feeTokenRegistry;
    }

    function deployBundler(uint256 _executionInterval, address _feeToken) external returns (address bundlerAddress) {
        Bundler bundler = new Bundler(
            msg.sender,
            _executionInterval,
            _feeToken,
            feeTokenRegistry
        );
        bundlerAddress = address(bundler);
        userBundlers[msg.sender].push(bundlerAddress);
    }

    function getUserBundlers(address _user) external view returns (address[] memory) {
        return userBundlers[_user];
    }

    // TODO: fix test
    function getBundler(address _user, uint256 _bundlerId) external view returns (address) {
        address[] memory bundlers = userBundlers[_user];

        if (_bundlerId >= bundlers.length)
            revert BundlerDoesNotExist(_user, _bundlerId);

        return bundlers[_bundlerId];
    }

    function getUserBundlersLength(address _user) external view returns (uint256) {
        return userBundlers[_user].length;
    }
}
