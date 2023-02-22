// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "./BasicMetaTransaction.sol";
import "./interfaces/IToken.sol";
import "hardhat/console.sol";

contract FactoryContract is BasicMetaTransaction, Ownable {
    address public implementation;

    address public adminAddress;

    struct TokenDetails {
        string name;
        string symbol;
        uint8 decimals;
        uint256 initialSupply;
        address tokenAddress;
    }

    TokenDetails[] public storeTokenDetails;
    mapping(address => TokenDetails) public registerToken;
    mapping(address => bool) public registered;

    event tokenRegistered(
        address indexed tokenAddress,
        TokenDetails indexed tokenDetails
    );
     event TokenCreated(
        string name,
        string symbol,
        address tokenAddress
    );
    event tokenUnregistered(
        address indexed tokenAddress,
        string indexed name,
        string indexed symbol
    );

    modifier onlyAdmin() {
        require(adminAddress == msgSender(), "onlyAdmin");
        _;
    }

    constructor(address _implementation) {
        implementation = _implementation;
        adminAddress = msg.sender;
    }

    function adminRole(address _adminAddress) external onlyOwner {
        adminAddress = _adminAddress;
    }

    //    function _initialize(address tokenAddress ,string memory _name, string memory _symbol) public {
    //     IERC20(tokenAddress)._initialize(_name, _symbol);

    //    }

    function createToken(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) external onlyAdmin returns (address _tokenAddress) {
        _tokenAddress = Clones.clone(implementation);
        console.log(_tokenAddress, "token address");
        // IERC20(_tokenAddress).initialize(_name, _symbol);
        console.log("in side contract");

        registerTokens(
            TokenDetails({
                name: _name,
                symbol: _symbol,
                decimals: _decimals,
                initialSupply: _initialSupply,
                tokenAddress: _tokenAddress
            }),
            address(_tokenAddress)
        );
        emit TokenCreated(_name, _symbol,_tokenAddress);
        return _tokenAddress;
    }

    function registerTokens(
        TokenDetails memory tokenDetails,
        address _tokenAddress
    ) public onlyAdmin {
        require(_tokenAddress != address(0), "invalid Token address");
        require(
            !registered[_tokenAddress],
            "token address is already registered"
        );

        registerToken[_tokenAddress] = TokenDetails({
            name: tokenDetails.name,
            symbol: tokenDetails.symbol,
            decimals: tokenDetails.decimals,
            initialSupply: tokenDetails.initialSupply,
            tokenAddress: tokenDetails.tokenAddress
        });
        registered[_tokenAddress] = true;

        storeTokenDetails.push(registerToken[_tokenAddress]);

        emit tokenRegistered(_tokenAddress, tokenDetails);
    }

    function unregisterTokens(address _tokenAddress) external onlyAdmin {
        require(_tokenAddress != address(0), "invalid Token address");
        require(registered[_tokenAddress], "token address is not registered");

        TokenDetails memory details = registerToken[_tokenAddress];

        for (uint256 i = 0; i < storeTokenDetails.length; i++) {
            if (storeTokenDetails[i].tokenAddress == _tokenAddress) {
                storeTokenDetails[i] = storeTokenDetails[
                    storeTokenDetails.length - 1
                ];
                storeTokenDetails.pop();
            }
        }

        delete registerToken[_tokenAddress];

        emit tokenUnregistered(_tokenAddress, details.name, details.symbol);
    }

    function getTokenDetails(
        address _tokenAddress
    ) public view returns (TokenDetails memory) {
        return registerToken[_tokenAddress];
    }

    function tokensRegistered() public view returns (TokenDetails[] memory) {
        return storeTokenDetails;
    }
}
