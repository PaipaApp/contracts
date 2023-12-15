//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {BaseFixture} from "../../fixtures/BaseFixture.sol";

// Given the owner of the contract
//      When calls setDefaultFeeToken
//          Then default fee token is updated
// Given a non-owner account
//     When calls setDefaultFeeToken
//        Then reverts with OwnableUnauthorizedAccount
contract SetDefaultFeeTokenUnitTest is BaseFixture {
    function setUp() public override {
        super.setUp();
    }

    modifier givenContractOwner() {
        _;
    }

    modifier whenCallsSetDefaultFeeToken() {
        _;
    }

    modifier givenNonContractOwner() {
        _;
    }

    function test_UpdateDefaultFeeToken()
        public
        givenContractOwner
        whenCallsSetDefaultFeeToken
    {
        vm.prank(feeRegistryOwner);
        feeTokenRegistry.setDefaultFeeToken(address(10));

        assertEq(
            feeTokenRegistry.defaultFeeToken(),
            address(10)
        );
    }

    function test_RevertsWhenNonOwnerCallsSetDefaultFeeToken()
        public
        givenNonContractOwner
        whenCallsSetDefaultFeeToken
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector,
            address(this)
        );

        vm.expectRevert(errorSelector);
        feeTokenRegistry.setDefaultFeeToken(address(10));
    }
}
