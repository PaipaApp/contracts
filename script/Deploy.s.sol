// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {FeeTokenRegistry} from "../src/FeeTokenRegistry.sol";
import {IFeeTokenRegistry} from "../src/interfaces/IFeeTokenRegistry.sol";
import {MockPriceFeed, MockToken} from "../test/mock/MockContracts.sol";
import "forge-std/console.sol";

contract DeployTestEnvironment is Script {
    function run() public {
        uint256 privateKey  = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        address testAccount = vm.envAddress("TEST_ACCOUNT");

        vm.startBroadcast(privateKey); {
            MockPriceFeed priceFeed = new MockPriceFeed();
            MockToken token = new MockToken();

            token.mint(testAccount, 10000000e18);

            IFeeTokenRegistry.FeeToken[] memory tokens = new IFeeTokenRegistry.FeeToken[](1);
            tokens[0] = IFeeTokenRegistry.FeeToken({
                token: address(token),
                priceFeed: address(priceFeed)
            });

            FeeTokenRegistry feeTokenRegistry = new FeeTokenRegistry(
                deployer,
                tokens,
                address(token)
            );

            console.log("FeeTokenRegistry deployed at: %s", address(feeTokenRegistry));
        }
        vm.stopBroadcast();
    }
}
