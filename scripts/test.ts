import { ethers } from "hardhat";
import { OffChainStrategy__factory } from "../typechain-types";

async function main() {
  let vault = OffChainStrategy__factory.connect("0xE049bdA7B0Ebb039C18671E13A65b4cfd6c8FaE5", ethers.provider);

  let agent = await vault.agent();
  console.log(" agent", agent);
}

main();
