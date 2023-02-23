const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("tokenContract testing ", () => {
  beforeEach(async () => {
    [owner, signer1, signer2, admin] = await ethers.getSigners();

    const TokenContract = await ethers.getContractFactory("TokenContract");
    token = await TokenContract.deploy();
    await token.deployed();

    await token.initialize("GNEXSolu", "Gnex");

    await token.adminRole(owner.address);
  });

  it("check basic functions", async () => {
    expect(await token.name()).to.equal("GNEXSolu");
    expect(await token.symbol()).to.equal("Gnex");
  });
  //mint function

  it("checking mint ", async () => {
    await token.mint(signer1.address, 100);
    expect(await token.balanceOf(signer1.address)).to.equal(100);
  });

  it("mint function if user blacklisted", async () => {
    await token.addBlackList(signer1.address, true);

    expect(token.mint(signer1.address, 100)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );

    await token.addBlackListBatch([owner.address, signer2.address]);

    expect(token.mint(signer1.address, 100)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });

  it("mint function only admin", async () => {
    await token.adminRole(signer1.address);
    expect(token.mint(signer1.address, 100)).to.be.revertedWith("onlyAdmin");
  });

  //burn functions

  it("checking burn ", async () => {
    await token.mint(signer1.address, 100);
    await token.burn(signer1.address, 50);
    expect(await token.balanceOf(signer1.address)).to.equal(50);
  });

  it("burn function if user blacklisted", async () => {
    await token.addBlackList(signer1.address, true);

    expect(token.burn(signer1.address, 100)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );

    await token.addBlackListBatch([owner.address, signer2.address]);

    expect(token.burn(signer1.address, 100)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });

  it("burn function only admin", async () => {
    await token.adminRole(signer1.address);
    expect(token.burn(signer1.address, 100)).to.be.revertedWith("onlyAdmin");
  });
  //transfer functionality
  it("transfer Function ", async () => {
    await token.mint(owner.address, 1000);

    await token.transfer(signer1.address, 100);
    expect(await token.balanceOf(signer1.address)).to.be.equal(100);
  });

  it("transfer Function if user blacklisted", async () => {
    await token.mint(owner.address, 1000);

    await token.addBlackList(signer1.address, true);

    expect(token.transfer(signer1.address, 100)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });

  it("transfer Function if user blacklisted", async () => {
    await token.mint(owner.address, 1000);

    await token.addBlackList(owner.address, true);

    expect(
      token.connect(owner).transfer(signer1.address, 100)
    ).to.be.revertedWith("Blacklistable: account is blacklisted");
  });

  it("transfer Function Insufficient balance", async () => {
    await token.mint(owner.address, 1000);

    await token.freezeTokens(owner.address, 1000);

    expect(
      token.connect(owner).transfer(signer1.address, 100)
    ).to.be.revertedWith("Insufficient Balance");
  });

  //transfer from functionality
  it("transferfrom Function ", async () => {
    await token.mint(owner.address, 1000);
    await token.approve(owner.address, 1000);
    await token
      .connect(owner)
      .transferFrom(owner.address, signer1.address, 100);
    expect(await token.balanceOf(signer1.address)).to.be.equal(100);
  });

  it("transferFrom Function if user blacklisted", async () => {
    await token.mint(owner.address, 1000);

    await token.addBlackList(signer1.address, true);

    expect(
      token.transferFrom(owner.address, signer1.address, 100)
    ).to.be.revertedWith("Blacklistable: account is blacklisted");
  });

  it("transferFrom Function if user blacklisted", async () => {
    await token.mint(owner.address, 1000);

    await token.addBlackList(owner.address, true);

    expect(
      token.connect(owner).transferFrom(owner.address, signer1.address, 100)
    ).to.be.revertedWith("Blacklistable: account is blacklisted");
  });

  it("transferFrom Function Insufficient balance", async () => {
    await token.mint(owner.address, 1000);

    await token.freezeTokens(owner.address, 1000);

    expect(
      token.connect(owner).transferFrom(owner.address, signer1.address, 100)
    ).to.be.revertedWith("Insufficient Balance");
  });

  //freezeTokens

  it("testing freeze tokens function", async () => {
    await token.mint(signer1.address, 1000);

    await token.freezeTokens(signer1.address, 100);

    expect(await token.getFreezeAmount(signer1.address)).to.be.equal(100);
  });

  it("testing freezetokens when amount exceed", async () => {
    await token.mint(signer1.address, 1000);

    expect(token.freezeTokens(signer1.address, 1001)).to.be.revertedWith(
      "Amount exceeds available balance"
    );
  });

  it("testing freezetokens when user blacklisted", async () => {
    await token.mint(signer1.address, 1000);
    await token.addBlackList(owner.address, true);

    expect(token.freezeTokens(signer1.address, 1001)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });
  it("testing freezetokens when msg.sender blacklisted", async () => {
    await token.mint(signer1.address, 1000);
    await token.addBlackList(owner.address, true);

    expect(token.freezeTokens(signer1.address, 1001)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });
  it("testing freezetokens when called by nonAdmin ", async () => {
    await token.mint(signer1.address, 1000);

    await token.adminRole(signer1.address);

    expect(token.freezeTokens(signer1.address, 1001)).to.be.revertedWith(
      "onlyAdmin"
    );
  });

  //unfreezeTokens

  it("testing Unfreeze tokens function", async () => {
    await token.mint(signer1.address, 1000);

    await token.freezeTokens(signer1.address, 100);

    expect(await token.getFreezeAmount(signer1.address)).to.be.equal(100);
    await token.unfreezeTokens(signer1.address, 50);
    expect(await token.getFreezeAmount(signer1.address)).to.be.equal(50);
  });

  it("testing unfreezetokens when amount exceed", async () => {
    await token.mint(signer1.address, 1000);
    await token.freezeTokens(signer1.address, 100);
    expect(token.unfreezeTokens(signer1.address, 101)).to.be.revertedWith(
      "Amount should be less than or equal to frozen tokens"
    );
  });

  it("testing unfreezetokens when user blacklisted", async () => {
    await token.mint(signer1.address, 1000);
    await token.addBlackList(signer1.address, true);

    expect(token.unfreezeTokens(signer1.address, 10)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });
  it("testing freezetokens when msg.sender blacklisted", async () => {
    await token.mint(signer1.address, 1000);
    await token.addBlackList(owner.address, true);

    expect(token.unfreezeTokens(signer1.address, 1001)).to.be.revertedWith(
      "Blacklistable: account is blacklisted"
    );
  });
  it("testing unfreezetokens when called by nonAdmin ", async () => {
    await token.mint(signer1.address, 1000);

    await token.adminRole(signer1.address);

    expect(token.freezeTokens(signer1.address, 10)).to.be.revertedWith(
      "onlyAdmin"
    );
  });

  //getFreezeAmount

  it("testing getFreezeAmount tokens function", async () => {
    await token.mint(signer1.address, 1000);

    await token.freezeTokens(signer1.address, 100);

    expect(await token.getFreezeAmount(signer1.address)).to.be.equal(100);
  });

  it("testing getFreezeAmount when called by nonAdmin ", async () => {
    await token.mint(signer1.address, 1000);

    await token.adminRole(signer1.address);

    expect(token.getFreezeAmount(signer1.address)).to.be.revertedWith(
      "onlyAdmin"
    );
  });

  
});
