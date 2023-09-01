// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract MockContract0 {
    uint256 public counter;

    function getCounter() external view returns (uint256) {
        return counter;
    }

    function count() public {
        counter += 1;
    }

    function increment(uint256 _amount) public {
        counter += _amount;
    }
}

contract MockContract1 {
    bool public locked;
    
    function toggleLock() public {
        locked = !locked;
    }

    function getLocked() public view returns (bool) {
        return locked;
    }

    function setLock(bool _locked) public {
        locked = _locked;
    }

    function getNumber() external pure returns (uint256) {
        return 1e18;
    }
}


