// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {CreateBundleFixture} from "../../fixtures/CreateBundleFixture.sol";
import {BundleRunner} from "../../../src/BundleRunner.sol";
import {IBundleRunner} from "../../../src/interfaces/IBundleRunner.sol";
import {IBundler} from "../../../src/interfaces/IBundler.sol";

//  Given the owner of the contract
//      When runBundles is called
//          Then fees are transferred to treasury 
//      And execution fee is higher than maxFeePerRun
//         Then revert with FeeTooHigh error
contract RunBundlesTest is CreateBundleFixture {
    address user0Bundle;
    address user1Bundle;
    uint256 maxFeePerRun = 5e18;
    uint256 constant transactionCost = 1000000000000000;

    function setUp() public override {
        super.setUp();

        user0Bundle = factory.getBundler(user0, 0);
        user1Bundle = factory.getBundler(user1, 0);

        vm.startPrank(user0); {
            IBundler(user0Bundle).approveBundleRunner(address(runner));
            IBundler(user0Bundle).setMaxFeePerRun(maxFeePerRun);
            mockToken.transfer(user0Bundle, 100e18);
        }
        vm.stopPrank();

        vm.startPrank(user1); {
            IBundler(user1Bundle).approveBundleRunner(address(runner));
            IBundler(user1Bundle).setMaxFeePerRun(maxFeePerRun);
            mockToken.transfer(user1Bundle, 100e18);
        }
        vm.stopPrank();
    }

    function test_RunSingleBundle() public {
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);
        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            transactionCost 
        );

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
    }

    function test_RunMultipleBundles() public {
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](2);
        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            // @dev value is in wei
            transactionCost
        );
        bundles[1] = IBundleRunner.BundleExecutionParams(
            user1Bundle,
            // @dev value is in wei
            transactionCost
        );

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        assertEq(IBundler(user0Bundle).getRuns(), uint256(1));
        assertEq(IBundler(user1Bundle).getRuns(), uint256(1));
    }

    function test_SendFeesToTreasury() public {
        address treasury = runner.getTreasury(); 
        uint treasurBalanceBefore = mockToken.balanceOf(treasury);
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);

        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            // @dev value is in wei
            transactionCost
        );

        vm.prank(runnerOwner);
        runner.runBundles(bundles);

        uint treasuryBalanceDelta = mockToken.balanceOf(treasury) - treasurBalanceBefore;
        uint expectedTokenBalance = 2e18;

        assertEq(treasuryBalanceDelta, expectedTokenBalance);
    }

    function test_RevertsIfFeeTokenPriceIsZero() public {
        mockPriceFeed.setPrice(0);
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);
        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            // @dev value is in wei
            transactionCost
        );

        vm.prank(runnerOwner);
        vm.expectRevert(BundleRunner.FeeTokenPriceCannotBeZero.selector);
        runner.runBundles(bundles);
    }

    function test_RevertsIfBundleSizeIsTooBig() public {
        uint8 oneOverLimit = runner.getBundleLimitPerBlock() + 1;
        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](oneOverLimit);

        for (uint8 i; i > oneOverLimit; i++) {
            bundles[i] = IBundleRunner.BundleExecutionParams(
                user0Bundle,
                // @dev value is in wei
                transactionCost
            );
        }

        vm.prank(runnerOwner);
        vm.expectRevert(BundleRunner.BundleTooBig.selector);
        runner.runBundles(bundles);
    }

    function test_RevertsIfFeeIsTooHigh() public {
        uint256 newMaxFeePerRun = 1e18;
        (, int256 price, , , ) = mockPriceFeed.latestRoundData();
        uint256 tokenAmount = transactionCost * uint256(price * 1e10) / 1e18;

        vm.prank(user0);
        IBundler(user0Bundle).setMaxFeePerRun(newMaxFeePerRun);

        bytes memory errorSelector = abi.encodeWithSelector(
            BundleRunner.FeeTooHigh.selector,
            tokenAmount,
            newMaxFeePerRun
        );

        IBundleRunner.BundleExecutionParams[] memory bundles = new IBundleRunner.BundleExecutionParams[](1);

        bundles[0] = IBundleRunner.BundleExecutionParams(
            user0Bundle,
            // @dev value is in wei
            transactionCost
        );

        vm.prank(runnerOwner);
        vm.expectRevert(errorSelector);
        runner.runBundles(bundles);
    }

    function test_RevertOnDisallowedFeeToken() public {}
}
