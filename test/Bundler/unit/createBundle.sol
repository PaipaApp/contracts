// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BundleFixture} from "../../fixtures/BundleFixture.sol";
import {TransactionType, TransactionName} from "../../fixtures/TransactionsFixture.sol";
import {IBundler} from "../../../src/interfaces/IBundler.sol";
import {Bundler} from "../../../src/Bundler.sol";

// Given the owner of the contract
//      When the owner creates a bundle
//      And the bundle is longer than MAX_BUNDLE_SIZE
//          Then the transaction reverts with MaxTransactionPerBundleReached
contract CreateBundleTestUnit is BundleFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_CreateBundleWithMoreThanMaxTransactions() public {
        IBundler.Transaction[] memory bundle = new IBundler.Transaction[](bundler.MAX_BUNDLE_SIZE() + 1);
        for (uint256 i = 0; i < bundler.MAX_BUNDLE_SIZE() + 1; i++) {
            bundle[i] = transactions[TransactionType.STATIC][TransactionName.WITHDRAW].tx;
        }

        vm.prank(user0);
        vm.expectRevert(Bundler.MaxTransactionPerBundleReached.selector);
        bundler.createBundle(bundle, new bool[][](0));
    }
}

