// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {IAccessControl} from "openzeppelin-contracts/contracts/access/IAccessControl.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {BaseFixture} from "../../fixtures/BaseFixture.sol";

// Given the owner of the contract
//     When call approveBundleRunner
//          Then the bundleRunner should be set to the new runner
//          Then emit BundleRunnerApproved event with the new runner
//          Then set the new runner's allowance to max uint256
// Given a non-owner of the contract
//      When call approveBundleRunner
//          Then revert with AccessControlUnauthorizedAccount error
contract ApproveBundleRunnerUnit is BaseFixture {
    modifier givenOwner() {
        _;
    }

    modifier givenNonOwner() {
        _;
    }

    modifier whenCallApproveBundleRunner() {
        _;
    }

    function test_BundleRunnerShouldBeSetToTheNewRunner()
        givenOwner
        whenCallApproveBundleRunner
        public
    {
        vm.prank(user0);
        bundler.approveBundleRunner(address(runner));

        assertEq(bundler.getBundleRunner(), address(runner));
    }

    function test_ShouldEmitBundleRunnerApprovedEventWithTheNewRunner()
        givenOwner
        whenCallApproveBundleRunner
        public
    {
        vm.expectEmit(address(bundler));
        emit Bundler.BundleRunnerApproved(address(runner));

        vm.prank(user0);
        bundler.approveBundleRunner(address(runner));
    }

    function test_ShouldSetTheNewRunnerAllowanceToMaxUint256()
        givenOwner
        whenCallApproveBundleRunner
        public
    {
        IERC20 feeToken = IERC20(bundler.feeToken());
        vm.prank(user0);
        bundler.approveBundleRunner(address(runner));

        assertEq(feeToken.allowance(address(bundler), address(runner)), type(uint256).max);
    }

    function test_RevertWithAccessControlUnauthorizedAccount() 
        givenNonOwner
        whenCallApproveBundleRunner
        public
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            address(this),
            0x00 // DEFAULT_ADMIN_ROLE
        );

        vm.expectRevert(errorSelector);
        bundler.approveBundleRunner(address(runner));
    }
}
