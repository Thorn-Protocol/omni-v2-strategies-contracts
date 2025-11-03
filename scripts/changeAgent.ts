import { ethers } from "hardhat";
import { OffChainStrategy__factory } from "../typechain-types";

async function main() {
  let vault = OffChainStrategy__factory.connect("0x00aa576bfa5f75BC6C651e8Cb587dD78b287040A", ethers.provider);

  let governance = await vault.governance();
  console.log(" governance", governance);
  let wallet = new ethers.Wallet(process.env.DEPLOYER!, ethers.provider);
  const nonce = await ethers.provider.getTransactionCount(wallet.address, "latest");
  let tx = await vault.connect(wallet).changeAgent("0x662Db28dEB8F649521262fB58C69D87b830e8276", { nonce });
  let receipt = await tx.wait();
  console.log(" receipt", receipt?.hash);
}

main();
