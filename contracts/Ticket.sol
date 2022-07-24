// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Ticket is Ownable, ERC721Enumerable, ERC721URIStorage {
    event LotteryStarted(
        uint256 lotteryId,
        uint256 startBlock,
        uint256 endBlock
    );

    event WinnerAddress(address winnerAddress);

    uint256 private _tokenIdCounter;
    uint256 public currentLotteryId;
    struct LotteryStruct {
        uint256 lotteryId;
        uint256 startBlock;
        uint256 endBlock;
    }
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => LotteryStruct) public lotteries;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _tokenIdCounter = 0;
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
        require(
            startBlock >= block.number,
            "You cannot start lottery from past blocks"
        );

        lotteries[currentLotteryId] = LotteryStruct({
            lotteryId: currentLotteryId,
            startBlock: startBlock,
            endBlock: endBlock
        });
        emit LotteryStarted(currentLotteryId, startBlock, endBlock);
    }

    function resetLottery() public onlyOwner {
        lotteries[currentLotteryId] = LotteryStruct({
            lotteryId: currentLotteryId + 1,
            startBlock: 0,
            endBlock: 0
        });
    }

    function getCurrentBlockNumber() public view returns (uint256) {
        return block.number;
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
            lotteries[currentLotteryId].endBlock == block.number + 1
        ) {
            payWinner(totalSupply(), ownerOf(getRandomInt(totalSupply())));
        }
    }

    function payWinner(uint256 _totalSupply, address winnerAddr) public {
        if (lotteries[currentLotteryId].endBlock == block.number + 1) {
            sendEther(payable(winnerAddr), address(this).balance / 2);
        } else {
            sendEther(payable(winnerAddr), address(this).balance);
            currentLotteryId = currentLotteryId + 1;
            uint256 i = 0;
            for (i; i < _totalSupply; i++) {
                _burn(i);
            }
        }
        emit WinnerAddress(winnerAddr);
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
