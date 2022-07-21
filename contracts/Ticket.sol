// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

contract Ticket is ERC721, ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    uint256 public tokenCounter;
    uint256 public currentLotteryId = 0;
    uint256 public numLotteries = 0;
    mapping(uint256 => string) private _tokenURIs;
    struct LotteryStruct {
        uint256 lotteryId;
        uint256 startBlock;
        uint256 endBlock;
    }
    mapping(uint256 => LotteryStruct) public lotteries;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tokenCounter = 0;
    }

    modifier isLotteryStartedAndRunning() {
        LotteryStruct memory currentLottery = lotteries[currentLotteryId];
        console.log("currentLottery.startBlock : ", currentLottery.startBlock);
        console.log("currentLottery.endBlock : ", currentLottery.endBlock);
        console.log("block.number : ", block.number);
        require(
            currentLottery.startBlock != 0 && currentLottery.endBlock != 0,
            "Lottery has not been started yet"
        );
        require(
            currentLottery.startBlock <= block.number,
            "Lottery starts at a later block"
        );
        require(
            currentLottery.endBlock >= block.number,
            "Lottery has already finished"
        );
        _;
    }

    function mint(string memory _tokenURI)
        public
        payable
        isLotteryStartedAndRunning
    {
        require(msg.value == 1 ether, "price is 1 eth");
        (bool sent, bytes memory data) = payable(address(this)).call{
            value: msg.value
        }("");
        require(sent, "Failed to send Ether");
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, _tokenURI);
        console.log("tokenCounter : ", tokenCounter);
        console.log("_tokenURI : ", _tokenURI);
        console.log(
            "tokenByIndex(tokenCounter) : ",
            tokenByIndex(tokenCounter)
        );
        tokenCounter++;

        if (lotteries[currentLotteryId].endBlock == block.number) {
            console.log(
                "lotteries[currentLotteryId].endBlock : ",
                lotteries[currentLotteryId].endBlock
            );
            console.log("block.number : ", block.number);
            endLottery();
        }
    }

    function initLottery(uint256 startBlock, uint256 endBlock)
        external
        onlyOwner
    {
        lotteries[currentLotteryId] = LotteryStruct({
            lotteryId: currentLotteryId,
            startBlock: startBlock,
            endBlock: endBlock
        });
        numLotteries = SafeMath.add(numLotteries, 1);
    }

    function endLottery() private returns (uint256) {
        uint256 winnerId = getRandomInt(totalSupply());
        uint256 token = tokenOfOwnerByIndex(msg.sender, winnerId);
        console.log("token : ", token);
        currentLotteryId = SafeMath.add(currentLotteryId, 1);
        return token;
    }

    //change to internal
    function getRandomInt(uint256 _endingValue) public view returns (uint256) {
        uint256 randomInt = SafeMath.mod(
            uint256(
                keccak256(abi.encodePacked(block.timestamp, totalSupply()))
            ),
            _endingValue
        );

        return randomInt;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        ); // Checks if the tokenId exists
        _tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        return _tokenURIs[_tokenId];
    }

    fallback() external payable {
        console.log("----- fallback:", msg.value);
    }

    receive() external payable {
        console.log("----- receive:", msg.value);
    }
}
