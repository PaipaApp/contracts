// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {Helpers} from "../../../src/libraries/Helpers.sol";

// Given a bytes array consisting of uint256(32), uint256(64) and uint256(96)
//      When getSlice is called with index 0
//          Then return uint256(32)
//      When getSlice is called with index 1
//          Then return uint256(64)
//      When getSlice is called with index 2
//          Then return uint256(96)
//      When getSlice is called with an index greater than length / fields
//          Then revert with InvalidDataOffset
contract HelpersTest is Test {
    bytes mockAbi;

    function setUp() public {
        mockAbi = abi.encode(uint256(32), uint8(64), uint8(96));
    }

    modifier givenBytesArray() {
        _;
    }

    modifier whenGetSliceIsCalledWithIndex(uint256 index) {
        _;
    }

    function test_Return32() 
        givenBytesArray
        whenGetSliceIsCalledWithIndex(0)
        public 
    {
        assertEq(bytes32(uint256(32)), Helpers.getSlice(mockAbi, 0));
    }

    function test_Return64() 
        givenBytesArray
        whenGetSliceIsCalledWithIndex(1)
    public {
        assertEq(bytes32(uint256(64)), Helpers.getSlice(mockAbi, 1));
    }

    function test_Return96() 
        givenBytesArray
        whenGetSliceIsCalledWithIndex(2)
        public 
    {
        assertEq(bytes32(uint256(96)), Helpers.getSlice(mockAbi, 2));
    }

    function test_RevertWithInvalidDataOffset() 
        givenBytesArray
        whenGetSliceIsCalledWithIndex(3)
        public 
    {
        uint outOfBoundsIndex = mockAbi.length / 32;

        console.log("outOfBoundsIndex: %s", outOfBoundsIndex);
        console.log("mockAbi length: %s", mockAbi.length);

        vm.expectRevert(Helpers.InvalidDataOffset.selector);
        Helpers.getSlice(mockAbi, outOfBoundsIndex);
    }

}
