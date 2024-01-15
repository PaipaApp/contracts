// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {BaseFixture} from "../../fixtures/BaseFixture.sol";
import {Bundler} from "../../../src/Bundler.sol";

// Given any account
//      When depositFeeToken is called
//          Then the fee token is transferred from the caller to the contract
//          Then FeeTokenDeposited event is emitted
contract DepositFeeTokenUnit is BaseFixture {
    function setUp() public override {
        super.setUp();
    }

    modifier givenAnyAccount() {
        _;
    }

    modifier whenDepositFeeTokenIsCalled() {
        _;
    }

    function test_DepositFeeToken()
        public
        givenAnyAccount
        whenDepositFeeTokenIsCalled
    {
        uint256 depositAmount = 10e18;
        IERC20 feeToken = IERC20(bundler.feeToken());

        vm.startPrank(user0); {
            feeToken.approve(address(bundler), depositAmount);
            bundler.depositFeeToken(depositAmount);
        }
        vm.stopPrank();

        assertEq(
            feeToken.balanceOf(address(bundler)),
            depositAmount
        );
    }

    function test_DepositFeeTokenEmitsEvent()
        public
        givenAnyAccount
        whenDepositFeeTokenIsCalled
    {
        uint256 depositAmount = 10e18;
        IERC20 feeToken = IERC20(bundler.feeToken());


        vm.startPrank(user0); {
            feeToken.approve(address(bundler), depositAmount);

            vm.expectEmit(address(bundler));
            emit Bundler.FeeTokenDeposited(
                address(feeToken),
                depositAmount
            );

            bundler.depositFeeToken(depositAmount);
        }
    }
}
