// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IOffChainStrategy {
    event AgentWithdraw(uint256 assets, uint256 totalIdle, uint256 totalDebt);
    event AgentDeposit(uint256 assets, uint256 totalIdle, uint256 totalDebt);
    event AssetUpdated(uint256 totalIdle, uint256 totalDebt);

    function agentWithdraw(uint256 assets) external;
    function agentDeposit(uint256 assets) external;
    function updateDebt(uint256 profit, uint loss) external;
}
