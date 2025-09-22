import { ethers } from "hardhat";
import { OffChainStrategy__factory } from "../typechain-types";

async function main() {
  let vault = OffChainStrategy__factory.connect("0xD2a9dB8f22707166e82EdF89534340237780eDA3", ethers.provider);

  let governance = await vault.governance();
  console.log(" governance", governance);
  let wallet = new ethers.Wallet(process.env.DEPLOYER!, ethers.provider);
  let tx = await vault.connect(wallet).changeAgent("0x662Db28dEB8F649521262fB58C69D87b830e8276");
  let receipt = await tx.wait();
  console.log(" receipt", receipt?.hash);
}

main();
