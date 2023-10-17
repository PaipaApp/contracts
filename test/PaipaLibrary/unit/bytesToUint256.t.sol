import {Test} from "forge-std/Test.sol";
import {PaipaLibrary} from "../../../src/PaipaLibrary.sol";

contract PaipaLibraryTest is Test {
    // TODO: test fail test cases
    // TODO: how to to test libs in foudry, if adds any complexity write about
    function test_GetAbiSlice() public {
        bytes memory mockAbi = abi.encode(uint(32), uint8(64), uint8(96));

        assertEq(
            bytes32(uint(32)),
            PaipaLibrary.getSlice(mockAbi, 0)
        );

        assertEq(
            bytes32(uint(64)),
            PaipaLibrary.getSlice(mockAbi, 1)
        );

        assertEq(
            bytes32(uint(96)),
            PaipaLibrary.getSlice(mockAbi, 2)
        );
    }
}