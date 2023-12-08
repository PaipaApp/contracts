// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {CreateBundleFixture} from "../../fixtures/CreateBundleFixture.sol";
import {BundleRunner} from "../../../src/BundleRunner.sol";
import {IBundleRunner} from "../../../src/interfaces/IBundleRunner.sol";
import {IBundler} from "../../../src/interfaces/IBundler.sol";

contract RunBundlesTest is CreateBundleFixture {
    address user0Bundle;
    address user1Bundle;

    function setUp() public override {
        super.setUp();

        user0Bundle = factory.getBundler(user0, 0);
        user1Bundle = factory.getBundler(user1, 0);

        vm.startPrank(user0); {
            IBundler(user0Bundle).approveBundleRunner(address(runner));
            mockToken.transfer(user0Bundle, 100e18);
        }
        vm.stopPrank();

        vm.startPrank(user1); {
            IBundler(user1Bundle).approveBundleRunner(address(runner));
            mockToken.transfer(user0Bundle, 100e18);
        }
        vm.stopPrank();

    }

    function test_RunSingleBundle() public {
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);
        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            1000000000000000 
        );

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
    }

    // TODO: add one more tx to bundle
    function test_RunMultipleBundles() public {
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);
        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            1000000000000000
        );

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
        // assertEq(IBundler(user1Bundle).getRuns(), uint256(1));
    }

    function test_SendFeesToTreasury() public {
        uint treasurBalanceBefore = mockToken.balanceOf(address(runner));

        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);
        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            1000000000000000
        );

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertTrue(mockToken.balanceOf(address(runner)) - treasurBalanceBefore > 0);
    }

    function test_RevertOnDisallowedFeeToken() public {}
}
