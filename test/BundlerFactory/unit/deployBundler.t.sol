// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BundlerFactory} from "../../../src/BundlerFactory.sol";
import "forge-std/Test.sol";

contract BundlerDeployerUnitTest is Test {
    BundlerFactory public factory;

    function setUp() public {
        factory = new BundlerFactory(address(this));
    }

    function test_DeployBundlerContract() public {
        address pipeAddress = factory.deployBundler(0);

        assertTrue(pipeAddress != address(0));
    }

    function test_RegisterUserBundlerAddresses() public {
        factory.deployBundler(0);

        address[] memory userBundlers = factory.getUserBundlers(address(this));

        assertEq(userBundlers.length, 1);
        assertTrue(userBundlers[0] != address(0));
    }
}
