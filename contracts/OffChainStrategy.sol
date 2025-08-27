// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IOffChainStrategy} from "./interfaces/IOffChainStrategy.sol";

contract OffChainStrategy is IOffChainStrategy, ERC4626 {
    address public governance;
    address public agent;
    uint256 public totalIdle;
    uint256 public totalDebt;

    modifier onlyAgent() {
        require(msg.sender == agent, "Only agent can call this function");
        _;
    }

    modifier onlyGovernance() {
        require(
            msg.sender == governance,
            "Only governance can call this function"
        );
        _;
    }

    constructor(
        IERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) ERC20(_name, _symbol) {
        governance = msg.sender;
    }

    function totalAssets() public view override returns (uint256) {
        return totalIdle + totalDebt;
    }

    function maxWithdraw(address owner) public view override returns (uint256) {
        return
            Math.min(
                _convertToAssets(balanceOf(owner), Math.Rounding.Floor),
                totalIdle
            );
    }

    function maxRedeem(address owner) public view override returns (uint256) {
        return
            Math.min(
                balanceOf(owner),
                _convertToShares(totalIdle, Math.Rounding.Floor)
            );
    }

    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal override {
        super._deposit(caller, receiver, assets, shares);
        totalIdle += assets;
        emit AssetUpdated(totalIdle, totalDebt);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override {
        super._withdraw(caller, receiver, owner, assets, shares);
        totalIdle -= assets;
        emit AssetUpdated(totalIdle, totalDebt);
    }

    function _convertToAssets(
        uint256 shares,
        Math.Rounding rounding
    ) internal view override returns (uint256) {
        if (shares == type(uint256).max || shares == 0) {
            return shares;
        }

        uint256 _totalSupply = totalSupply();
        uint256 _totalAssets = totalAssets();

        if (_totalSupply == 0) {
            return shares;
        }
        uint256 numerator = shares * _totalAssets;
        uint256 amount = numerator / _totalSupply;
        if (rounding == Math.Rounding.Ceil && numerator % _totalSupply != 0) {
            amount++;
        }
        return amount;
    }

    function _convertToShares(
        uint256 assets,
        Math.Rounding rounding
    ) internal view override returns (uint256) {
        if (assets == type(uint256).max || assets == 0) {
            return assets;
        }

        uint256 _totalSupply = totalSupply();
        uint256 _totalAssets = totalAssets();

        if (_totalSupply == 0) {
            return assets;
        }
        uint256 numerator = assets * _totalSupply;
        uint256 shares = numerator / _totalAssets;
        if (rounding == Math.Rounding.Ceil && numerator % _totalAssets != 0) {
            shares++;
        }
        return shares;
    }

    function agentWithdraw(uint256 assets) public onlyAgent {
        totalIdle -= assets;
        totalDebt += assets;
        IERC20(asset()).transfer(agent, assets);
        emit AssetUpdated(totalIdle, totalDebt);
        emit AgentWithdraw(assets, totalIdle, totalDebt);
    }

    function agentDeposit(uint256 assets) public onlyAgent {
        totalIdle += assets;
        totalDebt -= Math.min(assets, totalDebt);
        IERC20(asset()).transferFrom(agent, address(this), assets);
        emit AssetUpdated(totalIdle, totalDebt);
        emit AgentDeposit(assets, totalIdle, totalDebt);
    }

    function updateDebt(uint256 _totalDebt) public onlyAgent {
        totalDebt = _totalDebt;
        emit AssetUpdated(totalIdle, totalDebt);
    }
}
