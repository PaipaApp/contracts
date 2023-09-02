// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

// TODO: how smart contract wallets implement the onlyOwner function

// TODO: consider one contract per Pipe

// TODO: extends Ownable and Pausable

// TODO: all the functions in this contract should be only owner
// How to make {run} functions safe (?)
// => Can it be only public ?
// => What about time sensitve functions
contract Pipe is Ownable {
    using SafeERC20 for IERC20;

    enum Args {
        None,
        Static,
        Dynamic
    }

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    // TODO: HANDLE PAYABLE FUNCTIONS
    // TODO: create args enum => check the gas efficiecy of enums
    // TODO: create node id? id can be shorter than 31 bytes to make sure
    // it is storage efficient => node id serves the purpose of inform the client
    // which node has failed
    struct PipeNode {
        address execution; // TODO: rename to target
        string functionSignature;
        Args argsType;
        bytes fixedArgs;
    }

    PipeNode[] public pipe;

    // TODO: pass bytes result to this function to be able to decode on the frontend
    error PipeNodeError(); 
    error InvalidTarget();

    // TODO: check if all pipe node is args are valid
    function createPipe(PipeNode[] memory _pipeNodes) external onlyOwner {
        // TODO: does it make sense transform this into a linked list?
        // is it possible a linked list in solidity
        for (uint256 i = 0; i < _pipeNodes.length; i++) {
            pipe.push(_pipeNodes[i]);
        }
    }

    // TODO: maybe use some kind of polymorphism to avoid all the ifs
    // TODO: take in consideration time sensitive functions
    // TODO: should it by only owner?
    //      => give option to be only owner or not
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
    function runDynamicNode(
        PipeNode memory pipeNode,
        bytes memory resultLastNode
    ) internal returns (bytes memory) {
        bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);
        bytes memory data = bytes.concat(encodedSignature, resultLastNode);

        (bool success, bytes memory result) = pipeNode.execution.call(data);

        if (!success)
            revert PipeNodeError();
        else
            return result;
    }

    // TODO: SHOULD BE ONLY OWNER!!!!!
    function withdrawERC20(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    // function withdraw721(address _token, uint256 _amount) public {}

    // function withdraw1155(address _token, uint256 _amount) public {}

    function getPipe() external view returns (PipeNode[] memory) {
        return pipe;
    }

    // MUST BE ONLY OWNER
    // @notice Execute an arbitrary transaction in order for this contract to become
    // the owner of a given position in a given contract
    function runTransaction(address target, bytes calldata data) external onlyOwner returns (bytes memory) {
        if (target == address(this))
            revert InvalidTarget();

        (bool success, bytes memory result) = target.call(data);

        if (!success)
            revert PipeNodeError();

        return result;
    }
}
