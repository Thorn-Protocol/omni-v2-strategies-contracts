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
    proxy: {
      owner: deployer,
      execute: {
        init: {
          methodName: "initialize",
          args: [addresses.base.usdc, "OffChain Omni USDC", "omni USDC", addresses.base.vault],
        },
      },
    },
    log: true,
  });

};
deploy.tags = ["off-chain-strategy-usdc-v2-on-base"];
export default deploy;
