// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BaseFixture} from "./BaseFixture.sol";
import {IBundler} from "../../src/interfaces/IBundler.sol";
import {Bundler} from "../../src/Bundler.sol";
import {MockStake, MockToken} from "../mock/MockContracts.sol";
import "forge-std/console.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract CreateBundleFixture is BaseFixture {
    IBundler.Transaction transaction0;
    IBundler.Transaction transaction1;
    IBundler.Transaction[] transactions;
    bool[][] transactionArgsType;

    function setUp() public virtual override {
        super.setUp();

        _createBundler(user0);
        _initializeTransactions(user0);

        _createBundler(user1);
        _initializeTransactions(user1);
    }

    function _initializeTransactions(address _user) internal {
        // BalanceOf
        bytes[] memory transaction0Args = new bytes[](1);
        transaction0Args[0] = abi.encode(_user);
        transaction0 = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "stakeBalance(address)",
            args: transaction0Args
        });

        // Withdraw
        bytes[] memory transaction1Args = new bytes[](1);
        transaction1Args[0] = abi.encode(0);
        transaction1 = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "withdraw(uint256)",
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

    function _createBundler(address _user) internal {
        uint256 tokenAmount = 5e18;

        vm.startPrank(_user);
        {
            address userBundler = factory.deployBundler(0);

            IBundler(userBundler).createBundle(transactions, transactionArgsType);

            mockToken.transfer(userBundler, tokenAmount);

            // Approve
            IBundler(userBundler).runTransaction(
                address(mockToken), abi.encodeWithSelector(IERC20.approve.selector, address(mockStake), tokenAmount)
            );

            // Deposit
            IBundler(userBundler).runTransaction(
                address(mockStake), abi.encodeWithSelector(MockStake.deposit.selector, tokenAmount)
            );
        }
        vm.stopPrank();
    }
}
