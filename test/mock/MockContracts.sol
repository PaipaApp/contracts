// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract MockContract0 {
    uint256 public counter;

    function getCounter() external view returns (uint) {
        return counter;
    }

    function count() public {
        counter += 1;
    }
}

contract MockContract1 {
    bool public locked;
    
    function toggleLock() public {
        locked = !locked;
    }

    function getLocked() external view returns (bool) {
        return locked;
    }
}

