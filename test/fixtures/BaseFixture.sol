// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {Bundler} from "../../src/Bundler.sol";
import {BundlerFactory} from "../../src/BundlerFactory.sol";
import {BundleRunner} from "../../src/BundleRunner.sol";
import {FeeTokenRegistry} from "../../src/FeeTokenRegistry.sol";
import {IFeeTokenRegistry} from "../../src/interfaces/IFeeTokenRegistry.sol";
import {
    MockContract0,
    MockContract1,
    MockStake,
    MockToken,
    MockFeeToken,
    MockPriceFeed
} from "../mock/MockContracts.sol";
import "forge-std/console.sol";

abstract contract BaseFixture is Test {
    address public user0;
    address public user1;
    address public runnerOwner;
    address public bundleRunnerTreasury;
    address public factoryOwner;
    address public feeRegistryOwner;

    Bundler public bundler;
    BundlerFactory public factory;
    BundleRunner public runner;
    FeeTokenRegistry feeTokenRegistry;
    MockContract0 public mock0;
    MockContract1 public mock1;
    MockStake public mockStake;
    MockToken public mockToken;
    MockFeeToken public mockFeeToken;
    MockPriceFeed public mockPriceFeed;

    function setUp() public virtual {
        user0 = address(1);
        user1 = address(2);
        runnerOwner = address(3);
        factoryOwner = address(4);
        feeRegistryOwner = address(5);
        bundleRunnerTreasury = address(6);

        mock0 = new MockContract0();
        mock1 = new MockContract1();
        mockToken = new MockToken();
        mockFeeToken = new MockFeeToken();
        mockStake = new MockStake(mockToken);
        mockPriceFeed = new MockPriceFeed();

        IFeeTokenRegistry.FeeToken[] memory allowedTokens = new IFeeTokenRegistry.FeeToken[](1);
        allowedTokens[0] = IFeeTokenRegistry.FeeToken(
            address(mockToken),
            address(mockPriceFeed)
        );

        feeTokenRegistry = new FeeTokenRegistry(
            feeRegistryOwner,
            allowedTokens,
            address(mockToken)
        );
        bundler = new Bundler(user0, 0, address(mockToken),  feeTokenRegistry);
        factory = new BundlerFactory(factoryOwner, feeTokenRegistry);
        runner = new BundleRunner(runnerOwner, feeTokenRegistry, 10, bundleRunnerTreasury);

        mockToken.transfer(user0, 1000e18);
        mockToken.transfer(user1, 1000e18);

        mockFeeToken.transfer(user0, 10e18);
        mockFeeToken.transfer(user1, 10e18);
    }
}
