import { ethers } from "hardhat";
import { OffChainStrategy__factory } from "../typechain-types";

async function main() {
  let vault = OffChainStrategy__factory.connect("0x00aa576bfa5f75BC6C651e8Cb587dD78b287040A", ethers.provider);

  let agent = await vault.agent();
  console.log(" agent", agent);
}

main();
