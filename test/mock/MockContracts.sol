// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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
        _mint(msg.sender, 100000000e18);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}

contract MockFeeToken is ERC20("Mock Fee Token", "FEE") {
    address minter;

    constructor() {
        _mint(msg.sender, 100e18);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
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

        // @dev Mint 1% of the balance
        MockToken(address(mockToken)).mint(msg.sender, balances[msg.sender] * 100 / 10_000);
    }

    function stakeBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }
}

// @dev USD/ETH mock price feed fixed at U$ 2000.00
contract MockPriceFeed is AggregatorV3Interface {
    uint8 public decimals;
    string public description;
    uint256 public version;
    // @dev this variable is used to manipulate the price of the pair
    // during the tests
    int256 internal ethUsdPrice;

    constructor() {
        decimals = 8;
        description = "ETH/USD price feed";
        version = 1;
        ethUsdPrice = 200000000000; // USD/ETH at U$ 2k/ETH
    }

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) {
        return (
            _roundId,
            ethUsdPrice,
            1700834135,
            1700834135,
            110680464442257317888
        );
    }

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) {
        return (
            110680464442257317888,
            ethUsdPrice,
            1700834135,
            1700834135,
            110680464442257317888
        );
    }

    function setPrice(int256 _price) external {
        ethUsdPrice = _price;
    }
}
