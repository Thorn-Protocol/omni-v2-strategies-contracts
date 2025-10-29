// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockVault {
    address public asset;
    address strategy;

    constructor(address _asset) {
        asset = _asset;
    }

    function setStrategy(address _strategy) public {
        strategy = _strategy;
    }

    function deposit(uint256 amount) public returns (uint256) {
        IERC20(asset).approve(strategy, amount);
        return IERC4626(strategy).deposit(amount, address(this));
    }

    function mint(uint256 amount) public returns (uint256) {
        IERC20(asset).approve(strategy, amount);
        return IERC4626(strategy).mint(amount, address(this));
    }
}
