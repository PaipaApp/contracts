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

// Current cov: 75.00% (33/44) | 77.36% (41/53) | 56.25% (9/16)  | 55.56% (5/9)
//              77.27% (34/44) | 79.25% (42/53) | 62.50% (10/16) | 55.56% (5/9)
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

    function test_OverridePipeWithNewNodes() public {
        bytes[] memory customNodeArgs = new bytes[](1);
        customNodeArgs[0] = abi.encode(0);
        Pipe.PipeNode memory customNode = Pipe.PipeNode({
            target: address(3),
            functionSignature: 'customNode(uint256)',
            args: customNodeArgs
        });

        bool[][] memory customNodeArgsType = new bool[][](1);
        customNodeArgsType[0] = new bool[](1);
        customNodeArgsType[0][0] = false;

        Pipe.PipeNode[] memory customPipe = new Pipe.PipeNode[](1);
        customPipe[0] = customNode;

        vm.startPrank(user0);
        {
            // Create first pipe
            pipe.createPipe(nodes, nodeArgsType);
            // Overrides the last createPipe call
            pipe.createPipe(customPipe, customNodeArgsType);
        }
        vm.stopPrank();

        Pipe.PipeNode[] memory pipeNodes = pipe.getPipe();

        assertEq(pipeNodes.length, 1);
        assertEq(pipeNodes[0].functionSignature, 'customNode(uint256)');
        assertEq(pipeNodes[0].target, address(3));
        assertEq0(pipeNodes[0].args[0], abi.encode(0));
    }

    function test_RevertWhenArgsNotSameLength() public {
        bool[][] memory customNodeArgsType = new bool[][](0);

        vm.expectRevert(Pipe.ArgsMismatch.selector);
        vm.prank(user0);
        pipe.createPipe(nodes, customNodeArgsType);
    }

    function test_RevertWhenArgsContentNotSameLength() public {
        bool[][] memory customNodeArgsType = new bool[][](2);
        customNodeArgsType[0] = new bool[](1);
        // @dev this lines causes the mismatch, since the arg type length is 0
        customNodeArgsType[1] = new bool[](0);
        customNodeArgsType[0][0] = false;

        vm.expectRevert(Pipe.ArgsMismatch.selector);
        vm.prank(user0);
        pipe.createPipe(nodes, customNodeArgsType);
    }

    function test_RevertIfInvalidTarget() public {
        nodes[0].target = address(0);

        vm.expectRevert(Pipe.InvalidTarget.selector);
        vm.prank(user0);
        pipe.createPipe(nodes, nodeArgsType);
    }
}
