// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {BaseFixture} from "../../fixtures/BaseFixture.sol";
import {Bundler} from "../../../src/Bundler.sol";

// Given the owner of the contract
//      When call revokeBundleRunner
//          Then the bundleRunner should be set to zero address
//          Then emit BundleRunnerRevoked event with the old runner
//          Then set runner's allowance to zero
// Given a non-owner of the contract
//      When call revokeBundleRunner
//         Then revert with AccessControlUnauthorizedAccount error
contract RevokeBundleRunnerUnit is BaseFixture {
    function setUp() public override {
        super.setUp();

        vm.prank(user0);
        bundler.approveBundleRunner(address(runner));
    }

    modifier givenOwner() {
        _;
    }

    modifier givenNonOwner() {
        _;
    }

    modifier whenCallRevokeBundleRunner() {
        _;
    }

    function test_BundleRunnerShouldBeSetToZeroAddress()
        givenOwner
        whenCallRevokeBundleRunner
        public
    {
        vm.prank(user0);
        bundler.revokeBundleRunner(address(runner));

        assertEq(bundler.getBundleRunner(), address(0));
    }

    function test_ShouldEmitBundleRunnerRevokedEventWithTheOldRunner()
        givenOwner
        whenCallRevokeBundleRunner
        public
    {
        vm.expectEmit(address(bundler));
        emit Bundler.BundleRunnerRevoked(address(runner));

        vm.prank(user0);
        bundler.revokeBundleRunner(address(runner));
    }

    function test_ShouldSetRunnerAllowanceToZero()
        givenOwner
        whenCallRevokeBundleRunner
        public
    {
        IERC20 feeToken = bundler.getFeeToken();
        vm.prank(user0);
        bundler.revokeBundleRunner(address(runner));

        assertEq(feeToken.allowance(address(bundler), address(runner)), 0);
    }
}

