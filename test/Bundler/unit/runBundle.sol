// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {BundleFixture} from '../../fixtures/BundleFixture.sol';

contract RunBundleUnit is BundleFixture {
    uint256 constant public depositAmount = 5e18;

    function setUp() public override {
        super.setUp();

        vm.startPrank(user0);
        {
            mockToken.transfer(address(bundler), depositAmount);
            bundler.createBundle(staticStakeBundle, staticStakeArgTypes);
        }
        vm.stopPrank();
    }

    function test_RevertIfNotAdminOrRunner() public {

    }

    function test_IncrementRuns() public {
        bytes32 DEFAULT_ADMIN_ROLE = 0x00;
        console.log('HAS ADMIN ROLE: ', bundler.hasRole(DEFAULT_ADMIN_ROLE, user0));

        vm.prank(user0);
        bundler.runBundle();

        assertEq(bundler.getRuns(), 1);
    }
}
