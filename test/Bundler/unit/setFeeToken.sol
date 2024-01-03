// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { BundleFixture } from '../../fixtures/BundleFixture.sol';
import { Bundler } from '../../../src/Bundler.sol';
import { IAccessControl } from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';

// Given the owner of the contract
//      When call setFeeToken
//          Then the feeToken should be updated
//          Then emit SetFeeToken event with the old and new feeTokens
//      And feeToken is not allowed
//          Then revert with DisallowedFeeToken error
// Given a non-owner of the contract
//     When call setFeeToken
//        Then revert with AccessControl error
contract SetFeeTokenUnit is BundleFixture {
    modifier givenOwner() {
        _;
    }

    modifier givenNonOwner() {
        _;
    }

    modifier whenCallSetFeeToken () {
        _;
    }

    modifier andFeeTokenIsNotAllowed() {
        _;
    }

    function test_FeeTokenShouldBeUpdated() 
        givenOwner
        whenCallSetFeeToken
        public
    {
        address newFeeToken = address(mockToken);

        vm.prank(user0);
        bundler.setFeeToken(newFeeToken);

        assertEq(address(bundler.feeToken()), newFeeToken);
    }

    function test_EmitSetFeeTokenEvent() 
        givenOwner
        whenCallSetFeeToken
        public
    {
        address newFeeToken = address(mockToken);

        vm.expectEmit(address(bundler));
        emit Bundler.SetFeeToken(address(bundler.feeToken()), newFeeToken);

        vm.prank(user0);
        bundler.setFeeToken(newFeeToken);
    }

    function test_RevertWithDisallowedFeeTokenError() 
        givenOwner
        whenCallSetFeeToken
        andFeeTokenIsNotAllowed
        public
    {
        address newFeeToken = address(0x1);
        bytes memory errorSelector = abi.encodeWithSelector(
            Bundler.DisallowedFeeToken.selector,
            newFeeToken
        );

        vm.expectRevert(errorSelector);
        vm.prank(user0);
        bundler.setFeeToken(newFeeToken);
    }

    function test_RevertWithAccessControlError() 
        givenNonOwner
        whenCallSetFeeToken
        public
    {
        address newFeeToken = address(0x1);
        bytes memory errorSelector = abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            address(this),
            0x00 // DEFAULT_ADMIN_ROLE
        );

        vm.expectRevert(errorSelector);
        bundler.setFeeToken(newFeeToken);
    }
}
