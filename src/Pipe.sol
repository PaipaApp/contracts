// SPDX-License-Identifier: MTI
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";

// TODO: how reentrancy can affect execution

// TODO: how to work with ERC721 and ERC1155 approvals
// @dev this contract doesn't support ERC1155 transactions nor payable transactions
contract Pipe is Ownable, Pausable {
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
        Args argsType;
        bytes fixedArgs;
    }

    PipeNode[] public pipe;
    uint256 lastExecutionTimestamp;
    uint256 executionInterval;

    error PipeNodeError(uint256 nodeId, bytes result); 
    error InvalidTarget();
    error ExecutionBeforeInterval();
    error TransactionError(bytes result);

    function createPipe(PipeNode[] memory _pipeNodes) external onlyOwner {
        PipeNode[] storage _pipe = pipe;

        if (_pipe.length > 0)
            delete pipe;

        for (uint256 i = 0; i < _pipeNodes.length; i++) {
            PipeNode memory node = _pipeNodes[i];

            if (node.target == address(0))
                revert InvalidTarget();

            _pipe.push(node);
        }
    }

    function runPipe() external whenNotPaused {
        if (
            lastExecutionTimestamp > 0 &&
            block.timestamp < lastExecutionTimestamp + executionInterval
        )
            revert ExecutionBeforeInterval();

        bytes memory lastNodeResult;

        for (uint i = 0; i < pipe.length;) {
            PipeNode memory _pipe = pipe[i];

            lastNodeResult = _pipe.argsType == Args.Dynamic
                ? runDynamicNode(i, _pipe, lastNodeResult) 
                : runNode(i, _pipe);

            unchecked {
                i++;
            }
        }

        lastExecutionTimestamp = block.timestamp;
    }

    function runNode(uint256 nodeId, PipeNode memory pipeNode) internal returns (bytes memory) {
        bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);

        bytes memory data = pipeNode.argsType == Args.Static
            // TODO: is kinda risky to let the front end to deal with creating the fixed args
            // since the code can be updated and contain bugs. Wouldn't be better if this stays inside
            // the contract?
            ? bytes.concat(encodedSignature, pipeNode.fixedArgs)
            : encodedSignature;

        (bool success, bytes memory result) = pipeNode.target.call(data);

        if (!success)
            revert PipeNodeError(nodeId, result);
        else
            return result;
    }

    function runDynamicNode(
        uint nodeId,
        PipeNode memory pipeNode,
        bytes memory resultLastNode
    ) internal returns (bytes memory) {
        bytes memory encodedSignature = abi.encodeWithSignature(pipeNode.functionSignature);
        bytes memory data = bytes.concat(encodedSignature, resultLastNode);

        (bool success, bytes memory result) = pipeNode.target.call(data);

        if (!success)
            revert PipeNodeError(nodeId, result);
        else
            return result;
    }

    function getPipe() external view returns (PipeNode[] memory) {
        return pipe;
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
