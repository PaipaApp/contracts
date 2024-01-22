// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseFixture} from "../../fixtures/BaseFixture.sol";

// Given the contract is not paused
//     When the account calls pause
//        Then the paused state is true
// Given the contract is paused
//     When the account calls unpause
//        Then the paused state is false
contract PauseUnit is BaseFixture {
    modifier givenPaused() {
        _;
    }

    modifier givenUnpaused() {
        _;
    }

    modifier whenTheAccountCallsPause() {
        _;
    }

    modifier whenTheAccountCallsUnpause() {
        _;
    }

    function test_PauseIsTrue() public givenPaused whenTheAccountCallsPause {
        assertFalse(bundler.paused());
        vm.prank(user0);
        bundler.pauseRuns();
        assertTrue(bundler.paused());
    }

    function test_PauseIsFalse() public givenUnpaused whenTheAccountCallsUnpause {
        vm.startPrank(user0); {
            bundler.pauseRuns();
            bundler.resumeRuns();
        }
        assertFalse(bundler.paused());
    } 
}
