// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {TransactionsFixture, TransactionType, TransactionName} from "../../fixtures/TransactionsFixture.sol";
import {IBundler} from "../../../src/interfaces/IBundler.sol";

contract CreateBundlerTest is TransactionsFixture {
    IBundler.Transaction[] public staticBundle;
    bool[][] public staticBundleArgTypes;

    // @dev It isn't possible to have a fully dynamic bundle, since the first tx
    // always needs to be static
    IBundler.Transaction[] public mixedBundle;
    bool[][] public mixedBundleArgTypes;

    function setUp() public override {
        super.setUp();

        // Mounting static bundle
        staticBundle.push(transactions[TransactionType.STATIC][TransactionName.WITHDRAW].tx);
        // Mounting static bundle arg types
        staticBundleArgTypes = new bool[][](1);
        staticBundleArgTypes[0] = transactions[TransactionType.STATIC][TransactionName.WITHDRAW].txArgTypes;

        // Mounting mixed bundle
        mixedBundle.push(transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].tx);
        mixedBundle.push(transactions[TransactionType.DYNAMIC][TransactionName.WITHDRAW].tx);
        // Mounting mixed arg types
        mixedBundleArgTypes = new bool[][](2);
        mixedBundleArgTypes[0] = transactions[TransactionType.STATIC][TransactionName.BALANCE_OF].txArgTypes;
        mixedBundleArgTypes[1] = transactions[TransactionType.DYNAMIC][TransactionName.WITHDRAW].txArgTypes;
    }

    function test_CreateStaticBundle() public {
        vm.prank(user0);
        bundler.createBundle(staticBundle, staticBundleArgTypes);
        IBundler.Transaction[] memory transactions = bundler.getTransactions();

        assertEq(transactions[0].args[0], staticBundle[0].args[0]);
        assertEq(transactions[0].functionSignature, staticBundle[0].functionSignature);
        assertEq(transactions[0].target, staticBundle[0].target);
    }

    function test_CreateMixedBundle() public {
        vm.prank(user0);
        bundler.createBundle(mixedBundle, mixedBundleArgTypes);
        IBundler.Transaction[] memory transactions = bundler.getTransactions();

        assertEq(transactions[0].args[0], mixedBundle[0].args[0]);
        assertEq(transactions[0].functionSignature, mixedBundle[0].functionSignature);
        assertEq(transactions[0].target, mixedBundle[0].target);

        assertEq(transactions[1].args[0], mixedBundle[1].args[0]);
        assertEq(transactions[1].functionSignature, mixedBundle[1].functionSignature);
        assertEq(transactions[1].target, mixedBundle[1].target);
    }

    function test_InitializeArgsTypeBitmap() public {
        vm.prank(user0);
        bundler.createBundle(mixedBundle, mixedBundleArgTypes);

        assertEq(bundler.argTypeIsDynamic(0, 0), false);
        assertEq(bundler.argTypeIsDynamic(1, 0), true);
    }

    function test_OverrideBundleWithNewTransactions() public {
        vm.startPrank(user0);
        {
            bundler.createBundle(staticBundle, staticBundleArgTypes);
            // @dev Overrides the last createBundle call
            bundler.createBundle(mixedBundle, mixedBundleArgTypes);
        }
        vm.stopPrank();

        IBundler.Transaction[] memory bundlerTransactions = bundler.getBundle();

        assertEq(bundlerTransactions.length, mixedBundle.length);
        assertEq(bundlerTransactions[0].functionSignature, mixedBundle[0].functionSignature);
        assertEq(bundlerTransactions[0].target, mixedBundle[0].target);
        assertEq0(bundlerTransactions[0].args[0], mixedBundle[0].args[0]);

        assertEq(bundlerTransactions[1].functionSignature, mixedBundle[1].functionSignature);
        assertEq(bundlerTransactions[1].target, mixedBundle[1].target);
        assertEq0(bundlerTransactions[1].args[0], mixedBundle[1].args[0]);
    }

    function test_RevertWhenArgsNotSameLength() public {
        vm.expectRevert(Bundler.ArgsMismatch.selector);
        vm.prank(user0);
        bundler.createBundle(staticBundle, mixedBundleArgTypes);
    }

    function test_RevertWhenArgsContentNotSameLength() public {
        bool[][] memory customNodeArgsType = new bool[][](2);
        customNodeArgsType[0] = new bool[](1);
        // @dev this lines causes the mismatch, since the arg type length is 0
        customNodeArgsType[1] = new bool[](0);
        customNodeArgsType[0][0] = false;

        vm.expectRevert(Bundler.ArgsMismatch.selector);
        vm.prank(user0);
        bundler.createBundle(mixedBundle, customNodeArgsType);
    }

    function test_RevertIfInvalidTarget() public {
        staticBundle[0].target = address(0);

        vm.expectRevert(Bundler.InvalidTarget.selector);
        vm.prank(user0);
        bundler.createBundle(staticBundle, staticBundleArgTypes);
    }

    function test_RevertWithFirstTransactionWithDynamicArg() public {
        mixedBundleArgTypes[0][0] = true;

        vm.expectRevert(Bundler.FirstTransactionWithDynamicArg.selector);
        vm.prank(user0);
        bundler.createBundle(mixedBundle, mixedBundleArgTypes);
    }

}
