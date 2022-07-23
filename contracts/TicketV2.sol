// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract TicketV2 is Ownable, ERC721Enumerable, ERC721URIStorage {
    uint256 private _tokenIdCounter;
    uint256 public currentLotteryId;
    mapping(uint256 => string) private _tokenURIs;
    struct LotteryStruct {
        uint256 lotteryId;
        uint256 startBlock;
        uint256 endBlock;
    }
    mapping(uint256 => LotteryStruct) public lotteries;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _tokenIdCounter = 0;
    }

    function doMagic(uint256 id) public pure returns (uint256) {
        return id / 2;
    }

    function getCurrentTokenId() public view returns (uint256) {
        return currentLotteryId;
    }

    function setCurrentTokenId(uint256 id) public returns (uint256) {
        currentLotteryId = id;
        return currentLotteryId;
    }

    modifier isLotteryInitAndPlayable() {
        LotteryStruct memory currentLottery = lotteries[currentLotteryId];
        require(
            currentLottery.startBlock != 0 && currentLottery.endBlock != 0,
            "Lottery not initialized yet"
        );
        require(
            currentLottery.startBlock <= block.number,
            "You can not participate yet"
        );
        _;
    }

    receive() external payable {
        console.log("----- receive:", msg.value);
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
    }

    function safeMint(string memory _tokenURI)
        public
        payable
        virtual
        isLotteryInitAndPlayable
    {
        require(msg.value == 1 ether, "price is 1 eth");
        sendEther(payable(address(this)), msg.value);
        _safeMint(msg.sender, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, _tokenURI);
        _tokenIdCounter++;

        if (
            lotteries[currentLotteryId].endBlock == block.number ||
            lotteries[currentLotteryId].endBlock - 1 == block.number
        ) {
            payWinner();
        }
    }

    function payWinner() private returns (address) {
        uint256 totalSupply = totalSupply();
        address winnerAddr = ownerOf(getRandomInt(totalSupply));

        if (lotteries[currentLotteryId].endBlock - 1 == block.number) {
            sendEther(payable(winnerAddr), address(this).balance / 2);
        } else {
            sendEther(payable(winnerAddr), address(this).balance);
            currentLotteryId = currentLotteryId + 1;
            uint256 i = 0;
            for (i; i < totalSupply; i++) {
                _burn(i);
            }
        }
        return winnerAddr;
    }

    function sendEther(address payable _to, uint256 _amount) public payable {
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getRandomInt(uint256 _endingValue) private view returns (uint256) {
        uint256 randomInt = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, totalSupply(), msg.sender)
            )
        ) % _endingValue;

        return randomInt;
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI)
        internal
        virtual
        override
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        return _tokenURIs[_tokenId];
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
}
