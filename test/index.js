const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('Proxy', async () => {
  let owner
  let proxy, logic

  beforeEach(async () => {
    ;[owner] = await ethers.getSigners()

    const Logic = await ethers.getContractFactory('Ticket')
    logic = await Logic.deploy('Ticket', 'TKT')
    await logic.deployed()
    const Proxy = await ethers.getContractFactory('Proxy')
    proxy = await Proxy.deploy()
    await proxy.deployed()

    await proxy.setImplementation(logic.address)

    abi = [
      'function getCurrentTokenId() public view returns (uint256)',
      'function setCurrentTokenId(uint256 id) public returns (uint256)',
      'function initLottery(uint256 startBlock, uint256 endBlock) public',
      'function safeMint(string memory _tokenURI) public',
      'function payWinner() public returns (address)',
      'function sendEther(address payable _to, uint256 _amount) public payable',
      'function getRandomInt(uint256 _endingValue) public view returns (uint256)',
      'function _burn(uint256 tokenId) public',
      'function _setTokenURI(uint256 _tokenId, string memory _tokenURI) public ',
      'function tokenURI(uint256 _tokenId) public view returns (string memory)',
      'function _beforeTokenTransfer(address from, address to,uint256 tokenId) public',
      'function supportsInterface(bytes4 interfaceId) public view returns (bool)',
    ]
  })

  it('points to an implementation contract', async () => {
    expect(await proxy.callStatic.getImplementation()).to.eq(logic.address)
  })

  it('proxies calls to implementation contract', async () => {
    const proxied = new ethers.Contract(proxy.address, abi, owner)
    await proxied.setCurrentTokenId(5)
    expect(await proxied.getCurrentTokenId()).to.eq(5)
  })

  it('allows to change implementations', async () => {
    const LogicV2 = await ethers.getContractFactory('TicketV2')
    const logicv2 = await LogicV2.deploy('TicketV2', 'TKTV2')
    await logicv2.deployed()

    await proxy.setImplementation(logicv2.address)

    abi = [
      'function doMagic(uint256 id) public pure returns (uint256)',
      'function getCurrentTokenId() public view returns (uint256)',
      'function setCurrentTokenId(uint256 id) public returns (uint256)',
      'function initLottery(uint256 startBlock, uint256 endBlock) public',
      'function safeMint(string memory _tokenURI) public',
      'function payWinner() public returns (address)',
      'function sendEther(address payable _to, uint256 _amount) public payable',
      'function getRandomInt(uint256 _endingValue) public view returns (uint256)',
      'function _burn(uint256 tokenId) public',
      'function _setTokenURI(uint256 _tokenId, string memory _tokenURI) public ',
      'function tokenURI(uint256 _tokenId) public view returns (string memory)',
      'function _beforeTokenTransfer(address from, address to,uint256 tokenId) public',
      'function supportsInterface(bytes4 interfaceId) public view returns (bool)',
    ]

    const proxied = new ethers.Contract(proxy.address, abi, owner)
    expect(await proxied.doMagic(4)).to.eq(2)
  })
})
