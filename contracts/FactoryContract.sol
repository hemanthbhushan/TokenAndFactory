// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./BasicMetaTransaction.sol";
import "./interfaces/IToken.sol";

// import "hardhat/console.sol";

contract FactoryContract is BasicMetaTransaction, Ownable, Initializable {
    address public masterToken;
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
    event TokenCreated(string name, string symbol, address tokenAddress);
    event tokenUnregistered(
        address indexed tokenAddress,
        string indexed name,
        string indexed symbol
    );

    modifier onlyAdmin() {
        require(adminAddress == _msgSender(), "onlyAdmin");
        _;
    }

    modifier onlyRegistered(address _tokenAddress) {
        require(registered[_tokenAddress], "Token not registered");
        _;
    }

    function initialize(address _masterToken) public initializer {
        masterToken = _masterToken;
        adminAddress = _msgSender();
    }

    function adminRole(address _adminAddress) external onlyOwner {
        adminAddress = _adminAddress;
    }

    function createToken(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) external onlyAdmin returns (address _tokenAddress) {
        _tokenAddress = Clones.clone(masterToken);
        IToken(_tokenAddress).initialize(_name, _symbol, _initialSupply);
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
        emit TokenCreated(_name, _symbol, _tokenAddress);
        return _tokenAddress;
    }

    function tokenTransfer(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external onlyRegistered(_tokenAddress) onlyAdmin {
        IToken(_tokenAddress).transfer(_to, _amount);
    }

    function tokenTransferFrom(
        address _tokenAddress,
        address _from,
        address _to,
        uint256 _amount
    ) external onlyRegistered(_tokenAddress) onlyAdmin {
        IToken(_tokenAddress).transferFrom(_from, _to, _amount);
    }

    function tokenMint(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external onlyRegistered(_tokenAddress) {
        IToken(_tokenAddress).mint(_to, _amount);
    }

    function tokenBurn(
        address _tokenAddress,
        address _userAddress,
        uint256 _amount
    ) external onlyRegistered(_tokenAddress) onlyAdmin {
        IToken(_tokenAddress).burn(_userAddress, _amount);
    } 


    function registerTokens(
        TokenDetails memory tokenDetails,
        address _tokenAddress
    ) public onlyAdmin {
        require(_tokenAddress != address(0), "Invalid Token address");
        require(!registered[_tokenAddress], "Token already registered");

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
        require(_tokenAddress != address(0), "Invalid Token address");
        require(registered[_tokenAddress], "Token not registered");

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

    function _msgSender()
        internal
        view
        override(BasicMetaTransaction, Context)
        returns (address sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            return msg.sender;
        }
    }
}
