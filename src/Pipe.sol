// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Pipe {
    struct PipeNode {
        address execution;
        bytes selector;
    }

    // TODO: consider deploying pipes
    mapping(address => PipeNode[][]) pipes;

    // constructor(
    //     address contract0,
    //     bytes memory selector0,
    //     address contract1,
    //     bytes memory selector1
    // ) {
    //     PipeNode memory pipe0 = PipeNode({
    //         execution: contract0,
    //         selector: selector0
    //     });

    //     PipeNode memory pipe1 = PipeNode({
    //         execution: contract1,
    //         selector: selector1
    //     });

    //     pipe.push(pipe0);
    //     pipe.push(pipe1);
    // }

    function createPipe(PipeNode[] memory _pipe) external {
        // uint userPipesLength = pipes[msg.sender].length;
        // PipeNode[] storage pipe = pipes[msg.sender][userPipesLength];

        // for (uint i = 0; i < _pipe.length;) {
            // PipeNode memory node = PipeNode({
            //     execution: _pipe[i].execution,
            //     selector: _pipe[i].selector
            // });

            // pipe.push(node);

            // unchecked {
            //     i++;
            // }
        // }

        // pipes[msg.sender].push(pipe);
    }

    function runPipe(uint pipeId) external {
        PipeNode[] memory pipe = pipes[msg.sender][pipeId];

        for (uint i = 0; i < pipe.length;) {
            runNode(pipe[i]);

            unchecked {
                i++;
            }
        }
    }

    function runNode(PipeNode memory pipeNode) internal {
        (bool success, bytes memory result) = pipeNode.execution.call(pipeNode.selector);
    }
}
