// SPDX-License-Identifier: MTI
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";
import {BitMaps} from "openzeppelin-contracts/contracts/utils/structs/BitMaps.sol";

// TODO: how reentrancy can affect execution

// TODO: how to work with ERC721 and ERC1155 approvals
// @dev this contract doesn't support ERC1155 transactions nor payable transactions
// TODO: maybe convert the contract to support multiple pipes (?)
contract Pipe is Ownable, Pausable {
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    enum Args {
        None,
        Static,
        Dynamic
    }

    constructor(address _owner, uint256 _executionInterval) {
        executionInterval = _executionInterval;

        transferOwnership(_owner);
    }

    // TODO: variable packing
    struct PipeNode {
        address target;
        string functionSignature;
        bytes32[] args;
    }

    // TODO: how to use only Bitmaps for this
    // @dev Node ID => BitMap
    mapping(uint256 => BitMaps.BitMap) private argsBitmap;

    PipeNode[] public pipeNodes;
    uint256 lastExecutionTimestamp;
    uint256 executionInterval;

    error PipeNodeError(uint256 nodeId, bytes result); 
    error InvalidTarget();
    error ExecutionBeforeInterval();
    error TransactionError(bytes result);
    error ArgsMismatch();
    error InvalidDataOffset();

    function createPipe(
        PipeNode[] memory _pipeNodes,
        bool[][] calldata argTypes
    ) external onlyOwner {
        PipeNode[] storage nodes = pipeNodes;

        if (argTypes.length != _pipeNodes.length)
            revert ArgsMismatch();

        // @dev In order to override the current nodes
        if (nodes.length > 0)
            // TODO: calling delete on a dynamic array in storage sets the array
            // lenght to zero, but doesn't free the slots used by the array items
            // so this is maybe a problem
            delete pipeNodes;

        for (uint256 i = 0; i < _pipeNodes.length;) {
            PipeNode memory node = _pipeNodes[i];
            bool[] memory argType = argTypes[i];

            if (argType.length != node.args.length)
                revert ArgsMismatch();

            if (node.target == address(0))
                revert InvalidTarget();

            for (uint j = 0; j < node.args.length;) {
                argsBitmap[i].setTo(j, argType[j]);

                unchecked {
                    j++;
                }
            }

            nodes.push(node);

            unchecked {
                i++;
            }
        }
    }

    function run() external onlyOwner {

    }

    function getPipe() external view returns (PipeNode[] memory) {
        return pipeNodes;
    }

    function argTypeIsDynamic(uint nodeId, uint argId) external view returns (bool) {
        return argsBitmap[nodeId].get(argId);
    }

    // TODO: time guard
    function runPipe() external onlyOwner whenPaused {
        bytes memory lastNodeResult;

        for (uint8 i; i < pipeNodes.length;)  {
            PipeNode memory node = pipeNodes[i];

            bytes memory data = buildData(i, node, lastNodeResult);

            (bool success, bytes memory result) = node.target.call(data);

            if (!success)
                revert TransactionError(result);

            lastNodeResult = result;

            unchecked {
                i++;
            }
        }
    }

    function buildData(uint _nodeId, PipeNode memory _pipeNode, bytes memory _lastNodeResult) internal returns (bytes memory data) {
        data = abi.encodeWithSignature(_pipeNode.functionSignature);

        for (uint8 i; i < _pipeNode.args.length; ) {
            // se o bit eh on
            //      o valor dentro do array vai ser usado como position
            // caso contrario
            //      como valor

            argsBitmap[_nodeId].get(i)
                ? bytes.concat(data, getSlice(_lastNodeResult, _pipeNode.args[i]))
                : bytes.concat(data, _pipeNode.args[i]);

            unchecked {
                i++;
            }
        }
    }

    function getSlice(bytes memory data, uint256 intervalIndex) public pure returns (bytes32) {
        uint256 start = intervalIndex * 32;

        if(start + 32 > data.length)
            revert InvalidDataOffset();

        bytes32 slice;

        assembly {
            slice := mload(add(data, add(start, 32)))
        }

        return slice;
    }
 
    // function _runPipe() external whenNotPaused {
    //     if (
    //         lastExecutionTimestamp > 0 &&
    //         block.timestamp < lastExecutionTimestamp + executionInterval
    //     )
    //         revert ExecutionBeforeInterval();

    //     bytes memory lastNodeResult;

    //     for (uint i = 0; i < pipe.length;) {
    //         PipeNode memory _pipe = pipe[i];

    //         bytes memory encodedSignature = abi.encodeWithSignature(_pipe.functionSignature);
    //         bytes memory data = encodedSignature;

    //         // TODO: can this made without a for loop?
    //         for (uint j = 0; j < _pipe.args.length;) {
    //              data = _pipe.argsBitmap.get(j)
    //                 ? bytes.concat(data, getCalldataOffest(lastNodeResult))
    //                 : bytes.concat(data, _pipe.args[j]);

    //             unchecked {
    //                 i++;
    //             }
    //         }

    //         (bool success, bytes memory result) = _pipe.target.call(data);

    //         if (!success)
    //             revert PipeNodeError(i, result);
    //         else
    //             return result;

    //         unchecked {
    //             i++;
    //         }
    //     }
    // }

    // function getCalldataOffest(bytes memory data) internal returns (bytes memory) {
    //     bytes memory value = bytes(bytes32(0));

    //     return value;
    // }

    // function runPipe() external whenNotPaused {
    //     if (
    //         lastExecutionTimestamp > 0 &&
    //         block.timestamp < lastExecutionTimestamp + executionInterval
    //     )
    //         revert ExecutionBeforeInterval();

    //     bytes memory lastNodeResult;

    //     for (uint i = 0; i < pipe.length;) {
    //         PipeNode memory _pipe = pipe[i];

    //         lastNodeResult = _pipe.argsType == Args.Dynamic
    //             ? runDynamicNode(i, _pipe, lastNodeResult) 
    //             : runNode(i, _pipe);

    //         unchecked {
    //             i++;
    //         }
    //     }

    //     lastExecutionTimestamp = block.timestamp;
    // }

    // function runNode(uint256 nodeId, PipeNode memory pipeNode) internal returns (bytes memory) {
    //     bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);

    //     bytes memory data = pipeNode.argsType == Args.Static
    //         // TODO: is kinda risky to let the front end to deal with creating the fixed args
    //         // since the code can be updated and contain bugs. Wouldn't be better if this stays inside
    //         // the contract?
    //         ? bytes.concat(encodedSignature, pipeNode.fixedArgs)
    //         : encodedSignature;

    //     (bool success, bytes memory result) = pipeNode.target.call(data);

    //     if (!success)
    //         revert PipeNodeError(nodeId, result);
    //     else
    //         return result;
    // }

    // function runDynamicNode(
    //     uint nodeId,
    //     PipeNode memory pipeNode,
    //     bytes memory resultLastNode
    // ) internal returns (bytes memory) {
    //     bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);
    //     bytes memory data = bytes.concat(encodedSignature, resultLastNode);

    //     (bool success, bytes memory result) = pipeNode.target.call(data);

    //     if (!success)
    //         revert PipeNodeError(nodeId, result);
    //     else
    //         return result;
    // }

    // function getPipe() external view returns (PipeNode[] memory) {
    //     return pipe;
    // }

    // // @notice Execute an arbitrary transaction in order for this contract to become
    // // the owner of a given position in a given contract
    // function runTransaction(address target, bytes calldata data) external onlyOwner returns (bytes memory) {
    //     if (target == address(this))
    //         revert InvalidTarget();

    //     (bool success, bytes memory result) = target.call(data);

    //     if (!success)
    //         revert TransactionError(result);

    //     return result;
    // }

    // function setExecutionInterval(uint256 _executionInterval) external onlyOwner {
    //     executionInterval = _executionInterval;
    // }

    // function withdrawERC20(address _token, uint256 _amount) external onlyOwner {
    //     IERC20(_token).safeTransfer(owner(), _amount);
    // }

    // function withdraw721(address _token, uint256 _tokenId) public onlyOwner {
    //     IERC721(_token).safeTransferFrom(address(this), owner(), _tokenId);
    // }
}
