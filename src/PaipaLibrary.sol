/**
       ███████████             ███                     
      ░░███░░░░░███           ░░░                      
       ░███    ░███  ██████   ████  ████████   ██████  
       ░██████████  ░░░░░███ ░░███ ░░███░░███ ░░░░░███ 
       ░███░░░░░░    ███████  ░███  ░███ ░███  ███████ 
       ░███         ███░░███  ░███  ░███ ░███ ███░░███ 
       █████       ░░████████ █████ ░███████ ░░████████
      ░░░░░         ░░░░░░░░ ░░░░░  ░███░░░   ░░░░░░░░ 
                                    ░███               
                                    █████              
                                   ░░░░░         
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

library PaipaLibrary {
    error InvalidBytesLength();
    error InvalidDataOffset();

    function bytesToUint256(bytes memory _bytes) public pure returns (uint256 result) {
        if (_bytes.length < 32)
            revert InvalidBytesLength();

        assembly {
            result := mload(add(_bytes, 0x20))
        }
    }

    // TODO: need some kind of guard to make sure bytes isn't bigger than 32 bytes
    function getSlice(bytes memory data, uint256 intervalIndex) public pure returns (bytes32) {
        uint256 start = intervalIndex * 32;

        if(start + 32 > data.length)
            revert InvalidDataOffset();

        bytes32 slice;

        assembly {
            slice := mload(add(data, add(start, 32)))
        }

        return slice;
    }
}
