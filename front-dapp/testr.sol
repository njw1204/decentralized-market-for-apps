pragma solidity ^0.4.24;
import "./erc721.sol";

contract AppToken is ERC721 {
    
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
    
    
    function _createApp(uint256 _name, uint256 _time) private {
        uint256 id = appTokens.push(App(_name, _time, msg.sender)) - 1;
        owner[id] = msg.sender;
        NewToken(appTokens[id].appCode, id);
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
        Transfer(_from, _to, _tokenId);
    }
    
    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    
    
    function _changeSeller(address _from, address _to, uint256 _tokenId) private {
        appTokens[_tokenId].seller = _to;
        ChangeSeller(_from, _to, _tokenId);
    }
    
    function changeSeller(address _to, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _changeSeller(msg.sender, _to, _tokenId);
    }
    
    
    function _changeValid(uint256 _time, uint256 _tokenId) private {
        appTokens[_tokenId].valid = _time;
        validDate[_tokenId] = now + _time;
        ChangeValid(_tokenId);
    }
    
    function changeValid(uint256 _time, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _changeValid(_time, _tokenId);
    }
    
}