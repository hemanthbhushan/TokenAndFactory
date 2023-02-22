const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe('tokenContract testing ', () => { 

    beforeEach(async()=>{

        [owner,signer1,signer2,admin] = await ethers.getSigners();

  
        const TokenContract = await ethers.getContractFactory("TokenContract");
        token= await TokenContract.deploy();
        await token.deployed();

        await token.initialize("GNEXSolu","Gnex");
         
    })


    it("check basic functions",async()=>{
        

        expect(await token.name()).to.equal("GNEXSolu")
        expect(await token.symbol()).to.equal("Gnex")


    })
    //mint function 

    it("checking mint ",async()=>{
         await token.mint(signer1.address,100);
         expect(await token.balanceOf(signer1.address)).to.equal(100);
    })

    it("mint function if user blacklisted",async()=>{

        await token.addBlackList(signer1.address,true);
      
        expect(token.mint(signer1.address,100)).to.be.revertedWith("Blacklistable: account is blacklisted");
        
        await token.addBlackListBatch([owner.address,signer2.address]);
        
        expect(token.mint(signer1.address,100)).to.be.revertedWith("Blacklistable: account is blacklisted");
        

    })

it("mint function only admin",async()=>{ 
    await token.adminRole(signer1.address);
    expect(token.mint(signer1.address,100)).to.be.revertedWith("onlyAdmin");
   
})

//burn functions 

it("checking burn ",async()=>{
    await token.mint(signer1.address,100);
    await token.burn(signer1.address,50);
    expect(await token.balanceOf(signer1.address)).to.equal(50);
})

it("burn function if user blacklisted",async()=>{

    await token.addBlackList(signer1.address,true);
  
    expect(token.burn(signer1.address,100)).to.be.revertedWith("Blacklistable: account is blacklisted");
    
    await token.addBlackListBatch([owner.address,signer2.address]);
    
    expect(token.burn(signer1.address,100)).to.be.revertedWith("Blacklistable: account is blacklisted");
    

})

it("burn function only admin",async()=>{ 
    await token.adminRole(signer1.address);
    expect(token.burn(signer1.address,100)).to.be.revertedWith("onlyAdmin");
   
});

it("transfer Function ",async()=>{

    await token.mint(owner.address,1000);

    await token.transfer(signer1.address,100);
    expect(await token.balanceOf(signer1.address)).to.be.equal(100);
})



   

 })