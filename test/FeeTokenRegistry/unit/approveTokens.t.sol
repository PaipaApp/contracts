// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BaseFixture} from "../../fixtures/BaseFixture.sol";
import {FeeTokenRegistry} from "../../../src/FeeTokenRegistry.sol";
import {IFeeTokenRegistry} from "../../../src/interfaces/IFeeTokenRegistry.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

// Given the contract owner
//      When calls approveTokens
//          And the tokens length is less than 10
//              Then the tokens address is set to true on allowedFeeTokens mapping
//              Then the priceFeed address is set to the priceFeeds mapping
//              Then the event ApprovedTokens is emitted
//                  But one token is zero address
//                      Then reverts with InvalidFeeTokenParams
//                  But one priceFeed is zero address
//                      Then reverts with InvalidFeeTokenParams 
//          And the tokens length is greater than 10
//              Then reverts with InvalidTokensLength
// 
// Given a non-owner address
//      When calls approveTokens
//          Then reverts with OwnableUnauthorizedAccount
contract ApproveTokensUnitTest is BaseFixture {
    IFeeTokenRegistry.FeeToken[] public feeTokens;

    function setUp() public override {
        super.setUp();
        feeTokens.push(
            IFeeTokenRegistry.FeeToken(address(mockToken), address(mockPriceFeed))
        );
    }

    modifier givenContractOwner() {
        _;
    }

    modifier whenCallsApproveTokens() {
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

    function test_SetTokensAddressToTrueOnAllowedFeeTokensMapping()
        public
        givenContractOwner
        whenCallsApproveTokens
        andTokensLengthIsLessThan10
    {
        vm.prank(feeRegistryOwner);
        feeTokenRegistry.approveTokens(feeTokens);

        assertTrue(feeTokenRegistry.isTokenAllowed(address(mockToken)));
    }

    function test_SetPriceFeedAddressToPriceFeedsMapping()
        public
        givenContractOwner
        whenCallsApproveTokens
        andTokensLengthIsLessThan10
    {
        vm.prank(feeRegistryOwner);
        feeTokenRegistry.approveTokens(feeTokens);

        assertEq(
            address(mockPriceFeed),
            address(feeTokenRegistry.getPriceFeedForToken(address(mockToken)))
        );
    }

    function test_EmitApprovedTokensEvent()
        public
        givenContractOwner
        whenCallsApproveTokens
        andTokensLengthIsLessThan10
    {
        vm.expectEmit(address(feeTokenRegistry));
        emit FeeTokenRegistry.ApprovedTokens(feeTokens);

        vm.prank(feeRegistryOwner);
        feeTokenRegistry.approveTokens(feeTokens);
    }

    function test_RevertWithInvalidFeeTokenWhenOneTokenIsZeroAddress()
        public
        givenContractOwner
        whenCallsApproveTokens
        andTokensLengthIsLessThan10
    {
        feeTokens[0].token = address(0);
        bytes memory errorSelector = abi.encodeWithSelector(
            FeeTokenRegistry.InvalidFeeTokenParams.selector,
            address(0),
            address(mockPriceFeed)
        );

        vm.prank(feeRegistryOwner);
        vm.expectRevert(errorSelector);
        feeTokenRegistry.approveTokens(feeTokens);
    }

    function test_RevertWithInvalidFeeTokenWhenOnePriceFeedIsZeroAddress()
        public
        givenContractOwner
        whenCallsApproveTokens
        andTokensLengthIsLessThan10
    {
        feeTokens[0].priceFeed = address(0);
        bytes memory errorSelector = abi.encodeWithSelector(
            FeeTokenRegistry.InvalidFeeTokenParams.selector,
            address(mockToken),
            address(0)
        );

        vm.prank(feeRegistryOwner);
        vm.expectRevert(errorSelector);
        feeTokenRegistry.approveTokens(feeTokens);
    }

    function test_RevertWithInvalidTokensLength()
        public
        givenContractOwner
        whenCallsApproveTokens
        andTokensLengthIsGreaterThan10
    {
        for (uint8 i; i < 11; i++)
            feeTokens.push(IFeeTokenRegistry.FeeToken(address(mockToken), address(mockPriceFeed)));

        bytes memory errorSelector = abi.encodeWithSelector(
            FeeTokenRegistry.InvalidTokensLength.selector
        );

        vm.prank(feeRegistryOwner);
        vm.expectRevert(errorSelector);
        feeTokenRegistry.approveTokens(feeTokens);
    }

    function test_RevertWithOwnableCallerIsNotTheOwner()
        public
        givenNonContractOwner
        whenCallsApproveTokens
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector,
            address(this)
        );

        vm.expectRevert(errorSelector);
        feeTokenRegistry.approveTokens(feeTokens);
    }
}
