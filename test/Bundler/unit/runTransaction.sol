// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {BundleFixture} from "../../fixtures/BundleFixture.sol";
import {Bundler} from "../../../src/Bundler.sol";
import {MockToken} from "../../mock/MockContracts.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Given the owner of the contract
//      When the owner calls runTransaction with valid data
//          And the target is zero address
//              Then the transaction reverts with InvalidTarget
//          And the target is Bundler address
//              Then the transaction reverts with InvalidTarget
//           Then the transaction emits a TransactionExecuted event
//      When the owner calls runTransaction with invalid data
//          Then the transaction reverts with TransactionError
contract RunTransactionUnit is BundleFixture {
    function setUp() public override {
        super.setUp();
    }

    modifier givenOwner() {
        _;
    }

    modifier whenTheOwnerCallsRunTransaction() {
        _;
    }

    modifier whenTheAccountCallsRunTransactionWithInvalidData() {
        _;
    }

    modifier andTheTargetIsBundlerAddress() {
        _;
    }

    function test_RunTransactionWithTargetZeroAddress() 
        givenOwner
        whenTheOwnerCallsRunTransaction
        public
    {
        vm.prank(user0);
        vm.expectRevert(Bundler.InvalidTarget.selector);
        bundler.runTransaction(address(0), new bytes(0));
    }

    function test_RunTransactionWithBundlerAddress()
        givenOwner
        whenTheOwnerCallsRunTransaction
        public
    {
        vm.prank(user0);
        vm.expectRevert(Bundler.InvalidTarget.selector);
        bundler.runTransaction(address(bundler), new bytes(0));
    }

    function test_EmitTransactionExecutedEvent() public {
        uint256 tokenAmount = 10e18;

        // @dev the next two lines prevent the transaction to be reverted
        vm.prank(user0);
        mockToken.transfer(address(bundler), tokenAmount);

        bytes memory data = abi.encodeWithSelector(
            IERC20.transfer.selector,
            address(this),
            tokenAmount
        );

        vm.expectEmit(address(bundler));
        emit Bundler.TransactionRan(address(mockToken), abi.encode(true));

        vm.prank(user0);
        bundler.runTransaction(address(mockToken), data);
    }

    function test_RunTransactionWithInvalidData()
        givenOwner
        whenTheAccountCallsRunTransactionWithInvalidData
        public
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            Bundler.TransactionError.selector,
            0,
            new bytes(0)
        );

        vm.prank(user0);
        vm.expectRevert(errorSelector);
        bundler.runTransaction(address(mockToken), new bytes(0));
    }
}
