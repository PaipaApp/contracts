// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {IBundler} from "../../../src/interfaces/IBundler.sol";
import {BundleFixture} from "../../fixtures/BundleFixture.sol";

contract RunBundleIntegraiton is BundleFixture {
    uint256 public constant depositAmount = 5e18;

    function setUp() public override {
        super.setUp();

        vm.prank(user0);
        mockToken.transfer(address(bundler), depositAmount);
    }

    function test_RunBundleWithStaticArgs() public {
        vm.startPrank(user0);
        {
            bundler.createBundle(staticStakeBundle, staticStakeArgTypes);
            bundler.runBundle();
        }
        vm.stopPrank();

        assertEq(bundler.getRuns(), 1);
        assertEq(mockStake.stakeBalance(address(bundler)), depositAmount);
    }

    function test_RunBundleWithDynamicArgs() public {
        vm.startPrank(user0);
        {
            bundler.createBundle(dynamicStakeBundle, dynamicStakeArgTypes);
            bundler.runBundle();
        }
        vm.stopPrank();

        assertEq(bundler.getRuns(), 1);
        assertEq(mockStake.stakeBalance(address(bundler)), depositAmount);
    }
}
