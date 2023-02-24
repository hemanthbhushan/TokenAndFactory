const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("CHECK FACTORY CONTRACT", () => {
  let owner, signer1, signer2, admin, factory;

  beforeEach(async () => {
    [owner, signer1, signer2, admin] = await ethers.getSigners();

    const TokenContract = await ethers.getContractFactory("TokenContract");
    token = await TokenContract.deploy();
    await token.deployed();

    const FactoryContract = await ethers.getContractFactory("FactoryContract");
    factory = await FactoryContract.deploy();
    await factory.deployed();
    await factory.initialize(token.address);

    await factory.connect(owner).addAdminRole(admin.address);
  });

  it("testing createToken... ", async () => {
    const tokenAddress = await factory
      .connect(admin)
      .createToken("OneSolutions", "onex", 18, 10000000000000, admin.address);

    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000, admin.address);

    // console.log(await factory.tokensRegistered());
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
    const tokensCreated = await factory.tokensRegistered();
    // expect(tokensCreated.length).to.equal(2);

    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000, admin.address);

    let receipt = await tokenAddress1.wait();
    const event = receipt.events?.filter((x) => {
      return x.event == "TokenCreated";
    });
    console.log("events", event[0].args);
    tokenAttached = await token.attach(event[0].args.tokenAddress);

    const tokenscreated = await factory.tokensRegistered();

    expect(tokenscreated.length).to.equal(1);

    await factory.connect(admin).unregisterTokens(tokenAttached.address);
    const tokenscreated1 = await factory.tokensRegistered();

    expect(tokenscreated1.length).to.equal(0);
  });

  it("check getTokenDetails function", async () => {
    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000, admin.address);

    let receipt = await tokenAddress1.wait();
    const event = receipt.events?.filter((x) => {
      return x.event == "TokenCreated";
    });
    console.log("events", event[0].args);
    tokenAttached = await token.attach(event[0].args.tokenAddress);

    console.log(await factory.getTokenDetails(tokenAttached.address), "before");

    await factory.connect(admin).unregisterTokens(tokenAttached.address);

    console.log(
      await factory.getTokenDetails(tokenAttached.address),
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

  //tokenMint

  it("testing tokenMint", async () => {
    // await tokenAddress1.addAdminRole(factory.address)
    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000, admin.address);

    let receipt = await tokenAddress1.wait();
    const event = receipt.events?.filter((x) => {
      return x.event == "TokenCreated";
    });

    tokenAttached = await token.attach(event[0].args.tokenAddress);

    await factory
      .connect(admin)
      .tokenMint(tokenAttached.address, signer1.address, 100);

    const balance = await factory
      .connect(admin)
      .tokenBalance(tokenAttached.address, signer1.address);

    expect(balance).to.be.equal(100);
  });

  // tokenTransfer

  it.only("testing tokenTransfer", async () => {
    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000, admin.address);

    let receipt = await tokenAddress1.wait();
    const event = receipt.events?.filter((x) => {
      return x.event == "TokenCreated";
    });

    tokenAttached = await token.attach(event[0].args.tokenAddress);

    await factory
      .connect(admin)
      .tokenMint(tokenAttached.address, factory.address, 100);

    const balance1 = await factory.tokenBalance(
      tokenAttached.address,
      admin.address
    );

    console.log("balance1", balance1);

    await factory
      .connect(admin)
      .tokenTransfer(tokenAttached.address, signer1.address, 50);

    const balance = await factory.tokenBalance(
      tokenAttached.address,
      signer1.address
    );
    console.log("balance", balance);
    expect(balance).to.be.equal(50);
  });
  it.only("testing tokenTransferFrom", async () => {
    const tokenAddress1 = await factory
      .connect(admin)
      .createToken("TwoSolutions", "twox", 18, 10000000000000, admin.address);

    let receipt = await tokenAddress1.wait();
    const event = receipt.events?.filter((x) => {
      return x.event == "TokenCreated";
    });

    tokenAttached = await token.attach(event[0].args.tokenAddress);

    await factory
      .connect(admin)
      .tokenMint(tokenAttached.address, factory.address, 100);

    const balance1 = await factory.tokenBalance(
      tokenAttached.address,
      admin.address
    );

    console.log("balance1", balance1);

    await factory
      .connect(admin)
      .tokenTransferFrom(tokenAttached.address,factory.address ,signer1.address, 50);

    const balance = await factory.tokenBalance(
      tokenAttached.address,
      signer1.address
    );
    console.log("balance", balance);
    expect(balance).to.be.equal(50);
  });

});
