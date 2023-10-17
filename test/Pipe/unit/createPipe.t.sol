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

// SPDX-License-Identifier: MTI
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {Pipe} from '../../../src/Pipe.sol';
import {PipeFixture} from "../../fixtures/PipeFixture.sol";

contract CreatePipeTest is PipeFixture {
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

    function test_CreatePipeNodes() public {
        vm.prank(user0);
        pipe.createPipe(nodes, nodeArgsType);

        assertEq(nodes[0].args[0], abi.encode(user0));
        assertEq(nodes[0].functionSignature, 'balanceOf(address)');
        assertEq(nodes[0].target, address(mockStake));

        assertEq(nodes[1].args[0], abi.encode(0));
        assertEq(nodes[1].functionSignature, 'withdraw(uint256)');
        assertEq(nodes[1].target, address(mockStake));
    }

    function test_InitializeBitmapForNodes() public {
        vm.prank(user0);
        pipe.createPipe(nodes, nodeArgsType);

        assertEq(pipe.argTypeIsDynamic(0, 0), false);
        assertEq(pipe.argTypeIsDynamic(1, 0), true);
    }
}
