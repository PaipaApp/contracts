// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {BundleFixture} from "../../fixtures/BundleFixture.sol";
import {Bundler} from "../../../src/Bundler.sol";

// Given the owner of the contract
//      When the owner calls runBundle
//      And the time ellapse is less than executionInterval
//          Then the transaction reverts with ExecutionBeforeInterval
//      And the time ellapse is greater than executionInterval
//          Then the transaction succeeds
//      Then increments the runs counter
contract RunBundleUnit is BundleFixture {
    uint256 public constant depositAmount = 10e18;

    modifier givenOwner() {
        _;
    }

    modifier whenOwnerCallsRunBundle() {
        _;
    }

    modifier andTimeEllapseIsGreaterThanExecutionInterval() {
        _;
    }

    modifier andTimeEllapseIsLessThanExecutionInterval() {
        _;
    }

    function setUp() public override {
        super.setUp();

        vm.startPrank(user0);
        {
            mockToken.transfer(address(bundler), depositAmount);
            bundler.createBundle(staticStakeBundle, staticStakeArgTypes);
        }
        vm.stopPrank();
    }

    function test_RunBundleAfterInterval()
        givenOwner
        whenOwnerCallsRunBundle
        andTimeEllapseIsGreaterThanExecutionInterval
        public
    {
        vm.startPrank(user0);
        {
            bundler.setExecutionInterval(1 days);
            bundler.runBundle();
        }
        vm.stopPrank();
    }

    function test_RunBundleBeforeInterval()
        givenOwner
        whenOwnerCallsRunBundle
        andTimeEllapseIsGreaterThanExecutionInterval
        public
    {
        vm.startPrank(user0);
        {
            bundler.setExecutionInterval(1 days);
            // @dev this call should succeed
            bundler.runBundle();

            vm.expectRevert(Bundler.ExecutionBeforeInterval.selector);
            bundler.runBundle();
        }
        vm.stopPrank();
    }

    function test_IncrementRuns() givenOwner whenOwnerCallsRunBundle public {
        vm.prank(user0);
        bundler.runBundle();

        assertEq(bundler.getRuns(), 1);
    }

    // TODO: use vm.expectCall to test if all the contracts are called
}
