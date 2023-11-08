// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import {CreateBundleFixture} from '../../fixtures/CreateBundleFixture.sol';
import {BundleRunner} from '../../../src/BundleRunner.sol';
import {IBundler} from '../../../src/interfaces/IBundler.sol';

contract RunBundlesTest is CreateBundleFixture {
    address user0Bundle;

    function setUp() public override {
        super.setUp();

        user0Bundle = factory.getBundler(user0, 0);

        vm.prank(user0);
        IBundler(user0Bundle).approveRunner(address(runner));
    }

    function test_RunSingleBundle() public {
        address[] memory bundles = new address[](1);
        bundles[0] = user0Bundle;

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
    }
}
