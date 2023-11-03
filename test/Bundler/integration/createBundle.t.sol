// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {Bundler} from '../../../src/Bundler.sol';
import {BundlerFixture} from "../../fixtures/BundlerFixture.sol";

// Current cov: 75.00% (33/44) | 77.36% (41/53) | 56.25% (9/16)  | 55.56% (5/9)
//              77.27% (34/44) | 79.25% (42/53) | 62.50% (10/16) | 55.56% (5/9)
contract CreateBundlerTest is BundlerFixture {
    Bundler.Transaction transaction0;
    Bundler.Transaction transaction1;
    Bundler.Transaction[] transactions;
    bool[][] transactionArgsType;

    function setUp() public override {
        super.setUp();

        // NODE 0
        bytes[] memory transaction0Args = new bytes[](1);
        transaction0Args[0] = abi.encode(user0);
        transaction0 = Bundler.Transaction({
            target: address(mockStake),
            functionSignature: 'balanceOf(address)',
            args: transaction0Args
        });

        // NODE 1
        bytes[] memory transaction1Args = new bytes[](1);
        transaction1Args[0] = abi.encode(0);
        transaction1 = Bundler.Transaction({
            target: address(mockStake),
            functionSignature: 'withdraw(uint256)',
            args: transaction1Args
        });

        // INITIALIZE NODE ARGS TYPE
        transactionArgsType = new bool[][](2);

        transactionArgsType[0] = new bool[](1);
        transactionArgsType[1] = new bool[](1);

        transactionArgsType[0][0] = false;
        transactionArgsType[1][0] = true;

        transactions.push(transaction0);
        transactions.push(transaction1);
    }

    function test_CreateBundle() public {
        vm.prank(user0);
        bundler.createBundle(transactions, transactionArgsType);

        assertEq(transactions[0].args[0], abi.encode(user0));
        assertEq(transactions[0].functionSignature, 'balanceOf(address)');
        assertEq(transactions[0].target, address(mockStake));

        assertEq(transactions[1].args[0], abi.encode(0));
        assertEq(transactions[1].functionSignature, 'withdraw(uint256)');
        assertEq(transactions[1].target, address(mockStake));
    }

    function test_InitializeBitmapForTransactions() public {
        vm.prank(user0);
        bundler.createBundle(transactions, transactionArgsType);

        assertEq(bundler.argTypeIsDynamic(0, 0), false);
        assertEq(bundler.argTypeIsDynamic(1, 0), true);
    }

    function test_OverrideBundlerWithNewTransactions() public {
        bytes[] memory customNodeArgs = new bytes[](1);
        customNodeArgs[0] = abi.encode(0);
        Bundler.Transaction memory customNode = Bundler.Transaction({
            target: address(3),
            functionSignature: 'customNode(uint256)',
            args: customNodeArgs
        });

        bool[][] memory customNodeArgsType = new bool[][](1);
        customNodeArgsType[0] = new bool[](1);
        customNodeArgsType[0][0] = false;

        Bundler.Transaction[] memory customBundler = new Bundler.Transaction[](1);
        customBundler[0] = customNode;

        vm.startPrank(user0);
        {
            // Create first bundler
            bundler.createBundle(transactions, transactionArgsType);
            // Overrides the last createBundle call
            bundler.createBundle(customBundler, customNodeArgsType);
        }
        vm.stopPrank();

        Bundler.Transaction[] memory bundlerTransactions = bundler.getBundle();

        assertEq(bundlerTransactions.length, 1);
        assertEq(bundlerTransactions[0].functionSignature, 'customNode(uint256)');
        assertEq(bundlerTransactions[0].target, address(3));
        assertEq0(bundlerTransactions[0].args[0], abi.encode(0));
    }

    function test_RevertWhenArgsNotSameLength() public {
        bool[][] memory customNodeArgsType = new bool[][](0);

        vm.expectRevert(Bundler.ArgsMismatch.selector);
        vm.prank(user0);
        bundler.createBundle(transactions, customNodeArgsType);
    }

    function test_RevertWhenArgsContentNotSameLength() public {
        bool[][] memory customNodeArgsType = new bool[][](2);
        customNodeArgsType[0] = new bool[](1);
        // @dev this lines causes the mismatch, since the arg type length is 0
        customNodeArgsType[1] = new bool[](0);
        customNodeArgsType[0][0] = false;

        vm.expectRevert(Bundler.ArgsMismatch.selector);
        vm.prank(user0);
        bundler.createBundle(transactions, customNodeArgsType);
    }

    function test_RevertIfInvalidTarget() public {
        transactions[0].target = address(0);

        vm.expectRevert(Bundler.InvalidTarget.selector);
        vm.prank(user0);
        bundler.createBundle(transactions, transactionArgsType);
    }
}
