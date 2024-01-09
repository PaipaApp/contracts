// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {Bundler} from '../../../src/Bundler.sol';
import {IFeeTokenRegistry} from '../../../src/interfaces/IFeeTokenRegistry.sol';
import {BundleFixture} from '../../fixtures/BundleFixture.sol';
import {MockToken} from '../../mock/MockContracts.sol';

// Given the owner of the contract
//      When call setFeeToken
//          Then the feeToken should be updated
//          Then emit SetFeeToken event with the old and new feeTokens
//          Then set runner's allowance allowance to zero
//          Then set the new feeToken allowance max uint256
//      And feeToken is not allowed
//          Then revert with DisallowedFeeToken error
// Given a non-owner of the contract
//     When call setFeeToken
//        Then revert with AccessControlUnauthorizedAccount error
contract SetFeeTokenUnit is BundleFixture {
    MockToken newFeeToken;

    function setUp() public override {
        super.setUp();

        newFeeToken = new MockToken();

        IFeeTokenRegistry.FeeToken[] memory tokensToApprove = new IFeeTokenRegistry.FeeToken[](1);
        tokensToApprove[0] = IFeeTokenRegistry.FeeToken(address(newFeeToken), address(1));

        vm.prank(feeRegistryOwner);
        feeTokenRegistry.approveTokens(tokensToApprove);

        vm.prank(user0);
        bundler.approveBundleRunner(address(runner));
    }

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
        vm.prank(user0);
        bundler.setFeeToken(address(newFeeToken));

        assertEq(address(bundler.feeToken()), address(newFeeToken));
    }

    function test_EmitSetFeeTokenEvent()
        givenOwner
        whenCallSetFeeToken
        public
    {
        vm.expectEmit(address(bundler));
        emit Bundler.SetFeeToken(address(bundler.feeToken()), address(newFeeToken));

        vm.prank(user0);
        bundler.setFeeToken(address(newFeeToken));
    }

    function test_SetRunnerAllowanceToZeroOnOldToken()
        givenOwner
        whenCallSetFeeToken
        public
    {
        IERC20 feeToken = bundler.feeToken();
        vm.prank(user0);
        bundler.setFeeToken(address(newFeeToken));

        assertEq(feeToken.allowance(address(bundler), address(runner)), 0);
    }

    function test_SetNewFeeTokenAllowanceToMaxUint256() 
        givenOwner
        whenCallSetFeeToken
        public
    {
        vm.prank(user0);
        bundler.setFeeToken(address(newFeeToken));

        assertEq(newFeeToken.allowance(address(bundler), address(runner)), type(uint256).max);
    }

    function test_RevertWithDisallowedFeeTokenError() 
        givenOwner
        whenCallSetFeeToken
        andFeeTokenIsNotAllowed
        public
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            Bundler.DisallowedFeeToken.selector,
            address(5) // @dev arbitrary not allowed address
        );

        vm.expectRevert(errorSelector);
        vm.prank(user0);
        bundler.setFeeToken(address(5));
    }

    function test_RevertWithAccessControlUnauthorizedAccount() 
        givenNonOwner
        whenCallSetFeeToken
        public
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            address(this),
            0x00 // DEFAULT_ADMIN_ROLE
        );

        vm.expectRevert(errorSelector);
        bundler.setFeeToken(address(newFeeToken));
    }
}
