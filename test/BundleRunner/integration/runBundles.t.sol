// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {CreateBundleFixture} from "../../fixtures/CreateBundleFixture.sol";
import {BundleRunner} from "../../../src/BundleRunner.sol";
import {IBundler} from "../../../src/interfaces/IBundler.sol";

contract RunBundlesTest is CreateBundleFixture {
    address user0Bundle;
    address user1Bundle;

    function setUp() public override {
        super.setUp();

        user0Bundle = factory.getBundler(user0, 0);
        user1Bundle = factory.getBundler(user1, 0);

        vm.prank(user0);
        IBundler(user0Bundle).approveRunner(address(runner));

        vm.prank(user1);
        IBundler(user1Bundle).approveRunner(address(runner));
    }

    function test_RunSingleBundle() public {
        address[] memory bundles = new address[](1);
        bundles[0] = user0Bundle;

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
    }

    function test_RunMultipleBundles() public {
        address[] memory bundles = new address[](2);
        bundles[0] = user0Bundle;
        bundles[1] = user1Bundle;

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
        assertEq(IBundler(user1Bundle).getRuns(), uint256(1));
    }
}
