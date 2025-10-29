import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import {
  ERC20Mintable,
  ERC20Mintable__factory,
  MockVault,
  MockVault__factory,
  OffChainStrategy,
  OffChainStrategy__factory,
} from "../typechain-types";
import hre, { ethers, getNamedAccounts } from "hardhat";
import { expect } from "chai";
describe("OffChainStrategy", () => {
  let strategy: OffChainStrategy;
  let alice: any;
  let governance: any;
  let usdc: ERC20Mintable;
  let mockVault: MockVault;
  const { get } = hre.deployments;
  const provider = ethers.provider;
  before(async () => {
    await hre.deployments.fixture();
    let { deployer, agent, beneficiary } = await getNamedAccounts();
    governance = await hre.ethers.getSigner(deployer);
    alice = new ethers.Wallet(ethers.Wallet.createRandom().privateKey, provider);

    strategy = OffChainStrategy__factory.connect((await get("OffChainStrategy")).address, provider);
    usdc = ERC20Mintable__factory.connect((await get("USDC")).address, provider);
    mockVault = MockVault__factory.connect((await get("MockVault")).address, provider);

    await governance.sendTransaction({
      to: alice.address,
      value: ethers.parseEther("100"),
    });

    await usdc.connect(governance).mint(alice.address, ethers.parseUnits("1000", 6));
    await usdc.connect(governance).mint(await mockVault.getAddress(), ethers.parseUnits("1000", 6));
    await mockVault.connect(governance).setStrategy(await strategy.getAddress());
  });

  it("should deployment success", async () => {});

  describe("deposit", () => {
    it("only vault can call deposit function", async () => {
      let amount = 100_000_000;
      await expect(strategy.connect(alice).deposit(100, alice.address)).to.be.revertedWith(
        "Only vault can call this function"
      );
      await mockVault.connect(alice).deposit(amount);
    });
  });

  describe("mint", () => {
    it("only vault can call mint function", async () => {
      let amount = 100_000_000;
      await expect(strategy.connect(alice).mint(100, alice.address)).to.be.revertedWith(
        "Only vault can call this function"
      );
      await mockVault.connect(alice).mint(amount);
    });
  });
});
