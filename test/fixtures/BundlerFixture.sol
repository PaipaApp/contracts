// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {Bundler} from "../../src/Bundler.sol";
import {
    MockContract0,
    MockContract1,
    MockStake,
    MockToken
} from "../mock/MockContracts.sol";

abstract contract BundlerFixture is Test {
    address public user0;

    Bundler public bundler;
    MockContract0 public mock0;
    MockContract1 public mock1;
    MockStake public mockStake;
    MockToken public mockToken;

    function setUp() public virtual {
        user0 = address(1);

        vm.prank(user0);
        bundler = new Bundler(user0, 0);

        mock0 = new MockContract0();
        mock1 = new MockContract1();

        mockToken = new MockToken();
        mockStake = new MockStake(mockToken);

        mockToken.transfer(user0, 10e18);
    }
}
