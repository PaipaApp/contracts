// SPDX: MIT License 
pragma solidity 0.8.22;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {BaseFixture} from "../../fixtures/BaseFixture.sol";
import {Bundler} from "../../../src/Bundler.sol";

// Given the owner of the contract
//      When setMaxFeePerRun is called
//          Then the maxFeePerRun is set
//          Then SetMaxFeePerRun event is emitted
// 
// Given a non-owner of the contract account
//      When setMaxFeePerRun is called
//          Then revert with AccessControlUnauthorizedAccount error
contract SetMaxFeePerRunUnit is BaseFixture {
    modifier givenOwner() {
        _;
    }

    modifier givenNonOwner() {
        _;
    }

    modifier whenCallSetMaxFeePerRun() {
        _;
    }

    function test_SetMaxFeePerRun()
        public
        givenOwner
        whenCallSetMaxFeePerRun
    {
        uint256 maxFeePerRun = 10e18;

        vm.prank(user0);
        bundler.setMaxFeePerRun(maxFeePerRun);

        assertEq(
            bundler.getMaxFeePerRun(),
            maxFeePerRun
        );
    }

    function test_SetMaxFeePerRunEmitsEvent()
        public
        givenOwner
        whenCallSetMaxFeePerRun
    {
        uint256 maxFeePerRun = 10e18;

        vm.prank(user0);
        vm.expectEmit(address(bundler));
        emit Bundler.SetMaxFeePerRun(0, maxFeePerRun);
        bundler.setMaxFeePerRun(maxFeePerRun);
    }

    function test_RevertWithAccessControlUnauthorizedAccount() 
        givenNonOwner
        whenCallSetMaxFeePerRun
        public
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            address(this),
            0x00 // DEFAULT_ADMIN_ROLE
        );

        vm.expectRevert(errorSelector);
        bundler.setMaxFeePerRun(10e18);
    }
}
