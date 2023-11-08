// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BundlerFixture} from './BundlerFixture.sol';
import {IBundler} from '../../src/interfaces/IBundler.sol';
import {Bundler} from '../../src/Bundler.sol';
import {MockStake, MockToken} from '../mock/MockContracts.sol';
import "forge-std/console.sol";

abstract contract CreateBundleFixture is BundlerFixture {
    IBundler.Transaction transaction0;
    IBundler.Transaction transaction1;
    IBundler.Transaction[] transactions;
    bool[][] transactionArgsType;

    function setUp() public virtual override {
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

        transactions.push(transaction0);
        transactions.push(transaction1);

        vm.startPrank(user0); {
            address user0Bundler = factory.deployBundler(0);

            IBundler(user0Bundler).createBundle(transactions, transactionArgsType);

            mockToken.transfer(user0Bundler, 5e18);

            // Approve
            IBundler(user0Bundler).runTransaction(
                address(mockToken), 
                abi.encodeWithSelector(MockToken.approve.selector, address(mockToken), 5e18)
            );

            // Deposit
            IBundler(user0Bundler).runTransaction(
                address(mockStake), 
                abi.encodeWithSelector(MockStake.deposit.selector, 5e18)
            );
        }
        vm.stopPrank();
    }
}
