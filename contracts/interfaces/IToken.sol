// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IToken is IERC20 {
    function initialize(string memory name_, string memory symbol_,uint256 _totalSupply) external;

    //  function transfer(address _to,uint256 _amount)external returns (bool);

    //  function transferFrom(address _from,address _to,uint256 _amount)external returns (bool);

    function mint(address _to,uint256 _amount) external;
     function burn(
        address _userAddress,
        uint256 _amount
    )
        external;
}
