// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {Pausable} from "openzeppelin-contracts/contracts/utils/Pausable.sol";
import {BundleFixture} from "../../fixtures/BundleFixture.sol";
import {Bundler} from "../../../src/Bundler.sol";

// Given the owner of the contract
//      When the account calls runBundle
//          And the time ellapse is less than executionInterval
//              Then the transaction reverts with ExecutionBeforeInterval
//          And the time ellapse is greater than executionInterval
//              Then the transaction succeeds
//          And contract is paused
//              Then the transaction reverts with Paused
//          Then increments the runs counter
// Given an account with the role BUNDLE_RUNNER
//      When the account calls runBundle
//          Then the transaction succeeds
// Given an account without any role
//      When the account calls runBundle
//         Then the transaction reverts with NotAllowedToRunBundle
contract RunBundleUnit is BundleFixture {
    uint256 public constant depositAmount = 10e18;

    modifier givenOwner() {
        _;
    }

    modifier givenBundleRunner() {
        _;
    }

    modifier givenNoRole() {
        _;
    }

    modifier whenTheAccountCallsRunBundle() {
        _;
    }

    modifier andTimeEllapseIsGreaterThanExecutionInterval() {
        _;
    }

    modifier andTimeEllapseIsLessThanExecutionInterval() {
        _;
    }
    
    modifier andContractIsPaused() {
        _;
    }

    function setUp() public override {
        super.setUp();

        vm.startPrank(user0);
        {
            mockToken.transfer(address(bundler), depositAmount);
            bundler.createBundle(staticStakeBundle, staticStakeArgTypes);
            bundler.setExecutionInterval(1 days);
        }
        vm.stopPrank();
    }

    function test_RunBundleWithBundleRunnerRole() givenBundleRunner whenTheAccountCallsRunBundle public {
        vm.prank(user0);
        bundler.approveBundleRunner(user1);

        vm.prank(user1);
        bundler.runBundle();
    }

    function test_RunBundleWithNoRole() givenNoRole whenTheAccountCallsRunBundle public {
        vm.expectRevert(Bundler.NotAllowedToRunBundle.selector);
        bundler.runBundle();
    }

    function test_RunBundleWithOwnerRole()
        givenOwner
        whenTheAccountCallsRunBundle
        andTimeEllapseIsGreaterThanExecutionInterval
        public
    {
        vm.prank(user0);
        bundler.runBundle();
    }

    function test_RunBundleBeforeInterval()
        givenOwner
        whenTheAccountCallsRunBundle
        andTimeEllapseIsGreaterThanExecutionInterval
        public
    {
        vm.startPrank(user0);
        {
            // @dev this call should succeed
            bundler.runBundle();

            vm.expectRevert(Bundler.ExecutionBeforeInterval.selector);
            bundler.runBundle();
        }
        vm.stopPrank();
    }

    function test_RevertsWithPaused() 
        givenOwner
        whenTheAccountCallsRunBundle 
        andContractIsPaused 
        public
    {
        vm.startPrank(user0); {
            bundler.pauseRuns();

            vm.expectRevert(Pausable.EnforcedPause.selector);
            bundler.runBundle();
        }
        vm.stopPrank();
    }

    function test_IncrementRuns() givenOwner whenTheAccountCallsRunBundle public {
        vm.prank(user0);
        bundler.runBundle();

        assertEq(bundler.getRuns(), 1);
    }

    // TODO: use vm.expectCall to test if all the contracts are called => this is an integration test
}
