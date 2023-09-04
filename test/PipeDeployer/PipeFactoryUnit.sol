import {PipeFactory} from "../../src/PipeFactory.sol";
import "forge-std/Test.sol";

contract PipeDeployerUnitTest is Test {
    PipeFactory public factory;

    function setUp() public {
        factory = new PipeFactory();
    }

    function test_DeployPipeContract() public {
        address pipeAddress = factory.deployPipe(0);

        assertTrue(pipeAddress != address(0));
    }

    function test_RegisterUserPipeAddresses() public {
        factory.deployPipe(0);

        address[] memory userPipes = factory.getUserPipes(address(this));

        assertEq(userPipes.length, 1);
        assertTrue(userPipes[0] != address(0));
    }
}
