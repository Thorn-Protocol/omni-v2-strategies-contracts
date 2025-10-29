// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IOffChainStrategy} from "./interfaces/IOffChainStrategy.sol";

contract OffChainStrategy is IOffChainStrategy, ERC4626 {
    address public immutable vault;
    address public governance;
    address public agent;
    uint256 public totalIdle;
    uint256 public totalDebt;

    modifier onlyAgent() {
        require(msg.sender == agent, "Only agent can call this function");
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "Only vault can call this function");
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
        string memory _symbol,
        address _vault
    ) ERC4626(_asset) ERC20(_name, _symbol) {
        governance = msg.sender;
        vault = _vault;
    }

    // override ERC4626 functions
    function deposit(
        uint256 assets,
        address receiver
    ) public override onlyVault returns (uint256) {
        return super.deposit(assets, receiver);
    }

    function mint(
        uint256 shares,
        address receiver
    ) public override onlyVault returns (uint256) {
        return super.mint(shares, receiver);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override onlyVault returns (uint256) {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override onlyVault returns (uint256) {
        return super.redeem(shares, receiver, owner);
    }

    /**
     * @dev Returns the total amount of assets managed by this strategy
     * @return The sum of idle assets and debt
     */
    function totalAssets() public view override returns (uint256) {
        return totalIdle + totalDebt;
    }

    /**
     * @dev Returns the maximum amount of assets that can be withdrawn by the owner
     * @param owner The address of the owner
     * @return The maximum amount of assets that can be withdrawn
     */
    function maxWithdraw(
        address owner
    ) public view override onlyVault returns (uint256) {
        return
            Math.min(
                _convertToAssets(balanceOf(owner), Math.Rounding.Floor),
                totalIdle
            );
    }

    /**
     * @dev Returns the maximum amount of shares that can be redeemed by the owner
     * @param owner The address of the owner
     * @return The maximum amount of shares that can be redeemed
     */
    function maxRedeem(
        address owner
    ) public view override onlyVault returns (uint256) {
        return
            Math.min(
                balanceOf(owner),
                _convertToShares(totalIdle, Math.Rounding.Floor)
            );
    }

    /**
     * @dev Internal function to handle deposits
     * @param caller The address calling the deposit function
     * @param receiver The address receiving the shares
     * @param assets The amount of assets being deposited
     * @param shares The amount of shares being minted
     */
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal override onlyVault {
        super._deposit(caller, receiver, assets, shares);
        totalIdle += assets;
        emit AssetUpdated(totalIdle, totalDebt);
    }

    /**
     * @dev Internal function to handle withdrawals
     * @param caller The address calling the withdraw function
     * @param receiver The address receiving the assets
     * @param owner The address that owns the shares
     * @param assets The amount of assets being withdrawn
     * @param shares The amount of shares being burned
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override onlyVault {
        super._withdraw(caller, receiver, owner, assets, shares);
        totalIdle -= assets;
        emit AssetUpdated(totalIdle, totalDebt);
    }

    /**
     * @dev Converts shares to assets with specified rounding
     * @param shares The amount of shares to convert
     * @param rounding The rounding mode to use
     * @return The equivalent amount of assets
     */
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

    /**
     * @dev Converts assets to shares with specified rounding
     * @param assets The amount of assets to convert
     * @param rounding The rounding mode to use
     * @return The equivalent amount of shares
     */
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

    /**
     * @dev Allows the agent to withdraw assets from the strategy
     * @param assets The amount of assets to withdraw
     */
    function agentWithdraw(uint256 assets) public onlyAgent onlyVault {
        totalIdle -= assets;
        totalDebt += assets;
        IERC20(asset()).transfer(agent, assets);
        emit AssetUpdated(totalIdle, totalDebt);
        emit AgentWithdraw(assets, totalIdle, totalDebt);
    }

    /**
     * @dev Allows the agent to deposit assets back to the strategy
     * @param assets The amount of assets to deposit
     */
    function agentDeposit(uint256 assets) public onlyAgent onlyVault {
        totalIdle += assets;
        totalDebt -= Math.min(assets, totalDebt);
        IERC20(asset()).transferFrom(agent, address(this), assets);
        emit AssetUpdated(totalIdle, totalDebt);
        emit AgentDeposit(assets, totalIdle, totalDebt);
    }

    /**
     * @dev Updates the debt based on profit or loss from off-chain strategy
     * @param profit The amount of profit to add to debt (must be 0 if loss > 0)
     * @param loss The amount of loss to subtract from debt (must be 0 if profit > 0)
     */
    function updateDebt(uint256 profit, uint loss) public onlyAgent onlyVault {
        require(profit == 0 || loss == 0, "Profit and loss must be 0");
        if (profit > 0) {
            totalDebt += profit;
        } else {
            totalDebt -= loss;
        }
        emit AssetUpdated(totalIdle, totalDebt);
    }

    /**
     * @dev Changes the agent address (only governance can call this)
     * @param newAgent The new agent address
     */
    function changeAgent(address newAgent) public onlyGovernance onlyVault {
        agent = newAgent;
        emit AgentChanged(newAgent);
    }

    /**
     * @dev Changes the governance address (only governance can call this)
     * @param newGovernance The new governance address
     */
    function changeGovernance(
        address newGovernance
    ) public onlyGovernance onlyVault {
        governance = newGovernance;
        emit GovernanceChanged(newGovernance);
    }
}
