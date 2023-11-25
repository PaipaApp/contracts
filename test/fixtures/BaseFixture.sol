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

abstract contract BaseFixture is Test {
    address public user0;
    address public user1;
    address public runnerOwner;
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

        mock0 = new MockContract0();
        mock1 = new MockContract1();
        mockToken = new MockToken();
        mockFeeToken = new MockFeeToken();
        mockStake = new MockStake(mockToken);
        mockPriceFeed = new MockPriceFeed();

        IFeeTokenRegistry.TokenInfo[] memory allowedTokens = new IFeeTokenRegistry.TokenInfo[](1);
        allowedTokens[0] = IFeeTokenRegistry.TokenInfo(
            mockToken,
            mockPriceFeed
        );

        feeTokenRegistry = new FeeTokenRegistry(
            feeRegistryOwner,
            allowedTokens,
            IFeeTokenRegistry.TokenInfo(
                mockToken,
                mockPriceFeed
            )
        );
        bundler = new Bundler(user0, 0, address(mockToken),  feeTokenRegistry);
        factory = new BundlerFactory(factoryOwner, feeTokenRegistry);
        runner = new BundleRunner(runnerOwner, feeTokenRegistry);

        mockToken.transfer(user0, 10e18);
        mockToken.transfer(user1, 10e18);

        mockFeeToken.transfer(user0, 10e18);
        mockFeeToken.transfer(user1, 10e18);
    }
}
