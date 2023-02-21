// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TokenContract is ERC20,Ownable{
    
    address public adminAddress;


   
    mapping(address => bool) internal frozen;
    mapping(address => bool) internal blankList;
    mapping(address => uint256) internal frozenTokens;

    

 

    event AddressFrozen(address indexed _userAddress, bool indexed _isFrozen, address indexed _owner);
    event AddressUnfrozen(address indexed addr);
    event blankListed(address[] indexed addr);
    event removeBlankListed(address[] indexed addr);
    event TokensFrozen(address indexed _userAddress, uint256 _amount);
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);


      modifier onlyAdmin() {
        require(adminAddress == msg.sender, "onlyAdmin");
        _;
    }
    
    

    constructor(string memory _name,string memory _symbol)ERC20(_name,_symbol){}

    function mint(address _to, uint256 _amount) public  onlyAdmin {
      
        _mint(_to, _amount);
      
    }



    function burn(address _userAddress, uint256 _amount) external  onlyAdmin {
      uint256 freeBalance = balanceOf(_userAddress) - frozenTokens[_userAddress];
        if (_amount > freeBalance) {
            uint256 tokensToUnfreeze = _amount - (freeBalance);
            frozenTokens[_userAddress] = frozenTokens[_userAddress] - (tokensToUnfreeze);
            emit TokensUnfrozen(_userAddress, tokensToUnfreeze);
        }
        _burn(_userAddress, _amount);
      
    }


  function freezeTokens(address _userAddress, uint256 _amount) external  onlyAdmin {
        uint256 balance = balanceOf(_userAddress);
        require(balance >= frozenTokens[_userAddress] + _amount, "Amount exceeds available balance");
        frozenTokens[_userAddress] = frozenTokens[_userAddress] + (_amount);
        emit TokensFrozen(_userAddress, _amount);
    }

     function unfreezeTokens(address _userAddress, uint256 _amount) external  onlyAdmin {
        require(frozenTokens[_userAddress] >= _amount, "Amount should be less than or equal to frozen tokens");
        frozenTokens[_userAddress] = frozenTokens[_userAddress] - (_amount);
        emit TokensUnfrozen(_userAddress, _amount);
    }  




     function addBlackList(address _userAddress,bool _freeze) external onlyAdmin {
        require(!frozen[_userAddress], "address already frozen");
        frozen[_userAddress] = _freeze;
        emit AddressFrozen(_userAddress, _freeze, msg.sender);
    }

  

    function addBlackListBatch(address[] memory _blankList) external onlyAdmin{

        for(uint i = 0; i<_blankList.length;i++){

            blankList[_blankList[i]] = true;

        }
        emit blankListed(_blankList);
        



    }

    function removeBlackkListBatch(address[] memory _removeBlankList) external onlyAdmin{

        for(uint i = 0; i<_removeBlankList.length;i++){

            blankList[_removeBlankList[i]] = false;

        }
        emit removeBlankListed(_removeBlankList);



    }

    function adminRole(address _adminAddress) external onlyOwner {
        adminAddress = _adminAddress;
    }






}
