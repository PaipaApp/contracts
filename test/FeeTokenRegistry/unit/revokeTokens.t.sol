// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {BaseFixture} from "../../fixtures/BaseFixture.sol";
import {IFeeTokenRegistry} from "../../../src/interfaces/IFeeTokenRegistry.sol";
import {FeeTokenRegistry} from "../../../src/FeeTokenRegistry.sol";

// Given a contract owner
//      When calls revokeTokens
//          And tokens length is less than 10
//              Then the tokens address is set to false on allowedFeeTokens mapping
//              Then the event RevokedTokens is emitted
//              But one token is zero address
//                  Then reverts with InvalidTokenAddress
//          And tokens length is greater than 10
//              Then reverts with InvalidTokensLength
// 
// Given a non-owner address
//     When calls revokeTokens
//        Then reverts with Ownable: caller is not the owner
contract RevokeTokensUnitTest is BaseFixture {
    IFeeTokenRegistry.FeeToken[] public approveList;
    address[] public revokeList;

    function setUp() public override {
        super.setUp();

        approveList.push(
            IFeeTokenRegistry.FeeToken(address(mockToken), address(mockPriceFeed))
        );
        revokeList.push(address(mockToken));

        vm.prank(feeRegistryOwner);

        feeTokenRegistry.approveTokens(approveList);
    }

    modifier givenContractOwner() {
        _;
    }

    modifier whenCallsRevokeTokens() {
        _;
    }

    modifier andTokensLengthIsLessThan10() {
        _;
    }

    modifier andTokensLengthIsGreaterThan10() {
        _;
    }
    
    modifier givenNonContractOwner() {
        _;
    }

    function test_SetTokensAddressToFalseOnAllowedFeeTokensMapping()
        public
        givenContractOwner
        whenCallsRevokeTokens
        andTokensLengthIsLessThan10
    {
        vm.prank(feeRegistryOwner);
        feeTokenRegistry.revokeTokens(revokeList);

        assertFalse(feeTokenRegistry.isTokenAllowed(address(mockToken)));
    }

    function test_EmitRevokedTokensEvent()
        public
        givenContractOwner
        whenCallsRevokeTokens
        andTokensLengthIsLessThan10
    {
        vm.expectEmit(address(feeTokenRegistry));
        emit FeeTokenRegistry.RevokedTokens(revokeList);

        vm.prank(feeRegistryOwner);
        feeTokenRegistry.revokeTokens(revokeList);
    }

    function test_RevertWithInvalidTokenAddress()
        public
        givenContractOwner
        whenCallsRevokeTokens
        andTokensLengthIsLessThan10
    {
        revokeList.push(address(0));

        vm.prank(feeRegistryOwner);
        vm.expectRevert(FeeTokenRegistry.InvalidTokenAddress.selector);
        feeTokenRegistry.revokeTokens(revokeList);
    }

    function test_RevertWithInvalidTokensLength()
        public
        givenContractOwner
        whenCallsRevokeTokens
        andTokensLengthIsGreaterThan10
    {
        for (uint8 i; i < 11; i++)
            revokeList.push(address(mockToken));

        vm.prank(feeRegistryOwner);
        vm.expectRevert(FeeTokenRegistry.InvalidTokensLength.selector);
        feeTokenRegistry.revokeTokens(revokeList);
    }

    function test_RevertWithOwnableCallerIsNotTheOwner()
        public
        givenNonContractOwner
        whenCallsRevokeTokens
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector,
            address(this)
        );

        vm.expectRevert(errorSelector);
        feeTokenRegistry.revokeTokens(revokeList);
    }
}
