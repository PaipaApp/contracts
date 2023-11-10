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
    // MockToken
    BALANCE_OF,
    APPROVE,

    // MockStake
    STAKE_BALANCE,
    WITHDRAW,
    DEPOSIT
}

contract TransactionsFixture is BaseFixture {
    uint256 public constant defaultTokenAmount = 5e18;

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
        // STAKE BALANCE
        bytes[] memory stakeBalanceArgs = new bytes[](1);
        stakeBalanceArgs[0] = abi.encode(user0);
        IBundler.Transaction memory stakeBalance = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "stakeBalance(address)",
            args: stakeBalanceArgs
        });
        bool[] memory stakeBalanceArgTypes = new bool[](1);
        stakeBalanceArgTypes[0] = false;

        transactions[TransactionType.STATIC][TransactionName.STAKE_BALANCE] =
            TransactionData({tx: stakeBalance, txArgTypes: stakeBalanceArgTypes});

        // BALANCE OF
        bytes[] memory balanceOfArgs = new bytes[](1);
        balanceOfArgs[0] = abi.encode(user0);
        IBundler.Transaction memory balanceOf = IBundler.Transaction({
            target: address(mockToken),
            functionSignature: "balanceOf(address)",
            args: balanceOfArgs
        });
        bool[] memory balanceOfArgTypes = new bool[](1);
        balanceOfArgTypes[0] = false;

        transactions[TransactionType.STATIC][TransactionName.BALANCE_OF] =
            TransactionData({tx: balanceOf, txArgTypes: balanceOfArgTypes});

        // WITHDRAW
        bytes[] memory withdrawArgs = new bytes[](1);
        withdrawArgs[0] = abi.encode(defaultTokenAmount);
        IBundler.Transaction memory withdraw = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "withdraw(uint256)",
            args: withdrawArgs
        });
        bool[] memory withdrawArgTypes = new bool[](1);
        withdrawArgTypes[0] = false;

        transactions[TransactionType.STATIC][TransactionName.WITHDRAW] =
            TransactionData({tx: withdraw, txArgTypes: withdrawArgTypes});

        // APPROVE
        bytes[] memory approveArgs = new bytes[](2);
        approveArgs[0] = abi.encode(address(mockStake));
        approveArgs[1] = abi.encode(defaultTokenAmount);
        IBundler.Transaction memory approve = IBundler.Transaction({
            target: address(mockToken),
            functionSignature: "approve(address,uint256)",
            args: approveArgs
        });
        bool[] memory approveArgTypes = new bool[](2);
        approveArgTypes[0] = false;
        approveArgTypes[1] = false;

        transactions[TransactionType.STATIC][TransactionName.APPROVE] =
            TransactionData({tx: approve, txArgTypes: approveArgTypes});

        // DEPOSIT
        bytes[] memory depositArgs = new bytes[](1);
        depositArgs[0] = abi.encode(defaultTokenAmount);
        IBundler.Transaction memory deposit =
            IBundler.Transaction({target: address(mockStake), functionSignature: "deposit(uint256)", args: depositArgs});
        bool[] memory depositArgTypes = new bool[](1);
        depositArgTypes[0] = false;

        transactions[TransactionType.STATIC][TransactionName.DEPOSIT] =
            TransactionData({tx: deposit, txArgTypes: depositArgTypes});
    }

    function _createDynamicTransactions() internal {
        // STAKE BALANCE
        bytes[] memory stakeBalanceArgs = new bytes[](1);
        stakeBalanceArgs[0] = abi.encode(mockStake);
        IBundler.Transaction memory stakeBalance = IBundler.Transaction({
            target: address(mockStake),
            functionSignature: "stakeBalance(address)",
            args: stakeBalanceArgs
        });
        bool[] memory stakeBalanceArgTypes = new bool[](1);
        stakeBalanceArgTypes[0] = true;

        transactions[TransactionType.DYNAMIC][TransactionName.STAKE_BALANCE] =
            TransactionData({tx: stakeBalance, txArgTypes: stakeBalanceArgTypes});

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

        // APPROVE
        bytes[] memory approveArgs = new bytes[](2);
        approveArgs[0] = abi.encode(0);
        approveArgs[1] = abi.encode(0);
        IBundler.Transaction memory approve = IBundler.Transaction({
            target: address(mockToken),
            functionSignature: "approve(address,uint256)",
            args: approveArgs
        });
        bool[] memory approveArgTypes = new bool[](2);
        approveArgTypes[0] = true;
        approveArgTypes[1] = true;

        transactions[TransactionType.DYNAMIC][TransactionName.APPROVE] =
            TransactionData({tx: approve, txArgTypes: approveArgTypes});

        // DEPOSIT
        bytes[] memory depositArgs = new bytes[](1);
        depositArgs[0] = abi.encode(0);
        IBundler.Transaction memory deposit =
            IBundler.Transaction({target: address(mockStake), functionSignature: "deposit(uint256)", args: depositArgs});
        bool[] memory depositArgTypes = new bool[](1);
        depositArgTypes[0] = true;

        transactions[TransactionType.DYNAMIC][TransactionName.DEPOSIT] =
            TransactionData({tx: deposit, txArgTypes: depositArgTypes});
    }
}
