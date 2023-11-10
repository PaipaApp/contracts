// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {Bundler} from "../../src/Bundler.sol";
import {BundlerFactory} from "../../src/BundlerFactory.sol";
import {BundleRunner} from "../../src/BundleRunner.sol";
import {MockContract0, MockContract1, MockStake, MockToken} from "../mock/MockContracts.sol";

abstract contract BaseFixture is Test {
    address public user0;
    address public user1;
    address public runnerOwner;
    address public factoryOwner;

    Bundler public bundler;
    BundlerFactory public factory;
    BundleRunner public runner;
    MockContract0 public mock0;
    MockContract1 public mock1;
    MockStake public mockStake;
    MockToken public mockToken;

    function setUp() public virtual {
        user0 = address(1);
        user1 = address(2);
        runnerOwner = address(3);
        factoryOwner = address(4);

        bundler = new Bundler(user0, 0);
        factory = new BundlerFactory(factoryOwner);
        runner = new BundleRunner(runnerOwner);

        mock0 = new MockContract0();
        mock1 = new MockContract1();

        mockToken = new MockToken();
        mockStake = new MockStake(mockToken);

        mockToken.transfer(user0, 10e18);
        mockToken.transfer(user1, 10e18);
    }
}
