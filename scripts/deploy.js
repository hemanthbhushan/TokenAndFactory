const BN = require("ethers").BigNumber;
const { ethers } = require("hardhat");

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function main() {
  const [deployer] = await ethers.getSigners();
  const { chainId } = await ethers.provider.getNetwork();

  const owner = "0x14ef97a0a27EeDDFd9A1499FD7ef99b52F8C7452";
  console.log("im here");

  const FactoryContract = await ethers.getContractFactory("FactoryContract");

  const TokenContract = await ethers.getContractFactory("TokenContract");
  const OwnedUpgradeabilityProxy = await ethers.getContractFactory(
    "OwnedUpgradeabilityProxy"
  );

  let factory = await FactoryContract.deploy();
  console.log("FactoryContract address", factory.address);
  await sleep(6000);

  let token = await TokenContract.deploy();
  console.log("TokenContract address", token.address);
  await sleep(6000);
 

  let proxy = await OwnedUpgradeabilityProxy.deploy();
  console.log("proxy address", proxy.address);
  await sleep(6000);

  await proxy.upgradeTo(factory.address);
  await sleep(6000);

  let proxy1 = FactoryContract.attach(proxy.address);
  console.log("proxy1", proxy1.address);
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
