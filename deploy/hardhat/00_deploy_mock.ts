import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { addresses } from "../../utils/address";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log(`Deployer: ${deployer}`);

  const usdc = await deploy("USDC", {
    contract: "ERC20Mintable",
    from: deployer,
    args: ["USDC", "USDC", 6],
    log: true,
  });

  await deploy("MockVault", {
    contract: "MockVault",
    from: deployer,
    args: [usdc.address],
    log: true,
  });
};
deploy.tags = ["mock"];
export default deploy;
