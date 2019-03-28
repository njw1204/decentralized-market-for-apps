pragma solidity ^0.5.0;

contract BaseTokenInterface {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
}

contract ExtraTokenInterface is BaseTokenInterface {
    struct App {
        uint256 tokenId;
        string name;
        string comment;
        string url;
        uint256 validTime;
        address seller;
    }

    uint256 public totalSupply = 0; // total app count
    mapping (uint256 => App) public app; // store all apps based on tokenId

    mapping (uint256 => address) internal ownerOfApp; // store the app's owner
    mapping (address => uint256) internal ownerAppCount; // store the number of the owner's apps
    mapping (address => uint256[]) public appsOfOwner; // store the owner's apps
    mapping (address => mapping (uint256 => uint256)) internal appsOfOwnerIndex;

    mapping (address => uint256) public sellerAppCount;
    mapping (address => uint256[]) public appsOfSeller; // store the seller's apps
    mapping (address => mapping (uint256 => uint256)) internal appsOfSellerIndex;

    function transferToMarket(address _from, uint256 _tokenId) public;
    function sellerOf(uint256 _tokenId) public view returns (address _seller);
    function createApp(string memory _name, string memory _comment, string memory _url, uint256 _validTime) public;
    function changeSeller(address _to, uint256 _tokenId) public;
    function changeValidTime(uint256 _tokenId, uint256 _newValidTime) public;
    function changeName(uint256 _tokenId, string memory _newName) public;
    function changeComment(uint256 _tokenId, string memory _newComment) public;
    function changeUrl(uint256 _tokenId, string memory _newUrl) public;
}