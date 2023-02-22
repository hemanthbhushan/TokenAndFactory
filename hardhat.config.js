require("@nomicfoundation/hardhat-toolbox");
require("hardhat-contract-sizer");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-truffle5");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",

  contractSizer: {
    alphaSort: false,
    disambiguatePaths: true,
    runOnCompile: true,
    strict: false,
    only: [""],
  },

  etherscan: {
    apiKey: {
      polygonMumbai: `${process.env.MUMBAI_API}`,
    },
  },
};
