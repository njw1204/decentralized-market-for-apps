pragma solidity ^0.5.0;
import "./erc721.sol";

contract Test is ERC721 {
    
    event NewToken(uint256 appCode, uint256 id);
    event ChangeSeller(address _from, address _to, uint256 id);
    event ChangeValid(uint256 id);
    
    
    struct App {
        uint256 appCode;
        uint256 valid;
        address seller;
    }
    App[] public appTokens;
    
    mapping (uint256 => address) owner; //owner[appToken_index] : address
    mapping (uint256 => uint256) purchaseDate; //purchaseDate[appToken_index] : timestamp
    mapping (uint256 => uint256) validDate; //validDate[appToken_index] : timestamp
    
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = owner[_tokenId];
        return _owner;
    }
    
    function tokenInfo(uint256 _tokenId) public view returns (
        uint256 _appcode, 
        uint256 _valid, 
        address _seller, 
        address _owner, 
        uint256 _purchaseDate, 
        uint256 _validDate) {
        _appcode = appTokens[_tokenId].appCode;
        _valid = appTokens[_tokenId].valid;
        _seller = appTokens[_tokenId].seller;
        _owner = owner[_tokenId];
        _purchaseDate = purchaseDate[_tokenId];
        _validDate = validDate[_tokenId];
        return (_appcode, _valid, _seller, _owner, _purchaseDate, _validDate)    ;
    }
    
    
    function _createApp(uint256 _name, uint256 _time) private {
        uint256 id = appTokens.push(App(_name, _time, msg.sender)) - 1;
        owner[id] = msg.sender;
        emit NewToken(appTokens[id].appCode, id);
    }
    
    function createApp(string _name, uint256 _time) public {
        _createApp(uint256(keccak256(_name)), _time);
    }
    
    
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        owner[_tokenId] = _to;
        if(msg.sender==_from) {
            purchaseDate[_tokenId] = now;
            validDate[_tokenId] = now + appTokens[_tokenId].valid;
        }
        emit Transfer(_from, _to, _tokenId);
    }
    
    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    
    
    function _changeSeller(address _from, address _to, uint256 _tokenId) private {
        appTokens[_tokenId].seller = _to;
        emit ChangeSeller(_from, _to, _tokenId);
    }
    
    function changeSeller(address _to, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _changeSeller(msg.sender, _to, _tokenId);
    }
    
    
    function _changeValid(uint256 _time, uint256 _tokenId) private {
        appTokens[_tokenId].valid = _time;
        validDate[_tokenId] = now + _time;
        emit ChangeValid(_tokenId);
    }
    
    function changeValid(uint256 _time, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _changeValid(_time, _tokenId);
    }
    
}