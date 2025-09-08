import { ethers } from "hardhat";
import { OffChainStrategy__factory } from "../typechain-types";

async function main() {
  let vault = OffChainStrategy__factory.connect("0xE049bdA7B0Ebb039C18671E13A65b4cfd6c8FaE5", ethers.provider);

  let governance = await vault.governance();
  console.log(" governance", governance);
  let wallet = new ethers.Wallet(process.env.DEPLOYER!, ethers.provider);
  let tx = await vault.connect(wallet).changeAgent("0x1D51e9BCD82bEF1846778c9743460A53dB723192");
  let receipt = await tx.wait();
  console.log(" receipt", receipt?.hash);
}

main();
