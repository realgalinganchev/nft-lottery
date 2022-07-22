// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "./Lottery1.sol";
import "hardhat/console.sol";

contract Lottery2 is
    Lottery1,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable
{
    uint256 private _tokenIdCounter;
    uint256 public currentLotteryId;
    uint256 public numLotteries;
    mapping(uint256 => string) private _tokenURIs;
    struct LotteryStruct {
        uint256 lotteryId;
        uint256 startBlock;
        uint256 endBlock;
    }
    mapping(uint256 => LotteryStruct) public lotteries;

    function reInitialize() public reinitializer(2) {
        __ERC721_init("Ticket", "TKT");
        __ERC721URIStorage_init();
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
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
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
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
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
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
