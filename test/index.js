const { expect } = require('chai')
const { ethers } = require('hardhat')
const { NonceManager } = require('@ethersproject/experimental')
const proxyJSON = require('../artifacts/contracts/Proxy.sol/Proxy.json')
const proxyBytecode = proxyJSON.bytecode
const ticketJSON = require('../artifacts/contracts/Ticket.sol/Ticket.json')
const ticketInterface = ticketJSON.abi

describe('Proxy', async () => {
  let owner, player1, player2
  let factory, proxy, ticket, ticketv2
  let options, optionsMint, signerOwner, blockNumber, provider

  beforeEach(async () => {
    ;[owner, player1, player2] = await ethers.getSigners()

    options = {
      gasPrice: ethers.getDefaultProvider().getGasPrice(),
      gasLimit: 5000000,
    }

    optionsMint = {
      gasPrice: ethers.getDefaultProvider().getGasPrice(),
      gasLimit: 5000000,
      value: ethers.utils.parseEther('1'),
    }

    const Factory = await ethers.getContractFactory('Factory')
    factory = await Factory.deploy()
    await factory.deployed()

    const TicketV2 = await ethers.getContractFactory('TicketV2')
    ticketv2 = await TicketV2.deploy('TicketV2', 'TKTV2')
    await ticketv2.deployed()

    let salt = '42'
    let bytes32Salt = ethers.utils.formatBytes32String(salt)
    const computedAddress = await factory.getAddress(proxyBytecode, bytes32Salt)
    await factory.deploy(proxyBytecode, bytes32Salt).then((tx) => tx.wait(1))
    proxy = await ethers.getContractAt('Proxy', computedAddress)

    const Ticket = await ethers.getContractFactory('Ticket')
    ticket = await Ticket.deploy('Ticket', 'TKT')
    await ticket.deployed()

    await proxy.setImplementation(ticket.address)

    abi = [
      'function initLottery(uint256 startBlock, uint256 endBlock) public',
      'function resetLottery() public',
      'function getCurrentBlockNumber() public view returns (uint256)',
      'function safeMint(string memory _tokenURI) public',
      'function payWinner() public returns (address)',
      'function sendEther(address payable _to, uint256 _amount) public payable',
      'function getRandomInt(uint256 _endingValue) public view returns (uint256)',
      'function _burn(uint256 tokenId) public',
      'function tokenURI(uint256 _tokenId) public view returns (string memory)',
      'function _beforeTokenTransfer(address from, address to,uint256 tokenId) public',
      'function supportsInterface(bytes4 interfaceId) public view returns (bool)',
    ]

    provider = ethers.provider
    const walletOwner = new ethers.Wallet(
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
    )
    walletOwner.provider = provider
    signerOwner = walletOwner.connect(provider)
    const managedSigner = new NonceManager(signerOwner)
    ticketContract = new ethers.Contract(
      ticket.address,
      ticketInterface,
      managedSigner,
    )

    await ticketContract.getCurrentBlockNumber().then((data) => {
      blockNumber = data
    })
  })

  it('points to an implementation contract', async () => {
    expect(await proxy.callStatic.getImplementation()).to.eq(ticket.address)
  })

  it('owner should be able to start lottery and it should get initialized', async () => {
    await expect(
      ticketContract
        .connect(signerOwner)
        .initLottery(
          ethers.BigNumber.from(5).add(blockNumber),
          ethers.BigNumber.from(6).add(blockNumber),
          options,
        ),
    )
      .to.emit(ticketContract, 'LotteryStarted')
      .withArgs(
        0,
        ethers.BigNumber.from(5).add(blockNumber),
        ethers.BigNumber.from(6).add(blockNumber),
      )
  })

  it('only owner should start the lottery', async () => {
    await expect(
      ticketContract
        .connect(player1)
        .initLottery(
          ethers.BigNumber.from(5).add(blockNumber),
          ethers.BigNumber.from(6).add(blockNumber),
          options,
        ),
    ).to.be.revertedWith('Ownable: caller is not the owner')
  })

  it('cannot start lottery from past blocks', async () => {
    await expect(
      ticketContract
        .connect(signerOwner)
        .initLottery(
          ethers.BigNumber.from(blockNumber).sub(1),
          ethers.BigNumber.from(5).add(blockNumber),
          options,
        ),
    ).to.be.revertedWith('You cannot start lottery from past blocks')
  })

  it('players should not be able play before lottery has been initialized', async () => {
    await expect(
      ticketContract.safeMint('test', optionsMint),
    ).to.be.revertedWith('Lottery not initialized yet')
  })

  it('players can participate only by paying 1 ETH', async () => {
    ticketContract
      .connect(signerOwner)
      .initLottery(
        ethers.BigNumber.from(1).add(blockNumber),
        ethers.BigNumber.from(5).add(blockNumber),
        options,
      ),
      await expect(
        ticketContract
          .safeMint('test', {
            gasPrice: ethers.getDefaultProvider().getGasPrice(),
            gasLimit: 5000000,
            value: ethers.utils.parseEther('0.5'),
          })
          .then((tx) => tx.wait(1)),
      ).to.be.revertedWith('price is 1 eth')

    ticketContract.resetLottery()
  })

  it('surprise winner should be paid on second to last block of the lottery', async () => {
    await ticketContract.initLottery(
      ethers.BigNumber.from(blockNumber).add(1),
      ethers.BigNumber.from(blockNumber).add(1),
      options,
    )

    await ticketContract.safeMint('test1', optionsMint)
    await expect(ticketContract.payWinner(0, player1.address, options))
      .to.emit(ticketContract, 'WinnerAddress')
      .withArgs(player1.address)
  })

  it('final winner should be paid onlast block of the lottery', async () => {
    await ticketContract.initLottery(
      ethers.BigNumber.from(blockNumber).add(1),
      ethers.BigNumber.from(blockNumber),
      options,
    )
    await ticketContract.safeMint('test2', optionsMint)
    await expect(ticketContract.payWinner(0, player2.address, options))
      .to.emit(ticketContract, 'WinnerAddress')
      .withArgs(player2.address)
  })

  it('allows to change implementations', async () => {
    await proxy.setImplementation(ticketv2.address)
    abi = [
      'function testNewImplementation() public pure returns (string memory test)',
      'function initLottery(uint256 startBlock, uint256 endBlock) public',
      'function resetLottery() public',
      'function getCurrentBlockNumber() public view returns (uint256)',
      'function safeMint(string memory _tokenURI) public',
      'function payWinner() public returns (address)',
      'function sendEther(address payable _to, uint256 _amount) public payable',
      'function getRandomInt(uint256 _endingValue) public view returns (uint256)',
      'function _burn(uint256 tokenId) public',
      'function tokenURI(uint256 _tokenId) public view returns (string memory)',
      'function _beforeTokenTransfer(address from, address to,uint256 tokenId) public',
      'function supportsInterface(bytes4 interfaceId) public view returns (bool)',
    ]

    const proxied = new ethers.Contract(proxy.address, abi, owner)
    expect(await proxied.testNewImplementation()).to.eq('it works')
  })
})
