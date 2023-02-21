// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

 contract FactoryContract is Ownable{
    
     address public implementation; 
   
     address public adminAddress;



     struct TokenDetails{
        string name;
        string symbol;
        uint8 decimals;
        uint256 initialSupply;
    }

    address[] public storeAddress;
   mapping(address=>TokenDetails) public registerToken;
   mapping(address=>bool) public registered;

    event tokenRegistered(
        address indexed tokenAddress,
        TokenDetails indexed tokenDetails
    );

    event tokenUnregistered(
        address indexed tokenAddress,
        string indexed name,
        string indexed symbol
    );


      modifier onlyAdmin() {
        require(adminAddress == msg.sender, "onlyAdmin");
        _;
    }

    
    constructor(address _implementation){
        
       
         implementation = _implementation;
    }
 

    function adminRole(address _adminAddress) public onlyOwner {
        adminAddress = _adminAddress;
    }



    function CreateERC20Token(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) external onlyAdmin returns (address tokenAddress) {

         tokenAddress = Clones.clone(implementation);
        registerTokens(TokenDetails({name:_name,symbol:_symbol,decimals:_decimals,initialSupply: _initialSupply}),address(tokenAddress));

        
        return tokenAddress;
    }


     
    function registerTokens(TokenDetails memory tokenDetails,address _tokenAddress) public onlyAdmin  {

        require(_tokenAddress!= address(0) ,"invalid Token address");
        require(!registered[_tokenAddress],"token address is already registered");

        registerToken[_tokenAddress] = TokenDetails({
            name:tokenDetails.name,
            symbol:tokenDetails.symbol,
            decimals:tokenDetails.decimals,
            initialSupply:tokenDetails.initialSupply
        });
        registered[_tokenAddress] = true; 
        storeAddress.push(_tokenAddress);


        emit tokenRegistered(_tokenAddress,tokenDetails);
    }

     function unregisterTokens(address _tokenAddress) external onlyOwner  {

        require(_tokenAddress!= address(0) ,"invalid Token address");
        require(registered[_tokenAddress],"token address is not registered");
        

         TokenDetails memory details = registerToken[_tokenAddress];

         

         delete registerToken[_tokenAddress]; 


        emit tokenUnregistered(_tokenAddress,details.name,details.symbol);

    }

     function transferOwnershipOnTokenContract(address _newOwner) external  onlyAdmin {
        transferOwnership(_newOwner);
    }


 }
