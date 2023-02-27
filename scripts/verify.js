const Hre = require("hardhat");
async function main() {


//   await Hre.run("verify:verify", {
//     //Deployed contract Exchange address
//     address: "0xEF04C11d30eC569Db569B7c3A0f8ab7010ccAE53",
//     //Path of your main contract.
//     contract: "contracts/FactoryContract.sol:FactoryContract",
//   });

//   await Hre.run("verify:verify", {
//     //Deployed contract OwnedUpgradeabilityProxy address
//     address: "0xe921dF5Eaf198C737e4ea587E71cE1d7C92Db6D1",
//     //Path of your main contract.
//     contract: "contracts/upgradability/OwnedUpgradeabilityProxy.sol:OwnedUpgradeabilityProxy",
//   });
  await Hre.run("verify:verify", {
    //Deployed contract OwnedUpgradeabilityProxy address
    address: "0xB13bc7221077C5eD01f9Ff84618892ee332bBd19",
    //Path of your main contract.
    contract: "contracts/TokenContract.sol:TokenContract",
  });
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });