// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IFactory {
    function initialize(address _masterToken) external;

    function createToken(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        address _owner
    ) external;

    function tokenTransfer(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external;

    function tokenTransferFrom(
        address _tokenAddress,
        address _from,
        address _to,
        uint256 _amount
    ) external;

    function tokenMint(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external;

    function tokenBalance(address _tokenAddress, address _userAddress) external;

    function tokenBurn(
        address _tokenAddress,
        address _userAddress,
        uint256 _amount
    ) external;


    function registerTokens(
        // TokenDetails memory tokenDetails,
        address _tokenAddress
    ) external ;

     function unregisterTokens(address _tokenAddress) external ;


    function getTokenDetails(
        address _tokenAddress
    ) external;
    

     function tokensRegistered() external;

}
