// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Pipe} from "../../src/Pipe.sol";
import {MockContract0, MockContract1} from "../mock/MockContracts.sol";

contract ContractBTest is Test {
    uint256 testNumber;
    Pipe public pipe;
    MockContract0 public mock0;
    MockContract1 public mock1;

    function setUp() public {
        pipe = new Pipe();
        mock0 = new MockContract0();
        mock1 = new MockContract1();
    }

    /** 
     * Scenario: Cretate pipe
     *      Given Two base transaction without params
     *      When The user calls new pipe 
     *      Then Should create new pipe
     */   
    function test_CreatePipe() public {
        string memory signature0 = 'count()';
        string memory signature1 = 'toggleLock()';

        Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
            execution: address(mock0),
            functionSignature: signature0,
            argsType: Pipe.Args.None,
            fixedArgs: bytes(abi.encode(0))
        });

        Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
            execution: address(mock1),
            functionSignature: signature1,
            argsType: Pipe.Args.None,
            fixedArgs: bytes(abi.encode(0))
        });

        Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
        _pipe[0] = pipeNode0;
        _pipe[1] = pipeNode1;

        pipe.createPipe(_pipe);

        assertEq(address(mock0), pipe.getPipe()[0].execution);
        assertEq(signature0, pipe.getPipe()[0].functionSignature);

        assertEq(address(mock1), pipe.getPipe()[1].execution);
        assertEq(signature1, pipe.getPipe()[1].functionSignature);
    }

    /** 
     * Scenario: Run pipe nodes that doesn't take args
     *      Given Two base transaction without params
     *      When The user calls run pipe 
     *      Then Should run the pipe and execute transactions
     */   
    function test_RunNodesWithoutArgs() public {
        string memory signature0 = 'count()';
        string memory signature1 = 'toggleLock()';

        Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
            execution: address(mock0),
            functionSignature: signature0,
            argsType: Pipe.Args.None,
            fixedArgs: bytes(abi.encode(0))
        });

        Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
            execution: address(mock1),
            functionSignature: signature1,
            argsType: Pipe.Args.None,
            fixedArgs: bytes(abi.encode(0))
        });

        Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
        _pipe[0] = pipeNode0;
        _pipe[1] = pipeNode1;

        pipe.createPipe(_pipe);
        pipe.runPipe();

        assertEq(mock0.getCounter(), 1);
        assertEq(mock1.getLocked(), true);
    }

    /** 
     * Scenario: Run pipe nodes that take fixed params
     *      A base transaction without params
     *      When The user calls run pipe 
     *      Then Should run the pipe and execute the node with a pre defined param
     */   
    function test_RunPipeWithStaticArgs() public {
        string memory signature0 = "increment(uint256)";
        uint amount = 10;

        Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
            execution: address(mock0),
            functionSignature: signature0,
            argsType: Pipe.Args.Static,
            fixedArgs: bytes(abi.encode(amount))
        });

        Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](1);
        _pipe[0] = pipeNode0;

        pipe.createPipe(_pipe);
        pipe.runPipe();

        assertEq(mock0.getCounter(), amount);
    }

    /** 
     * Scenario: Run pipe nodes passing params from previous function
     *      Given A base transaction and a pipe transaction
     *      When The user calls run pipe 
     *      Then Should run the first function, and use its return value as the input of the next tx
     */   
    function test_RunPipeWithDynamicArgs() public {
        string memory signature0 = "getNumber()";
        string memory signature1 = "increment(uint256)";

        Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
            execution: address(mock1),
            functionSignature: signature0,
            argsType: Pipe.Args.None,
            fixedArgs: bytes(abi.encodePacked(uint8(0)))
        });

        Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
            execution: address(mock0),
            functionSignature: signature1,
            argsType: Pipe.Args.Dynamic,
            fixedArgs: bytes(abi.encodePacked(uint8(0)))
        });

        Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
        _pipe[0] = pipeNode0;
        _pipe[1] = pipeNode1;

        pipe.createPipe(_pipe);
        pipe.runPipe();

        assertEq(mock1.getNumber(), mock0.getCounter());
    }

    /** 
     * Scenario: Run pipe nodes passing params from previous function
     *      Given A transaction that contains token transfer
     *      When The user calls run pipe 
     *      Then Should run the first function, and use its return value as the input of the next tx
     */   
     function test_RunPipeWithTokenTransfer() public {

     }
}
