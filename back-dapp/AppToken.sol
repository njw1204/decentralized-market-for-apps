/// @author robinjoo1015 & njw1204

pragma solidity ^0.5.0;
import "./lib/SafeMath.sol";
import "./TokenInterface.sol";

contract AppToken is ExtraTokenInterface {
    using SafeMath for uint256;
    
    event ChangeSeller(uint256 indexed tokenId, address from, address to);
    event ChangeValidTime(uint256 indexed tokenId, uint256 newValidTime);

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerAppCount[_owner];
    }
    
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return ownerOfApp[_tokenId];
    }
    
    function sellerOf(uint256 _tokenId) public view returns (address _seller) {
        return app[_tokenId].seller;
    }
    
    function createApp(string memory _name, string memory _comment, string memory _url, uint256 _validTime) public {
        uint256 _tokenId = totalSupply.add(1);

        app[_tokenId] = App(_tokenId, _name, _comment, _url, _validTime, msg.sender); // create new app
        sellerAppCount[msg.sender] = sellerAppCount[msg.sender].add(1);
        // push to array of seller's apps
        appsOfSellerIndex[msg.sender][_tokenId] = appsOfSeller[msg.sender].length;
        appsOfSeller[msg.sender].push(_tokenId);
        _transfer(address(0), msg.sender, _tokenId); // transfer created app from 0 to msg.sender
    }
    
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        require(_from != _to && _to != address(0));

        if (_from != address(0)) {
            ownerAppCount[_from] = ownerAppCount[_from].sub(1);
            // remove element (set 0) at array of owner's apps
            delete appsOfOwner[_from][appsOfOwnerIndex[_from][_tokenId]];
            delete appsOfOwnerIndex[_from][_tokenId];
        }
        else {
            // create new app
            totalSupply = totalSupply.add(1);
        }

        ownerOfApp[_tokenId] = _to;
        ownerAppCount[_to] = ownerAppCount[_to].add(1);
        // push to array of owner's apps
        appsOfOwnerIndex[_to][_tokenId] = appsOfOwner[_to].length;
        appsOfOwner[_to].push(_tokenId);
        emit Transfer(_from, _to, _tokenId);
    }
    
    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    
    function changeSeller(address _to, uint256 _tokenId) public {
        require(msg.sender == sellerOf(_tokenId) && _to != address(0));

        sellerAppCount[msg.sender] = sellerAppCount[msg.sender].sub(1);
        // remove element (set 0) at array of seller's apps
        delete appsOfSeller[msg.sender][appsOfSellerIndex[msg.sender][_tokenId]];
        delete appsOfSellerIndex[msg.sender][_tokenId];

        app[_tokenId].seller = _to;
        sellerAppCount[_to] = sellerAppCount[_to].add(1);
        // push to array of seller's apps
        appsOfSellerIndex[_to][_tokenId] = appsOfSeller[_to].length;
        appsOfSeller[_to].push(_tokenId);
        emit ChangeSeller(_tokenId, msg.sender, _to);
    }
    
    function changeValidTime(uint256 _tokenId, uint256 _newValidTime) public {
        require(msg.sender == sellerOf(_tokenId));
        app[_tokenId].validTime = _newValidTime;
        emit ChangeValidTime(_tokenId, _newValidTime);
    }

    function changeName(uint256 _tokenId, string memory _newName) public {
        require(msg.sender == sellerOf(_tokenId));
        app[_tokenId].name = _newName;
    }

    function changeComment(uint256 _tokenId, string memory _newComment) public {
        require(msg.sender == sellerOf(_tokenId));
        app[_tokenId].comment = _newComment;
    }

    function changeUrl(uint256 _tokenId, string memory _newUrl) public {
        require(msg.sender == sellerOf(_tokenId));
        app[_tokenId].url = _newUrl;
    }
}