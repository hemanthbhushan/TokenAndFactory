// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TokenContract is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    address public adminAddress;
    uint256 internal _limitSupply;

    mapping(address => bool) internal frozen;
    mapping(address => bool) internal _blacklisted;
    mapping(address => uint256) internal frozenTokens;

    event AddressBlackListed(
        address indexed _userAddress,
        bool indexed _isFrozen,
        address indexed _owner
    );
    event AddressUnfrozen(address indexed addr);
    event blackListed(address[] indexed addr);
    event removeBlankListed(address[] indexed addr);
    event TokensFrozen(address indexed _userAddress, uint256 _amount);
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);

    event adminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(adminAddress == msg.sender, "onlyAdmin");
        _;
    }

    modifier notBlacklisted(address account) {
        require(
            !_blacklisted[account],
            "Blacklistable: account is blacklisted"
        );
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) public initializer {
        __ERC20_init(_name, _symbol);
        _limitSupply = _initialSupply;
        __Ownable_init();
        // adminAddress = _owner;
        adminRole(_owner);
    }

    function totalSupply() public view override returns (uint256) {
        return _limitSupply;
    }

    /**
     *  @dev mint tokens on a wallet
     *  Improved version of default mint method. Tokens can be minted
     *  to an address if only it is a verified address as per the security token.
     *  @param _to Address to mint the tokens to.
     *  @param _amount Amount of tokens to mint.
     *  This function can only be called by a wallet set as Admin of the token
     *  emits a `Transfer` event
     */

    function mint(
        address _to,
        uint256 _amount
    ) public notBlacklisted(msg.sender) notBlacklisted(_to) onlyAdmin {
        require(
            super.totalSupply() + _amount <= _limitSupply,
            "Amount exceeds totalSupply"
        );
        _mint(_to, _amount);
    }

    /**
     *  @dev burn tokens on a wallet
     *  In case the `account` address has not enough free tokens (unfrozen tokens)
     *  but has a total balance higher or equal to the `value` amount
     *  the amount of frozen tokens is reduced in order to have enough free tokens
     *  to proceed the burn, in such a case, the remaining balance on the `account`
     *  is 100% composed of frozen tokens post-transaction.
     *  @param _userAddress Address to burn the tokens from.
     *  @param _amount Amount of tokens to burn.
     *  This function can only be called by a wallet set as admin of the token
     *  emits a `TokensUnfrozen` event if `_amount` is higher than the free balance of `_userAddress`
     *  emits a `Transfer` event
     */

    function burn(
        address _userAddress,
        uint256 _amount
    )
        external
        notBlacklisted(msg.sender)
        notBlacklisted(_userAddress)
        onlyAdmin
    {
        uint256 freeBalance = balanceOf(_userAddress) -
            frozenTokens[_userAddress];
        if (_amount > freeBalance) {
            uint256 tokensToUnfreeze = _amount - (freeBalance);
            frozenTokens[_userAddress] =
                frozenTokens[_userAddress] -
                (tokensToUnfreeze);
            emit TokensUnfrozen(_userAddress, tokensToUnfreeze);
        }
        _burn(_userAddress, _amount);
    }

    /*
     *  @dev function allowing to issue transfer
     *  Require that the msg.sender and `to` addresses are not BlackListed.
     *  Require that the total value should not exceed available balance.
     *  @param _to The address of the receiver
     *  @param _amounts The number of tokens to transfer to the corresponding receiver
     *  emits  `Transfer` events
     */

    function transfer(
        address _to,
        uint256 _amount
    )
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        require(
            _amount <= balanceOf(msg.sender) - (frozenTokens[msg.sender]),
            "Insufficient Balance"
        );

        return super.transfer(_to, _amount);
    }

    /*
     *  @dev function allowing to issue transfer
     *  Require that the msg.sender,from and `to` addresses are not BlackListed.
     *  Require that the total value should not exceed available balance.
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     *  emits  `Transfer` events
     */

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(_from)
        notBlacklisted(_to)
        returns (bool)
    {
        require(
            _amount <= balanceOf(_from) - (frozenTokens[_from]),
            "Insufficient Balance"
        );
        return super.transferFrom(_from, _to, _amount);
    }

    /**
     *  @dev freezes token amount specified for given address.
     *  @param _userAddress The address for which to update frozen tokens
     *  @param _amount Amount of Tokens to be frozen
     *  This function can only be called by a wallet set as admin of the token
     *  emits a `TokensFrozen` event
     */

    function freezeTokens(
        address _userAddress,
        uint256 _amount
    )
        external
        notBlacklisted(msg.sender)
        notBlacklisted(_userAddress)
        onlyAdmin
    {
        uint256 balance = balanceOf(_userAddress);
        require(
            balance >= frozenTokens[_userAddress] + _amount,
            "Amount exceeds available balance"
        );
        frozenTokens[_userAddress] = frozenTokens[_userAddress] + (_amount);
        emit TokensFrozen(_userAddress, _amount);
    }

    /**
     *  @dev unfreezes token amount specified for given address
     *  @param _userAddress The address for which to update frozen tokens
     *  @param _amount Amount of Tokens to be unfrozen
     *  This function can only be called by a wallet set as admin of the token
     *  emits a `TokensUnfrozen` event
     */

    function unfreezeTokens(
        address _userAddress,
        uint256 _amount
    )
        external
        notBlacklisted(msg.sender)
        notBlacklisted(_userAddress)
        onlyAdmin
    {
        require(
            frozenTokens[_userAddress] >= _amount,
            "Amount should be less than or equal to frozen tokens"
        );
        frozenTokens[_userAddress] = frozenTokens[_userAddress] - (_amount);
        emit TokensUnfrozen(_userAddress, _amount);
    }

    /**
     *  @dev Returns the amount of tokens that are partially frozen on a wallet
     *  the amount of frozen tokens is always <= to the total balance of the wallet
     *  @param _userAddress the address of the wallet on which getFrozenTokens is called
     */

    function getFreezeAmount(
        address _userAddress
    ) external view onlyAdmin returns (uint256) {
        return frozenTokens[_userAddress];
    }

    /**
     *  @dev sets an address frozen status for this token.
     *  @param _userAddress The address for which to update frozen status
     *  @param _freeze Frozen status of the address
     *  This function can only be called by a wallet set as admin of the token
     *  emits an `AddressBlackListed` event
     */
    function addBlackList(
        address _userAddress,
        bool _freeze
    )
        external
        notBlacklisted(msg.sender)
        notBlacklisted(_userAddress)
        onlyAdmin
    {
        _blacklisted[_userAddress] = _freeze;
        emit AddressBlackListed(_userAddress, _freeze, msg.sender);
    }

    function addBlackListBatch(
        address[] memory _blankList
    ) external notBlacklisted(msg.sender) onlyAdmin {
        for (uint i = 0; i < _blankList.length; i++) {
            require(
                !_blacklisted[_blankList[i]],
                "address already blacklisted"
            );

            _blacklisted[_blankList[i]] = true;
        }
        emit blackListed(_blankList);
    }

    function removeBlackkListBatch(
        address[] memory _removeBlankList
    ) external notBlacklisted(msg.sender) onlyAdmin {
        for (uint i = 0; i < _removeBlankList.length; i++) {
            require(
                _blacklisted[_removeBlankList[i]],
                "address not blacklisted"
            );

            _blacklisted[_removeBlankList[i]] = false;
        }
        emit removeBlankListed(_removeBlankList);
    }

    /**
     *  @dev Returns the blackList status of a wallet
     *  if isBlacklisted returns `true` the wallet is blacklisted
     *  if isBlacklisted returns `false` the wallet is not blacklisted
     *  isBlacklisted returning `true` doesn"t mean that the balance is free, tokens could be blocked by
     *  a freezeTokens
     *  @param _userAddress the address of the wallet on which isFrozen is called
     */

    function isBlacklisted(address _userAddress) external view returns (bool) {
        return _blacklisted[_userAddress];
    }

    /**
     * @dev Sets a new admin role address.
     * @param _owner The new address allowed by the owner as Admin.
     */

    function adminRole(address _owner) public onlyOwner {
        address _oldAdmin = adminAddress;
        adminAddress = _owner;

        emit adminChanged(_oldAdmin, adminAddress);
    }
}
