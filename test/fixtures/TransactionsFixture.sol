// SPDX-License-Identifier: MTI
pragma solidity ^0.8.22;

import {BaseFixture} from "./BaseFixture.sol";
import {IBundler} from "../../src/interfaces/IBundler.sol";
import "forge-std/console.sol";

enum TransactionType {
    STATIC,
    DYNAMIC
}

enum TransactionName {
    BALANCE_OF,
    WITHDRAW,
    DEPOSIT,
    APPROVE
}

contract TransactionsFixture is BaseFixture {
    struct TransactionData {
        IBundler.Transaction tx;
        bool[] txArgTypes;
    }

    mapping(TransactionType => mapping(TransactionName => TransactionData)) public transactions;

    function setUp() public virtual override {
        super.setUp();
        _createStaticTransactions();
        _createDynamicTransactions();
    }

    function _createStaticTransactions() internal {
        // BALANCE OF
        bytes[] memory balanceOfArgs = new bytes[](1);
        balanceOfArgs[0] = abi.encode(user0);
        IBundler.Transaction memory balanceOf = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "balanceOf(address)",
            args: balanceOfArgs
        });
        bool[] memory balanceOfArgTypes = new bool[](1);
        balanceOfArgTypes[0] = false;

        transactions[TransactionType.STATIC][TransactionName.BALANCE_OF] =
            TransactionData({tx: balanceOf, txArgTypes: balanceOfArgTypes});

        // WITHDRAW
        bytes[] memory withdrawArgs = new bytes[](1);
        withdrawArgs[0] = abi.encode(5e18);
        IBundler.Transaction memory withdraw = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "withdraw(uint256)",
            args: withdrawArgs
        });
        bool[] memory withdrawArgTypes = new bool[](1);
        withdrawArgTypes[0] = false;

        transactions[TransactionType.STATIC][TransactionName.WITHDRAW] =
            TransactionData({tx: withdraw, txArgTypes: withdrawArgTypes});
    }

    function _createDynamicTransactions() internal {
        // BALANCE OF
        bytes[] memory balanceOfArgs = new bytes[](1);
        balanceOfArgs[0] = abi.encode(0);
        IBundler.Transaction memory balanceOf = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "balanceOf(address)",
            args: balanceOfArgs
        });
        bool[] memory balanceOfArgTypes = new bool[](1);
        balanceOfArgTypes[0] = true;

        transactions[TransactionType.DYNAMIC][TransactionName.BALANCE_OF] =
            TransactionData({tx: balanceOf, txArgTypes: balanceOfArgTypes});

        // WITHDRAW
        bytes[] memory withdrawArgs = new bytes[](1);
        withdrawArgs[0] = abi.encode(0);
        IBundler.Transaction memory withdraw = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "withdraw(uint256)",
            args: withdrawArgs
        });
        bool[] memory withdrawArgTypes = new bool[](1);
        withdrawArgTypes[0] = true;

        transactions[TransactionType.DYNAMIC][TransactionName.WITHDRAW] =
            TransactionData({tx: withdraw, txArgTypes: withdrawArgTypes});
    }
}
