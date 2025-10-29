import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { addresses } from "../../utils/address";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute, get } = deployments;
  const { deployer } = await getNamedAccounts();

  let usdc = await get("USDC");
  let mockVault = await get("MockVault");
  let vault = await deploy("OffChainStrategy", {
    contract: "OffChainStrategy",
    from: deployer,
    args: [usdc.address, "OffChain Omni USDC", "omni USDC", mockVault.address],
    log: true,
  });
};
deploy.tags = ["off-chain-strategy"];
export default deploy;
