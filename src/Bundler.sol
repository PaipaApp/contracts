/**
 *        ███████████             ███
 *       ░░███░░░░░███           ░░░
 *        ░███    ░███  ██████   ████  ████████   ██████
 *        ░██████████  ░░░░░███ ░░███ ░░███░░███ ░░░░░███
 *        ░███░░░░░░    ███████  ░███  ░███ ░███  ███████
 *        ░███         ███░░███  ░███  ░███ ░███ ███░░███
 *        █████       ░░████████ █████ ░███████ ░░████████
 *       ░░░░░         ░░░░░░░░ ░░░░░  ░███░░░   ░░░░░░░░
 *                                     ░███
 *                                     █████
 *                                    ░░░░░
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/utils/Pausable.sol";
import {BitMaps} from "openzeppelin-contracts/contracts/utils/structs/BitMaps.sol";
import {Helpers} from "./libraries/Helpers.sol";
import {IBundler} from "./interfaces/IBundler.sol";
import {IFeeTokenRegistry} from "./interfaces/IFeeTokenRegistry.sol";

// @dev this contract doesn't support payable transactions
contract Bundler is IBundler, AccessControl, Pausable {
    using BitMaps for BitMaps.BitMap;
    using SafeERC20 for IERC20;

    bytes32 private constant BUNDLE_RUNNER = keccak256("BUNDLE_RUNNER");

    // @dev Transaction ID => BitMap
    mapping(uint256 => BitMaps.BitMap) private argsBitmap;

    Transaction[] private transactions;
    uint256 private lastExecutionTimestamp;
    uint256 private executionInterval;
    uint256 private runs;
    uint256 private maxFeePerRun;
    address private bundleRunner;

    uint8 constant public MAX_BUNDLE_SIZE = 10;
    IERC20 public feeToken;
    IFeeTokenRegistry public feeTokenRegistry;

    event SetFeeToken(address oldFeeToken, address newFeeToken);
    event SetMaxFeePerRun(uint256 oldMaxFee, uint256 newMaxFee);
    event TransactionRan(address to, bytes result);
    event SetExecutionInterval(uint256 oldInterval, uint256 newInterval);
    event BundleRunnerRevoked(address runner);
    event BundleRunnerApproved(address runner);
    event FeeTokenDeposited(address token, uint256 amount);

    error TransactionError(uint256 transactionId, bytes result);
    error InvalidTarget();
    error ExecutionBeforeInterval();
    error ArgsMismatch();
    error NotAllowedToRunBundle();
    error FirstTransactionWithDynamicArg(uint256 argIndex);
    error DisallowedFeeToken(address feeToken);
    error MaxTransactionPerBundleReached();

    constructor(address _owner, uint256 _executionInterval, address _feeToken, IFeeTokenRegistry _feeTokenRegistry) {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        executionInterval = _executionInterval;
        feeTokenRegistry = _feeTokenRegistry;
        feeToken = feeTokenRegistry.isTokenAllowed(address(_feeToken))
            ? IERC20(_feeToken)
            : IERC20(feeTokenRegistry.getDefaultFeeToken().token);
    }

    function createBundle(Transaction[] memory _transactions, bool[][] calldata _argTypes)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (_transactions.length > MAX_BUNDLE_SIZE)
            revert MaxTransactionPerBundleReached();

        if (_argTypes.length != _transactions.length)
            revert ArgsMismatch();

        // @dev In order to override the current transactions
        if (transactions.length > 0)
            delete transactions;

        for (uint256 i = 0; i < _transactions.length; i++) {
            Transaction memory transaction = _transactions[i];
            bool[] memory argType = _argTypes[i];

            if (argType.length != transaction.args.length)
                revert ArgsMismatch();

            if (transaction.target == address(0))
                revert InvalidTarget();

            for (uint256 j = 0; j < transaction.args.length; j++) {
                // @dev The first transaction cannot receive dynamic arguments
                if (i == 0 && argType[j] == true)
                    revert FirstTransactionWithDynamicArg(j);

                argsBitmap[i].setTo(j, argType[j]);
            }

            transactions.push(transaction);
        }
    }

    function getBundle() external view returns (Transaction[] memory) {
        return transactions;
    }

    function argTypeIsDynamic(uint256 transactionId, uint256 argId) external view returns (bool) {
        return argsBitmap[transactionId].get(argId);
    }

    function runBundle() external whenNotPaused {
        if (lastExecutionTimestamp > 0 && block.timestamp < lastExecutionTimestamp + executionInterval)
            revert ExecutionBeforeInterval();

        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender) && !hasRole(BUNDLE_RUNNER, msg.sender))
            revert NotAllowedToRunBundle();

        bytes memory lastTransactionResult;

        for (uint8 i; i < transactions.length; i++) {
            Transaction memory transaction = transactions[i];
            bytes memory data = buildData(i, transaction, lastTransactionResult);

            (bool success, bytes memory result) = transaction.target.call(data);

            if (!success)
                revert TransactionError(i, result);

            lastTransactionResult = result;
        }

        runs += 1;
        lastExecutionTimestamp = block.timestamp;
    }

    function buildData(uint256 _transactionId, Transaction memory _transaction, bytes memory _lastTransactionResult)
        internal
        view
        returns (bytes memory data)
    {
        data = abi.encodeWithSignature(_transaction.functionSignature);

        for (uint8 i; i < _transaction.args.length; i++) {
            // @dev is dynamic arg
            if (argsBitmap[_transactionId].get(i)) {
                uint256 interval = Helpers.bytesToUint256(_transaction.args[i]);
                data = bytes.concat(data, Helpers.getSlice(_lastTransactionResult, interval));
            } else {
                data = bytes.concat(data, _transaction.args[i]);
            }
        }
    }

    // @notice Execute an arbitrary transaction in order for this contract to become
    // the owner of a given position in a given contract
    function runTransaction(address target, bytes calldata data)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bytes memory)
    {
        if (target == address(this) || target == address(0))
            revert InvalidTarget();

        (bool success, bytes memory result) = target.call(data);

        if (!success)
            revert TransactionError(0, result);

        emit TransactionRan(target, result);

        return result;
    }

    function getExecutionInterval() external view returns (uint256) {
        return executionInterval;
    }

    function setExecutionInterval(uint256 _executionInterval) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit SetExecutionInterval(executionInterval, _executionInterval);

        executionInterval = _executionInterval;
    }

    function depositFeeToken(uint256 _amount) external {
        feeToken.transferFrom(msg.sender, address(this), _amount);
        emit FeeTokenDeposited(address(feeToken), _amount);
    }

    function getRuns() external view returns (uint256) {
        return runs;
    }

    function getTransactions() external view returns (Transaction[] memory) {
        return transactions;
    }

    function approveBundleRunner(address _bundleRunner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(BUNDLE_RUNNER, _bundleRunner);

        // @dev feeToken cannot be address(0). It is initialized in the constructor
        IERC20(feeToken).safeIncreaseAllowance(_bundleRunner, type(uint256).max);
        bundleRunner = _bundleRunner;

        emit BundleRunnerApproved(_bundleRunner);
    }

    function revokeBundleRunner(address _runner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(BUNDLE_RUNNER, _runner);
        IERC20(feeToken).forceApprove(_runner, 0);

        emit BundleRunnerRevoked(_runner);

        bundleRunner = address(0);
    }

    function setMaxFeePerRun(uint256 _maxFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit SetMaxFeePerRun(maxFeePerRun, _maxFee);

        maxFeePerRun = _maxFee;
    }

    function setFeeToken(address _feeToken) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!feeTokenRegistry.isTokenAllowed(_feeToken))
            revert DisallowedFeeToken(_feeToken);

        emit SetFeeToken(address(feeToken), _feeToken);

        IERC20(feeToken).forceApprove(bundleRunner, 0);
        IERC20(_feeToken).safeIncreaseAllowance(bundleRunner, type(uint256).max);

        feeToken = IERC20(_feeToken);
    }

    function pauseRuns() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function isPaused() external view returns (bool) {
        return paused();
    }

    function resumeRuns() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function getFeeToken() external view returns (IERC20) {
        return feeToken;
    }

    function getBundleRunner() external view returns (address) {
        return bundleRunner;
    }

    function getMaxFeePerRun() external view returns (uint256) {
        return maxFeePerRun;
    }
}
