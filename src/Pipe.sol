// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

// TODO: consider one contract per Pipe
// TODO: extends Ownable and Pausable
contract Pipe {
    enum Args {
        None,
        Static,
        Dynamic
    }

    // TODO: create args enum => check the gas efficiecy of enums
    // TODO: create node id? id can be shorter than 31 bytes to make sure
    // it is storage efficient => node id serves the purpose of inform the client
    // which node has failed
    struct PipeNode {
        address execution;
        string functionSignature;
        Args argsType;
        bytes fixedArgs;
    }

    PipeNode[] public pipe;

    error PipeNodeError();

    function createPipe(PipeNode[] memory _pipeNodes) external {
        // TODO: does it make sense transform this into a linked list?
        // is it possible a linked list in solidity
        for (uint256 i = 0; i < _pipeNodes.length; i++) {
            pipe.push(_pipeNodes[i]);
        }
    }

    // TODO: maybe use some kind of polymorphism to avoid all the ifs
    function runPipe() external {
        bytes memory lastNodeResult;

        for (uint i = 0; i < pipe.length;) {
            // TODO: make pipe[i] local variable
            lastNodeResult = pipe[i].argsType == Args.Dynamic
                ? runDynamicNode(pipe[i], lastNodeResult) 
                : runNode(pipe[i]);

            unchecked {
                i++;
            }
        }
    }

    // TODO: unify into a single run function ?
    function runNode(PipeNode memory pipeNode) internal returns (bytes memory) {
        bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);

        bytes memory data = pipeNode.argsType == Args.Static
            ? bytes.concat(encodedSignature, pipeNode.fixedArgs)
            : encodedSignature;

        (bool success, bytes memory result) = pipeNode.execution.call(data);

        if (!success)
            revert PipeNodeError();
        else
            return result;
    }

    // TODO: unify into a single run function ?
    function runDynamicNode(PipeNode memory pipeNode, bytes memory resultLastNode) internal returns (bytes memory) {
        bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);
        bytes memory data = bytes.concat(encodedSignature, resultLastNode);

        (bool success, bytes memory result) = pipeNode.execution.call(data);

        if (!success)
            revert PipeNodeError();
        else
            return result;
    }

    function getPipe() external view returns (PipeNode[] memory) {
        return pipe;
    }
}
