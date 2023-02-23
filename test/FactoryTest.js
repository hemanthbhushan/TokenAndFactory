const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("CHECK FACTORY CONTRACT", () => {
  let owner, signer1, signer2, admin, factory;

  beforeEach(async () => {
    [owner, signer1, signer2, admin] = await ethers.getSigners();

    const TokenContract = await ethers.getContractFactory("TokenContract");
    token = await TokenContract.deploy();
    await token.deployed();
    console.log("im here");

    const FactoryContract = await ethers.getContractFactory("FactoryContract");
    factory = await FactoryContract.deploy(token.address);
    await factory.deployed();

    await factory.connect(owner).adminRole(admin.address);
  });

  it.only("testing createToken... ", async () => {
    const tokenAddress = await factory
      .connect(admin)
      .createToken("OneSolutions", "onex", 18, 10000000000000);

    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000);

    console.log(await factory.tokensRegistered());
    const tokensCreated = await factory.tokensRegistered();
    // expect(tokensCreated.length).to.equal(2);

    let receipt = await tokenAddress1.wait();
    const event = receipt.events?.filter((x) => {
      return x.event == "TokenCreated";
    });
    console.log("events", event[0].args);
    tokenAttached = await token.attach(event[0].args.tokenAddress);
    console.log("New Token :>> ", tokenAttached.address);
    tokenAttached = await token.attach(event[0].args.tokenAddress);
    
    

  });

  it("testing register function ", async () => {
    await factory.connect(admin).registerTokens(
      {
        name: "GenxSoultion",
        symbol: "Genx",
        decimals: 18,
        initialSupply: 10000000,
        tokenAddress: "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e",
      },
      "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e"
    );

    const tokensCreated = await factory.tokensRegistered();

    expect(tokensCreated.length).to.equal(1);
  });

  it("testing unRegister function ", async () => {
    await factory.connect(admin).registerTokens(
      {
        name: "GenxSoultion",
        symbol: "Genx",
        decimals: 18,
        initialSupply: 10000000,
        tokenAddress: "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e",
      },
      "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e"
    );

    const tokensCreated = await factory.tokensRegistered();

    expect(tokensCreated.length).to.equal(1);

    await factory
      .connect(admin)
      .unregisterTokens("0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e");
    const tokensCreated1 = await factory.tokensRegistered();

    expect(tokensCreated1.length).to.equal(0);
  });

  it("check getTokenDetails function", async () => {
    const tokenAddress = await factory
      .connect(admin)
      .createToken("OneSolutions", "onex", 18, 10000000000000);

    const token = await factory.tokensRegistered();

    console.log(
      await factory.getTokenDetails(
        "0xCafac3dD18aC6c6e92c921884f9E4176737C052c"
      )
    );

    await factory
      .connect(admin)
      .unregisterTokens("0xCafac3dD18aC6c6e92c921884f9E4176737C052c");

    console.log(
      await factory.getTokenDetails(
        "0xCafac3dD18aC6c6e92c921884f9E4176737C052c"
      ),
      "afterrrrrrr"
    );
  });

  it("check Admin role", async () => {
    expect(
      factory.registerTokens(
        {
          name: "GenxSoultion",
          symbol: "Genx",
          decimals: 18,
          initialSupply: 10000000,
          tokenAddress: "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e",
        },
        "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e"
      )
    ).to.be.revertedWith("onlyAdmin");

    expect(
      factory.registerTokens("0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e")
    ).to.be.revertedWith("onlyAdmin");

    expect(
      factory.createToken("OneSolutions", "onex", 18, 10000000000000)
    ).to.be.revertedWith("onlyAdmin");
  });
});
