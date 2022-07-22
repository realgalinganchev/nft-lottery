const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('Ticket Smart Contract Tests', function () {
  let ticket

  this.beforeEach(async function () {
    // This is executed before each test
    // Deploying the smart contract
    const Ticket = await ethers.getContractFactory('Ticket')
    ticket = await Ticket.deploy('Ticket', 'TKT')
  })

  it('NFT is minted successfully', async function () {
    ;[account1] = await ethers.getSigners()
    console.log(account1.getAddress())
    expect(await ticket.balanceOf(account1.address)).to.equal(0)
    const options = {
      value: ethers.utils.parseEther('1'),
    }
    const tokenURI =
      'https://opensea-creatures-api.herokuapp.com/api/creature/1'
    const tx = await ticket.connect(account1).mint(tokenURI, options)

    expect(await ticket.balanceOf(account1.address)).to.equal(1)
  })

  it('tokenURI is set sucessfully', async function () {
    ;[account1, account2] = await ethers.getSigners()
    console.log(account1.getAddress())
    console.log(account2.getAddress())
    const options = {
      value: ethers.utils.parseEther('1'),
    }
    const tokenURI_1 =
      'https://opensea-creatures-api.herokuapp.com/api/creature/1'
    const tokenURI_2 =
      'https://opensea-creatures-api.herokuapp.com/api/creature/2'

    const tx1 = await ticket.connect(account1).mint(tokenURI_1, options)
    const tx2 = await ticket.connect(account2).mint(tokenURI_2, options)
    expect(await ticket.tokenURI(0)).to.equal(tokenURI_1)
    expect(await ticket.tokenURI(1)).to.equal(tokenURI_2)
  })
})
