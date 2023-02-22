const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("CHECK FACTORY CONTRACT",()=>{

  let owner,signer1,signer2,admin,factory;


  beforeEach(async()=>{

    [owner,signer1,signer2,admin] = await ethers.getSigners();

  
    const TokenContract = await ethers.getContractFactory("TokenContract");
    token= await TokenContract.deploy();
    await token.deployed();
    console.log("im here")  
  
      const FactoryContract = await ethers.getContractFactory("FactoryContract");
      factory= await FactoryContract.deploy(token.address);
      await factory.deployed();
     

  })


  it("testing CreateToken... ",async()=>{
     
    
    await factory.connect(owner).adminRole(admin.address);
    const tokenAddress = await factory.connect(admin).CreateToken("OneSolutions","onex",18,10000000000000);
    const tokenAddress1 = await factory.connect(admin).CreateToken("TwoSolutions","twox",18,10000000000000);

    // console.log(await factory.tokensRegistered());
    const tokensCreated = await factory.tokensRegistered();


    expect(tokensCreated.length).to.equal(2);




  })

})

