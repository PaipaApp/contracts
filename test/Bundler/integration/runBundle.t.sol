// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {BundlerFixture} from '../../fixtures/BundlerFixture.sol';
import {IBundler} from '../../../src/interfaces/IBundler.sol';

contract RunBundlerTest is BundlerFixture {
    IBundler.Transaction transaction0;
    IBundler.Transaction transaction1;
    IBundler.Transaction[] nodes;
    bool[][] transactionArgsType;

    function setUp() public override {
        super.setUp();

        // NODE 0
        bytes[] memory transaction0Args = new bytes[](1);
        transaction0Args[0] = abi.encode(user0);
        transaction0 = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: 'balanceOf(address)',
            args: transaction0Args
        });

        // NODE 1
        bytes[] memory transaction1Args = new bytes[](1);
        transaction1Args[0] = abi.encode(0);
        transaction1 = IBundler.Transaction({
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

        nodes.push(transaction0);
        nodes.push(transaction1);
    }

    function test_RunBundleWithDynamicArg() public {
        uint256 depositAmount = 10e18;

        vm.startPrank(user0);
        {
            mockToken.transfer(address(bundler), depositAmount);

            // NODE 0
            IBundler.Transaction memory customTransaction0 = IBundler.Transaction({
                target: address(mockToken),
                functionSignature: 'balanceOf(address)',
                args: new bytes[](1)
            });
            customTransaction0.args[0] = abi.encode(address(bundler));

            // NODE 1
            // Get first 32 bytes of balanceOf and fixed param user0
            IBundler.Transaction memory customTransaction1 = IBundler.Transaction({
                target: address(mockToken),
                functionSignature: 'approve(address,uint256)',
                args: new bytes[](2)
            });
            customTransaction1.args[0] = abi.encode(address(mockStake));
            customTransaction1.args[1] = abi.encode(uint8(0));

            // NODE 2
            // Get first 32 bytes of the data returned from balanceOf
            IBundler.Transaction memory customTransaction2 = IBundler.Transaction({
                target: address(mockStake),
                functionSignature: 'deposit(uint256)',
                args: new bytes[](1)
            });
            customTransaction2.args[0] = abi.encode(0); 

            // INITIALIZE NODE ARGS TYPE
            bool[][] memory customTransactionArgsType = new bool[][](4);
            customTransactionArgsType[0] = new bool[](1);
            customTransactionArgsType[1] = new bool[](2);
            customTransactionArgsType[2] = new bool[](1);
            customTransactionArgsType[3] = new bool[](1);

            customTransactionArgsType[0][0] = false;
            customTransactionArgsType[1][0] = false;
            customTransactionArgsType[1][1] =  true;
            customTransactionArgsType[2][0] = false;
            customTransactionArgsType[3][0] = true;

            IBundler.Transaction[] memory transactions = new IBundler.Transaction[](4);
            transactions[0] = customTransaction0;
            transactions[1] = customTransaction1;
            transactions[2] = customTransaction0;
            transactions[3] = customTransaction2;

            bundler.createBundle(transactions, customTransactionArgsType);
            bundler.runBundle();
        }
        vm.stopPrank();

        assertEq(mockStake.balanceOf(address(bundler)), depositAmount);
    }
}
