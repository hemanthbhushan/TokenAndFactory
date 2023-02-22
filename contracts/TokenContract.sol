// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TokenContract is ERC20,Ownable{
    
    address public adminAddress;
    bool  initialized ;


   
    mapping(address => bool) internal frozen;
    mapping(address => bool) internal _blacklisted;
    mapping(address => uint256) internal frozenTokens;

    

 

    event AddressFrozen(address indexed _userAddress, bool indexed _isFrozen, address indexed _owner);
    event AddressUnfrozen(address indexed addr);
    event blackListed(address[] indexed addr);
    event removeBlankListed(address[] indexed addr);
    event TokensFrozen(address indexed _userAddress, uint256 _amount);
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);


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
    
    

    // constructor(string memory _name,string memory _symbol)ERC20(_name,_symbol){}
    function initialize(string memory _name,string memory _symbol) public onlyOwner {
        require(initialized == false,"already initialized");
        initialized = true;
        _initialize(_name, _symbol);
    }

    function mint(address _to, uint256 _amount) public notBlacklisted(msg.sender) notBlacklisted(_to) onlyAdmin {
      
        _mint(_to, _amount);
      
       }



    function burn(address _userAddress, uint256 _amount) external notBlacklisted(msg.sender) notBlacklisted(_userAddress) onlyAdmin {
      uint256 freeBalance = balanceOf(_userAddress) - frozenTokens[_userAddress];
        if (_amount > freeBalance) {
            uint256 tokensToUnfreeze = _amount - (freeBalance);
            frozenTokens[_userAddress] = frozenTokens[_userAddress] - (tokensToUnfreeze);
            emit TokensUnfrozen(_userAddress, tokensToUnfreeze);
        }
        _burn(_userAddress, _amount);
      
    }

    function transfer(address _to,uint256 _amount)public override notBlacklisted(msg.sender) notBlacklisted(_to) returns(bool) {
        require(_amount <= balanceOf(msg.sender) - (frozenTokens[msg.sender]), "Insufficient Balance");
        transfer(_to,_amount);
    }

    function transferFrom(address _from,address _to,uint256 _amount)public override notBlacklisted(msg.sender) notBlacklisted(_from) notBlacklisted(_to) returns(bool) {
        require(_amount <= balanceOf(_from) - (frozenTokens[_from]), "Insufficient Balance");
        transferFrom(_from,_to,_amount);
    }


    function freezeTokens(address _userAddress, uint256 _amount) external notBlacklisted(msg.sender) notBlacklisted(_userAddress) onlyAdmin {
        uint256 balance = balanceOf(_userAddress);
        require(balance >= frozenTokens[_userAddress] + _amount, "Amount exceeds available balance");
        frozenTokens[_userAddress] = frozenTokens[_userAddress] + (_amount);
        emit TokensFrozen(_userAddress, _amount);
        }

    function unfreezeTokens(address _userAddress, uint256 _amount) external notBlacklisted(msg.sender) notBlacklisted(_userAddress) onlyAdmin {
        require(frozenTokens[_userAddress] >= _amount, "Amount should be less than or equal to frozen tokens");
        frozenTokens[_userAddress] = frozenTokens[_userAddress] - (_amount);
        emit TokensUnfrozen(_userAddress, _amount);
    }  




     function addBlackList(address _userAddress,bool _freeze) external notBlacklisted(msg.sender) notBlacklisted(_userAddress) onlyAdmin {
         _blacklisted[_userAddress] = _freeze;
        emit AddressFrozen(_userAddress, _freeze, msg.sender);
       }

  

    function addBlackListBatch(address[] memory _blankList) external notBlacklisted(msg.sender)  onlyAdmin{

        for(uint i = 0; i<_blankList.length;i++){
             require(!_blacklisted[_blankList[i]], "address already blacklisted");

            _blacklisted[_blankList[i]] = true;

        }
        emit blackListed(_blankList);
        



    }

    function removeBlackkListBatch(address[] memory _removeBlankList) external notBlacklisted(msg.sender) onlyAdmin{

        for(uint i = 0; i<_removeBlankList.length;i++){
            require(_blacklisted[_removeBlankList[i]], "address not blacklisted");

            _blacklisted[_removeBlankList[i]] = false;

        }
        emit removeBlankListed(_removeBlankList);



    }

     function isBlacklisted(address account) external view returns (bool) {
        return _blacklisted[account];
    }

    function adminRole(address _adminAddress) external onlyOwner {
        adminAddress = _adminAddress;
    }






}
