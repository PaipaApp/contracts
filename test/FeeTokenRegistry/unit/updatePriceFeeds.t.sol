// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {BaseFixture} from "../../fixtures/BaseFixture.sol";
import {IFeeTokenRegistry} from "../../../src/interfaces/IFeeTokenRegistry.sol";
import {FeeTokenRegistry} from "../../../src/FeeTokenRegistry.sol";

// Given the owner of the contract
//      When calls updatePriceFeeds
//          And tokens length is less than 10
//              Then updates price feed for a given token
//              Then emits event UpdatedPriceFeeds
//              But one token is zero address
//                  Then reverts with InvalidFeeTokenParams
//              But one priceFeed is zero address
//                  Then reverts with InvalidFeeTokenParams
//          And tokens length is more than 10
//                  Then reverts with InvalidTokensLength
// 
// Given a non-owner account 
//      When calls updatePriceFeeds
//          Then reverts with OwnableUnauthorizedAccount
contract UpdatePriceFeedsUnitTest is BaseFixture {
    IFeeTokenRegistry.FeeToken[] public feeTokens;

    function setUp() public override {
        super.setUp();
        feeTokens.push(
            IFeeTokenRegistry.FeeToken(address(mockToken), address(mockPriceFeed))
        );

        vm.prank(feeRegistryOwner);
        feeTokenRegistry.approveTokens(feeTokens);
    }

    modifier givenContractOwner() {
        _;
    }

    modifier whenCallsUpdatePriceFeeds() {
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

    function test_UpdatePriceFeedForAGivenToken()
        public
        givenContractOwner
        whenCallsUpdatePriceFeeds
        andTokensLengthIsLessThan10
    {
        feeTokens[0].priceFeed = address(10);

        vm.prank(feeRegistryOwner);
        feeTokenRegistry.updatePriceFeeds(feeTokens);

        assertEq(
            address(feeTokenRegistry.getPriceFeedForToken(address(mockToken))),
            address(10)
        );
    }

    function test_EmitUpdatedPriceFeedsEvent()
        public
        givenContractOwner
        whenCallsUpdatePriceFeeds
        andTokensLengthIsLessThan10
    {
        vm.expectEmit(address(feeTokenRegistry));
        emit FeeTokenRegistry.UpdatedPriceFeeds(feeTokens);

        vm.prank(feeRegistryOwner);
        feeTokenRegistry.updatePriceFeeds(feeTokens);
    }

    function test_RevertWithInvalidFeeTokenParamsWhenTokenIsZeroAddress()
        public
        givenContractOwner
        whenCallsUpdatePriceFeeds
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
        feeTokenRegistry.updatePriceFeeds(feeTokens);
    }

    function test_RevertWithInvalidFeeTokenParamsWhenPriceFeedIsZeroAddress()
        public
        givenContractOwner
        whenCallsUpdatePriceFeeds
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
        feeTokenRegistry.updatePriceFeeds(feeTokens);
    }

    function test_RevertWithInvalidTokensLength()
        public
        givenContractOwner
        whenCallsUpdatePriceFeeds
        andTokensLengthIsGreaterThan10
    {
        for (uint8 i; i < 11; i++)
            feeTokens.push(
                IFeeTokenRegistry.FeeToken(address(mockToken), address(mockPriceFeed))
            );

        vm.prank(feeRegistryOwner);
        vm.expectRevert(FeeTokenRegistry.InvalidTokensLength.selector);
        feeTokenRegistry.updatePriceFeeds(feeTokens);
    }

    function test_RevertWithOwnableCallerIsNotTheOwner()
        public
        givenNonContractOwner
        whenCallsUpdatePriceFeeds
    {
        bytes memory errorSelector = abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector,
            address(this)
        );

        vm.expectRevert(errorSelector);
        feeTokenRegistry.updatePriceFeeds(feeTokens);
    }
}
