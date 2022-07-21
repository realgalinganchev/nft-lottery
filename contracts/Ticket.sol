// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Ticket is ERC721, ERC721Enumerable, Ownable {
    uint256 public tokenCounter;
    uint256 public currentLotteryId = 0;
    uint256 public numLotteries = 0;
    mapping(uint256 => string) private _tokenURIs;
    struct LotteryStruct {
        uint256 lotteryId;
        uint256 startBlock;
        uint256 endBlock;
        // bool isActive;
        // bool isCompleted;
    }
    mapping(uint256 => LotteryStruct) public lotteries;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tokenCounter = 0;
    }

    modifier isLotteryActive() {
        LotteryStruct memory currentLottery = lotteries[currentLotteryId];
        require(
            currentLottery.startBlock <= block.number,
            "Lottery hasn't started yet"
        );
        require(
            currentLottery.endBlock >= block.number,
            "Lottery has already finished"
        );
        if (lotteries[currentLotteryId].endBlock == block.number) { /// -1 ?/??
            endLottery();
        }
        _;
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

    function mint(string memory _tokenURI) public payable isLotteryActive {
        require(msg.value == 1 ether, "price is 1 eth");

        sendViaCall(payable(address(this)));
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, _tokenURI);

        tokenCounter++;
    }

    function initLottery(uint256 startBlock, uint256 endBlock)
        external
        onlyOwner
    {
        lotteries[currentLotteryId] = LotteryStruct({
            lotteryId: currentLotteryId,
            startBlock: startBlock,
            endBlock: endBlock
            // isActive: true,
            // isCompleted: false
        });
        numLotteries = numLotteries + 1;
    }

    function endLottery() private {
        uint256 winnerId = getRandomInt(totalSupply() - 1);
        console.log(winnerId);
    }

    function getRandomInt(uint256 _endingValue)
        internal
        view
        returns (uint256)
    {
        uint256 randomInt = uint256(blockhash(block.number - 1));
        uint256 range = _endingValue - 1;
        randomInt = randomInt % range;
        return randomInt;
    }

    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
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
