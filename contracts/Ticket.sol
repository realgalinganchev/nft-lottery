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
    uint256 public tokenIdCounter;
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
        tokenIdCounter = 0;
    }

    modifier isLotteryInitAndPlayable() {
        LotteryStruct memory currentLottery = lotteries[currentLotteryId];
        require(
            currentLottery.startBlock != 0 && currentLottery.endBlock != 0,
            "Lottery not started"
        );
        require(
            currentLottery.startBlock <= block.number,
            "Lottery starts later"
        );
        _;
    }

    function mint(string memory _tokenURI)
        public
        payable
        isLotteryInitAndPlayable
    {
        require(msg.value == 1 ether, "price is 1 eth");
        sendEther(payable(address(this)), msg.value);
        _safeMint(msg.sender, tokenIdCounter);
        _setTokenURI(tokenIdCounter, _tokenURI);
        console.log("tokenByIndex() :  ", tokenByIndex(tokenIdCounter));
        tokenIdCounter++;

        if (
            lotteries[currentLotteryId].endBlock == block.number ||
            SafeMath.sub(lotteries[currentLotteryId].endBlock, 1) ==
            block.number
        ) {
            payWinner();
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
    }

    function payWinner() private returns (address) {
        uint256 winnerTokenIndex = getRandomInt(totalSupply());
        address winnerAddr = ownerOf(winnerTokenIndex);
        console.log("winnerAddr : ", winnerAddr);
        if (
            SafeMath.sub(lotteries[currentLotteryId].endBlock, 1) ==
            block.number
        ) {
            sendEther(
                payable(winnerAddr),
                SafeMath.div(address(this).balance, 2)
            );
        } else {
            sendEther(payable(winnerAddr), address(this).balance);
            currentLotteryId = SafeMath.add(currentLotteryId, 1);
            console.log("totalSupply before burning: ", totalSupply());
            uint256 totalSupply = totalSupply();
            uint256 i = 0;
            for (i; i < totalSupply; i++) {
                _burn(i);
            }
        }

        return winnerAddr;
    }

    function getRandomInt(uint256 _endingValue) private view returns (uint256) {
        uint256 randomInt = SafeMath.mod(
            uint256(
                keccak256(abi.encodePacked(block.timestamp, totalSupply()))
            ),
            _endingValue
        );

        return randomInt;
    }

    function sendEther(address payable _to, uint256 _amount) public payable {
        (bool sent, bytes memory data) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
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
        console.log("totalSupply : ", totalSupply());
    }
}
