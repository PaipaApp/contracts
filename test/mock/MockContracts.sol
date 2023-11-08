// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

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

contract MockToken is ERC20("Mock Token", "MOCK") {
    address minter;

    constructor() {
        _mint(msg.sender, 100e18);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function approve(address _to, uint256 _amount) public override returns(bool) {
        approve(_to, _amount);
    }
}

contract MockStake {
    IERC20 public mockToken;
    mapping(address => uint256) public balances;

    constructor(IERC20 _mockToken) {
        mockToken = _mockToken;
    }

    function deposit(uint256 _amount) public {
        mockToken.transferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;
    }
    
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] > 0, "User balance is zero");

        balances[msg.sender] -= _amount;

        mockToken.transfer(msg.sender, _amount);
    }

    function collectRewards() public {
        require(balances[msg.sender] > 0, "Nothing to collect");

        // Mint 1% of the balance
        MockToken(address(mockToken)).mint( msg.sender, balances[msg.sender] * 100 / 10_000);
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }
}

