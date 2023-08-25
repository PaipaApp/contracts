// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Pipe} from "../../src/Pipe.sol";
import {MockContract0, MockContract1} from "../mock/MockContracts.sol";

contract ContractBTest is Test {
    uint256 testNumber;
    Pipe public pipe;
    MockContract0 public mock0;
    MockContract1 public mock1;

    function setUp() public {
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
        bytes memory signature0 = abi.encodeWithSignature('count()');
        bytes memory signature1 = abi.encodeWithSignature('toggleLock()');

        Pipe.PipeNode memory pipeNode0 = Pipe.PipeNode({
            execution: address(mock0),
            selector: signature0
        });

        Pipe.PipeNode memory pipeNode1 = Pipe.PipeNode({
            execution: address(mock1),
            selector: signature1
        });

        Pipe.PipeNode[] memory _pipe = new Pipe.PipeNode[](2);
        _pipe[0] = pipeNode0;
        _pipe[1] = pipeNode1;

        pipe.createPipe(_pipe);
    }

    /** 
     * Scenario: Run pipe
     *      Given Two base transaction without params
     *      When The user calls run pipe 
     *      Then Should run the pipe
     */   
    // function test_RunPipe() public {
        // TODO: wont pass, need to create pipe first

        // pipe.runPipe(0);

        // assertEq(mock0.getCounter(), 1);
        // assertEq(mock1.getLocked(), true);
    // }
}
