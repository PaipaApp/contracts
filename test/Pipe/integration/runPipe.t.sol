/**
       ███████████             ███                     
      ░░███░░░░░███           ░░░                      
       ░███    ░███  ██████   ████  ████████   ██████  
       ░██████████  ░░░░░███ ░░███ ░░███░░███ ░░░░░███ 
       ░███░░░░░░    ███████  ░███  ░███ ░███  ███████ 
       ░███         ███░░███  ░███  ░███ ░███ ███░░███ 
       █████       ░░████████ █████ ░███████ ░░████████
      ░░░░░         ░░░░░░░░ ░░░░░  ░███░░░   ░░░░░░░░ 
                                    ░███               
                                    █████              
                                   ░░░░░         
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Pipe} from "../../../src/Pipe.sol";
import {PipeFixture} from '../../fixtures/PipeFixture.sol';

contract RunPipeTest is PipeFixture {
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
}
