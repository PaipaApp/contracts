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
        bytes[] args;
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


        if (argTypes.length != _pipeNodes.length) {
            console.log('DAMN Arg types length: %s', argTypes.length);
            console.log('DAMN Pipe nodes length: %s', _pipeNodes.length);

            revert ArgsMismatch();
        }

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

    function getPipe() external view returns (PipeNode[] memory) {
        return pipeNodes;
    }

    function argTypeIsDynamic(uint nodeId, uint argId) external view returns (bool) {
        return argsBitmap[nodeId].get(argId);
    }

    // TODO: time guard
    function runPipe() external onlyOwner whenNotPaused {
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

    function buildData(
        uint _nodeId,
        PipeNode memory _pipeNode,
        bytes memory _lastNodeResult
    ) internal view returns (bytes memory data) {
        data = abi.encodeWithSignature(_pipeNode.functionSignature);

        for (uint8 i; i < _pipeNode.args.length; ) {
            if (argsBitmap[_nodeId].get(i)) {
                uint256 interval = bytesToUint256(_pipeNode.args[i]);

                data = bytes.concat(data, getSlice(_lastNodeResult, interval));
            } else {
               data = bytes.concat(data, _pipeNode.args[i]);
            }

            unchecked {
                i++;
            }
        }
    }

    // TODO: test this
    function bytesToUint256(bytes memory _bytes) public pure returns (uint256 result) {
        require(_bytes.length >= 32, "Bytes length should be at least 32 bytes.");

        assembly {
            result := mload(add(_bytes, 0x20))
        }
    }

    // TODO: need some kind of guard to make sure bytes isn't bigger than 32 bytes
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

    // @notice Execute an arbitrary transaction in order for this contract to become
    // the owner of a given position in a given contract
    function runTransaction(address target, bytes calldata data) external onlyOwner returns (bytes memory) {
        if (target == address(this))
            revert InvalidTarget();

        (bool success, bytes memory result) = target.call(data);

        if (!success)
            revert TransactionError(result);

        return result;
    }
 
    function setExecutionInterval(uint256 _executionInterval) external onlyOwner {
        executionInterval = _executionInterval;
    }

    function withdrawERC20(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(owner(), _amount);
    }

    function withdraw721(address _token, uint256 _tokenId) public onlyOwner {
        IERC721(_token).safeTransferFrom(address(this), owner(), _tokenId);
    }
}
