/// @author njw1204

pragma solidity ^0.5.0;
import "./lib/Ownable.sol";
import "./lib/SafeMath.sol";
import "./TokenInterface.sol";

contract AppMarket is Ownable {
    using SafeMath for uint256;

    event MakeSell(uint256 indexed tokenId, uint256 price);
    event BuyApp(uint256 indexed tokenId, uint256 price);

    struct Sell {
        uint256 tokenId;
        uint256 price;
        bool enable;
    }

    uint256 private constant UINT256_MAX = ~uint256(0);
    uint256 public totalSellCount = 0;
    uint256 public nowSellCount = 0;
    Sell[] public sellArr;
    mapping (uint256 => uint256) private tokenIdToSellIndex;
    ExtraTokenInterface public tokenContract;

    constructor (address _tokenAddress) public {
        tokenContract = ExtraTokenInterface(_tokenAddress);
        sellArr.push(Sell(UINT256_MAX, UINT256_MAX, false)); // dummy node
    }

    function makeSell(uint256 _tokenId, uint256 _price) external {
        (,,,,, address seller) = tokenContract.app(_tokenId);
        require(msg.sender == seller);
        tokenContract.transferToMarket(msg.sender, _tokenId); // transfer token to this contract (keep until someone buy)

        tokenIdToSellIndex[_tokenId] = sellArr.length;
        sellArr.push(Sell(_tokenId, _price, true));
        totalSellCount = totalSellCount.add(1);
        nowSellCount = nowSellCount.add(1);

        emit MakeSell(_tokenId, _price);
    }

    function buyApp(uint256 _tokenId) external payable {
        Sell storage sell = sellArr[tokenIdToSellIndex[_tokenId]];
        require(sell.tokenId == _tokenId && msg.value == sell.price && sell.enable);

        (,,,,, address seller) = tokenContract.app(_tokenId);
        address(uint160(seller)).transfer(msg.value); // transfer price to seller
        tokenContract.transfer(msg.sender, _tokenId); // transfer token to buyer
        sell.enable = false;
        nowSellCount = nowSellCount.sub(1);

        emit BuyApp(_tokenId, msg.value);
    }

    function changeTokenContract(address _tokenContract) external onlyOwner {
        tokenContract = ExtraTokenInterface(_tokenContract);
    }
}