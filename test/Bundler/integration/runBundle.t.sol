// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {BundlerFixture} from '../../fixtures/BundlerFixture.sol';

contract RunBundlerTest is BundlerFixture {
    Bundler.Transaction transaction0;
    Bundler.Transaction transaction1;
    Bundler.Transaction[] nodes;
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

        nodes.push(transaction0);
        nodes.push(transaction1);
    }

    function test_RunNodeWithDynamicArg() public {
        uint256 depositAmount = 10e18;

        vm.startPrank(user0);
        {
            mockToken.transfer(address(bundler), depositAmount);

            // NODE 0
            bytes[] memory transaction0Args = new bytes[](1);
            transaction0Args[0] = abi.encode(address(bundler));
            Bundler.Transaction memory transaction0 = Bundler.Transaction({
                target: address(mockToken),
                functionSignature: 'balanceOf(address)',
                args: transaction0Args
            });

            // NODE 1
            bytes[] memory transaction1Args = new bytes[](2);
            // Get first 32 bytes of balanceOf and fixed param user0
            transaction1Args[0] = abi.encode(address(mockStake));
            transaction1Args[1] = abi.encode(uint8(0));
            Bundler.Transaction memory transaction1 = Bundler.Transaction({
                target: address(mockToken),
                functionSignature: 'approve(address,uint256)',
                args: transaction1Args
            });

            // NODE 2
            bytes[] memory transaction2Args = new bytes[](1);
            // Get first 32 bytes of the data returned from balanceOf
            transaction2Args[0] = abi.encode(0); 
            Bundler.Transaction memory transaction2 = Bundler.Transaction({
                target: address(mockStake),
                functionSignature: 'deposit(uint256)',
                args: transaction2Args
            });

            // INITIALIZE NODE ARGS TYPE
            bool[][] memory transactionArgsType = new bool[][](4);
            transactionArgsType[0] = new bool[](1);
            transactionArgsType[1] = new bool[](2);
            transactionArgsType[2] = new bool[](1);
            transactionArgsType[3] = new bool[](1);

            transactionArgsType[0][0] = false;
            transactionArgsType[1][0] = false;
            transactionArgsType[1][1] =  true;
            transactionArgsType[2][0] = false;
            transactionArgsType[3][0] = true;

            Bundler.Transaction[] memory transactions = new Bundler.Transaction[](4);
            transactions[0] = transaction0;
            transactions[1] = transaction1;
            transactions[2] = transaction0;
            transactions[3] = transaction2;

            bundler.createBundle(transactions, transactionArgsType);
            bundler.runBundle();
        }
        vm.stopPrank();

        assertEq(mockStake.balanceOf(address(bundler)), depositAmount);
    }
}
