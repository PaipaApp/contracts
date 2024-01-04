// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IAccessControl} from "openzeppelin-contracts/contracts/access/IAccessControl.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {BundleFixture} from "../../fixtures/BundleFixture.sol";

// Given owner of contract
//      When call setExecutionInterval
//          Then executionInterval is set to new value
//          Then emits SetExecutionInterval event
// Given a non-owner of contract
//     When call setExecutionInterval
//        Then reverts with AccessControlUnauthorizedAccount
contract SetExecutionIntervalUnit is BundleFixture {
    uint256 constant public newExecutionInterval = 1 days;

    modifier givenOwner() {
        _;
    }

    modifier givenNonOwner() {
        _;
    }

    modifier whenCallSetExecutionInterval() {
        _;
    }

    function test_SetExecutionIntervalNewValue() public {
        vm.prank(user0);
        bundler.setExecutionInterval(newExecutionInterval);

        assertEq(bundler.getExecutionInterval(), newExecutionInterval);
    }

    function test_EmitsSetExecutionIntervalEvent() public {
        vm.expectEmit(address(bundler));
        emit Bundler.SetExecutionInterval(
            bundler.getExecutionInterval(),
            newExecutionInterval
        );

        vm.prank(user0);
        bundler.setExecutionInterval(newExecutionInterval);
    }

    function test_RevertsWhenCallSetExecutionIntervalWithNonOwner() public {
        bytes memory errorSelector = abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            address(this),
            0x00
        );

        vm.expectRevert(errorSelector);
        bundler.setExecutionInterval(newExecutionInterval);
    }
}
