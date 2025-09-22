import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { addresses } from "../../utils/address";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log(`Deployer: ${deployer}`);

  await deploy("OffChainStrategyUsdcV2OnBase", {
    contract: "OffChainStrategy",
    from: deployer,
    args: [addresses.base.usdc, "OffChain Omni USDC", "omni USDC"],
    log: true,
  });

  await execute("OffChainStrategyUsdcV2OnBase", { from: deployer }, "changeAgent", [""]);
};
deploy.tags = ["off-chain-strategy-usdc-v2-on-base"];
export default deploy;
