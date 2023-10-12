//
//       ███████████             ███                     
//      ░░███░░░░░███           ░░░                      
//       ░███    ░███  ██████   ████  ████████   ██████  
//       ░██████████  ░░░░░███ ░░███ ░░███░░███ ░░░░░███ 
//       ░███░░░░░░    ███████  ░███  ░███ ░███  ███████ 
//       ░███         ███░░███  ░███  ░███ ░███ ███░░███ 
//       █████       ░░████████ █████ ░███████ ░░████████
//      ░░░░░         ░░░░░░░░ ░░░░░  ░███░░░   ░░░░░░░░ 
//                                    ░███               
//                                    █████              
//                                   ░░░░░         

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Pipe} from "../../../src/Pipe.sol";
import {PipeFixture} from '../../fixtures/PipeFixture.sol';

contract PipeUnitTest is PipeFixture {
    Pipe.PipeNode pipeNode0;
    Pipe.PipeNode pipeNode1;
    Pipe.PipeNode[] nodes;
    bool[][] nodeArgsType;

    function setUp() public override {
        super.setUp();

        // NODE 0
        bytes[] memory node0Args = new bytes[](1);
        node0Args[0] = abi.encode(user0);
        pipeNode0 = Pipe.PipeNode({
            target: address(mockStake),
            functionSignature: 'balanceOf(address)',
            args: node0Args
        });

        // NODE 1
        bytes[] memory node1Args = new bytes[](1);
        node1Args[0] = abi.encode(0);
        pipeNode1 = Pipe.PipeNode({
            target: address(mockStake),
            functionSignature: 'withdraw(uint256)',
            args: node1Args
        });

        // INITIALIZE NODE ARGS TYPE
        nodeArgsType = new bool[][](2);

        nodeArgsType[0] = new bool[](1);
        nodeArgsType[1] = new bool[](1);

        nodeArgsType[0][0] = false;
        nodeArgsType[1][0] = true;

        nodes.push(pipeNode0);
        nodes.push(pipeNode1);
    }

    // TODO: move this to a lib
    // TODO: test fail test cases
    function test_GetAbiSlice() public {
        bytes memory mockAbi = abi.encode(uint(32), uint8(64), uint8(96));

        assertEq(
            bytes32(uint(32)),
            pipe.getSlice(mockAbi, 0)
        );

        assertEq(
            bytes32(uint(64)),
            pipe.getSlice(mockAbi, 1)
        );

        assertEq(
            bytes32(uint(96)),
            pipe.getSlice(mockAbi, 2)
        );
    }

    // TODO: write tests for all combinations of Pipes
    // Fixed => Dynamic => None
    // None => Fixed => Dynamic
    // None => None => Dynamic
    // Fixed => Dynamic => None
    // Fixed => Dynamic => Dynamic
    // Fixed => Fixed => Fixed
    // ETC
    function test_RunNodeWithDynamicArg() public {
        uint256 depositAmount = 10e18;

        vm.startPrank(user0);
        {
            mockToken.transfer(address(pipe), depositAmount);

            // NODE 0
            bytes[] memory node0Args = new bytes[](1);
            node0Args[0] = abi.encode(address(pipe));
            Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
                target: address(mockToken),
                functionSignature: 'balanceOf(address)',
                args: node0Args
            });

            // NODE 1
            bytes[] memory node1Args = new bytes[](2);
            // Get first 32 bytes of balanceOf and fixed param user0
            node1Args[0] = abi.encode(address(mockStake));
            node1Args[1] = abi.encode(uint8(0));
            Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
                target: address(mockToken),
                functionSignature: 'approve(address,uint256)',
                args: node1Args
            });

            // NODE 2
            bytes[] memory node2Args = new bytes[](1);
            // Get first 32 bytes of the data returned from balanceOf
            node2Args[0] = abi.encode(0); 
            Pipe.PipeNode memory pipeNode2 = Pipe.PipeNode({
                target: address(mockStake),
                functionSignature: 'deposit(uint256)',
                args: node2Args
            });

            // INITIALIZE NODE ARGS TYPE
            bool[][] memory nodeArgsType = new bool[][](4);
            nodeArgsType[0] = new bool[](1);
            nodeArgsType[1] = new bool[](2);
            nodeArgsType[2] = new bool[](1);
            nodeArgsType[3] = new bool[](1);

            nodeArgsType[0][0] = false;
            nodeArgsType[1][0] = false;
            nodeArgsType[1][1] =  true;
            nodeArgsType[2][0] = false;
            nodeArgsType[3][0] = true;

            Pipe.PipeNode[] memory pipeNodes = new Pipe.PipeNode[](4);
            pipeNodes[0] = pipeNode0;
            pipeNodes[1] = pipeNode1;
            pipeNodes[2] = pipeNode0;
            pipeNodes[3] = pipeNode2;

            pipe.createPipe(pipeNodes, nodeArgsType);
            pipe.runPipe();
        }
        vm.stopPrank();

        assertEq(mockStake.balanceOf(address(pipe)), depositAmount);
    }

    // /** 
    //  * Scenario: Cretate pipe
    //  *      Given Two base transaction without params
    //  *      When The user calls new pipe 
    //  *      Then Should create new pipe
    //  */   
    // function test_CreatePipe() public {
    //     string memory signature0 = 'count()';
    //     string memory signature1 = 'toggleLock()';

    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mock0),
    //         functionSignature: signature0,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
    //         target: address(mock1),
    //         functionSignature: signature1,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
    //     _pipe[0] = pipeNode0;
    //     _pipe[1] = pipeNode1;

    //     pipe.createPipe(_pipe);

    //     assertEq(address(mock0), pipe.getPipe()[0].target);
    //     assertEq(signature0, pipe.getPipe()[0].functionSignature);

    //     assertEq(address(mock1), pipe.getPipe()[1].target);
    //     assertEq(signature1, pipe.getPipe()[1].functionSignature);
    // }

    // /** 
    //  * Scenario: Override pipe with new nodes
    //  *      Given A Pipe with pipe nodes initialized
    //  *      When A user calls the create function
    //  *      Then Should override the current pipe with new nodes
    //  */   
    // function test_OverridePipe() public {
    //     string memory signature0 = 'count()';
    //     string memory signature1 = 'toggleLock()';

    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mock0),
    //         functionSignature: signature0,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
    //         target: address(mock1),
    //         functionSignature: signature1,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](1);
    //     _pipe[0] = pipeNode0;

    //     pipe.createPipe(_pipe);

    //     _pipe[0] = pipeNode1;
    //     pipe.createPipe(_pipe);

    //     assertEq(pipe.getPipe().length, 1);
    //     assertEq(address(mock1), pipe.getPipe()[0].target);
    //     assertEq(signature1, pipe.getPipe()[0].functionSignature);
    // }

    // /** 
    //  * Scenario: Revert creation if target is zero address
    //  *      Given A pipe with target address equals to zero
    //  *      Then The transaction should revert with invalid target
    //  */   
    // function test_RevertOnCreationWhenInvalidTarget() public {
    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mock0),
    //         functionSignature: 'count()',
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](1);
    //     _pipe[0] = pipeNode0;

    //     vm.expectRevert(Pipe.InvalidTarget.selector);
    //     pipe.createPipe(_pipe);
    // }

    // /** 
    //  * Scenario: Run pipe nodes that doesn't take args
    //  *      Given Two base transaction without params
    //  *      When The user calls run pipe 
    //  *      Then Should run the pipe and execute transactions
    //  */   
    // function test_RunNodesWithoutArgs() public {
    //     string memory signature0 = 'count()';
    //     string memory signature1 = 'toggleLock()';

    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mock0),
    //         functionSignature: signature0,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
    //         target: address(mock1),
    //         functionSignature: signature1,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(0)
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
    //     _pipe[0] = pipeNode0;
    //     _pipe[1] = pipeNode1;

    //     pipe.createPipe(_pipe);
    //     pipe.runPipe();

    //     assertEq(mock0.getCounter(), 1);
    //     assertEq(mock1.getLocked(), true);
    // }

    // /** 
    //  * Scenario: Run pipe nodes that take fixed params
    //  *      A base transaction without params
    //  *      When The user calls run pipe 
    //  *      Then Should run the pipe and execute the node with a pre defined param
    //  */   
    // function test_RunPipeWithStaticArgs() public {
    //     string memory signature0 = "increment(uint256)";
    //     uint amount = 10;

    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mock0),
    //         functionSignature: signature0,
    //         argsType: Pipe.Args.Static,
    //         fixedArgs: abi.encode(amount)
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](1);
    //     _pipe[0] = pipeNode0;

    //     pipe.createPipe(_pipe);
    //     pipe.runPipe();

    //     assertEq(mock0.getCounter(), amount);
    // }

    // /** 
    //  * Scenario: Run pipe nodes passing params from previous function
    //  *      Given A base transaction and a pipe transaction
    //  *      When The user calls run pipe 
    //  *      Then Should run the first function, and use its return value as the input of the next tx
    //  */   
    // function test_RunPipeWithDynamicArgs() public {
    //     string memory signature0 = "getNumber()";
    //     string memory signature1 = "increment(uint256)";

    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mock1),
    //         functionSignature: signature0,
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
    //         target: address(mock0),
    //         functionSignature: signature1,
    //         argsType: Pipe.Args.Dynamic,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
    //     _pipe[0] = pipeNode0;
    //     _pipe[1] = pipeNode1;

    //     pipe.createPipe(_pipe);
    //     pipe.runPipe();

    //     assertEq(mock1.getNumber(), mock0.getCounter());
    // }

    // /** 
    //  * Scenario: Run pipe nodes where one of the transactions contains a token transfer
    //  *      Given A transaction that contains token transfer
    //  *      When The user calls run pipe 
    //  *      Then It should execute the transfer between the contracts
    //  */   
    // function test_RunPipeWithTokenTransfer() public {
    //     uint256 pipeStakeBalanceBefore = mockStake.balanceOf(address(pipe)); // TODO: Invariant test for depositor

    //     // User creates a position in a contract
    //     vm.prank(address(1));
    //     uint256 depositAmount = mockToken.balanceOf(address(1));
    //     mockToken.transfer(address(pipe), depositAmount);

    //     pipe.runTransaction(
    //         address(mockToken),
    //         abi.encodeWithSignature("approve(address,uint256)", address(mockStake), 100e18)
    //     );

    //     pipe.runTransaction(
    //         address(mockStake),
    //         abi.encodeWithSignature('deposit(uint256)', depositAmount)
    //     );

    //     // User Creates a pipeline
    //     // collect rewards => check balance => deposit balance into the contract
    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mockStake),
    //         functionSignature: "collectRewards()",
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
    //         target: address(mockToken),
    //         functionSignature: 'balanceOf(address)',
    //         argsType: Pipe.Args.Static,
    //         fixedArgs: abi.encode(address(pipe))
    //     });

    //     Pipe.PipeNode memory pipeNode2 = Pipe.PipeNode({
    //         target: address(mockStake),
    //         functionSignature: 'deposit(uint256)',
    //         argsType: Pipe.Args.Dynamic,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](3);
    //     _pipe[0] = pipeNode0;
    //     _pipe[1] = pipeNode1;
    //     _pipe[2] = pipeNode2;

    //     pipe.createPipe(_pipe);
    //     pipe.runPipe();

    //     uint256 pipeStakeBalanceAfter = mockStake.balanceOf(address(pipe)) - pipeStakeBalanceBefore;

    //     assertEq(pipeStakeBalanceAfter, depositAmount + depositAmount * 100 / 10_000);
    // }

    // /** 
    //  * Scenario: A pipe being ran, but user is not owner of the position
    //  *      Given A transaction that contains token transfer
    //  *      When The user calls run pipe 
    //  *      Then It should revert with PipeNodeError
    //  */   
    // function test_RevertPipeWhenContractNotOwner() public {
    //     // User creates a position in a contract
    //     vm.prank(address(1));
    //     uint256 depositAmount = mockToken.balanceOf(address(1));
    //     mockToken.approve(address(mockStake), depositAmount);
    //     mockStake.deposit(depositAmount);

    //     // User Creates a pipeline
    //     // collect rewards => check balance => deposit balance into the contract
    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mockStake),
    //         functionSignature: "collectRewards()",
    //         argsType: Pipe.Args.None,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
    //         target: address(mockToken),
    //         functionSignature: 'balanceOf(address)',
    //         argsType: Pipe.Args.Static,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode memory pipeNode2 = Pipe.PipeNode({
    //         target: address(mockStake),
    //         functionSignature: 'deposit(uint256)',
    //         argsType: Pipe.Args.Static,
    //         fixedArgs: abi.encode(uint8(0))
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](3);
    //     _pipe[0] = pipeNode0;
    //     _pipe[1] = pipeNode1;
    //     _pipe[2] = pipeNode2;

    //     pipe.createPipe(_pipe);

    //     vm.expectRevert(Pipe.PipeNodeError.selector);
    //     pipe.runPipe();
    // }

    // /** 
    //  * Scenario: A pipe being ran before execution interval
    //  *      Given A pipe contract that defines an execution interval greater than zero
    //  *      When The user calls run pipe twice in a row
    //  *      Then It should revert with ExecutionBeforeInterval
    //  */   
    // function test_RevertIfPipeExecutedBeforeInterval() public {
    //     pipe.setExecutionInterval(1 days);

    //     Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
    //         target: address(mockToken),
    //         functionSignature: 'balanceOf(address)',
    //         argsType: Pipe.Args.Static,
    //         fixedArgs: abi.encode(address(pipe))
    //     });

    //     Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](1);
    //     _pipe[0] = pipeNode0;

    //     pipe.createPipe(_pipe);
    //     pipe.runPipe();

    //     vm.expectRevert(Pipe.ExecutionBeforeInterval.selector);
    //     pipe.runPipe();
    // }

    // function test_RunPipeWithPayableFunction() public {}
}
