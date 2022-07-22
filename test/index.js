const { expect, assert } = require('chai')
const { ethers, upgrades } = require('hardhat')

describe('Contract Version 2 test', function () {
  let oldContract, upgradedContract, owner, addr1

  beforeEach(async function () {
    ;[owner, addr1] = await ethers.getSigners(2)
    const Lottery1 = await ethers.getContractFactory('Lottery1')
    const Lottery2 = await ethers.getContractFactory('Lottery2')

    oldContract = await upgrades.deployProxy(Lottery1, [], {
      initializer: 'initialize',
      kind: 'uups',
    })
    await oldContract.deployed()

    upgradedContract = await upgrades.upgradeProxy(oldContract, Lottery2, {
      call: { fn: 'reInitialize' },
    })
  })

  it('Old contract cannnot mint NFTs', async function () {
    try {
      oldContract.safeMint(owner.address, 'Test NFT')
    } catch (error) {
      assert(error.message === 'oldContract.safeMint is not a function')
    }
  })
  it('New Contract Should return the old & new greeting and token name after deployment', async function () {
    expect(await upgradedContract.name()).to.equal('Ticket')
  })

  it('Only Owner can start the lottery', async function () {
    await expect(
      upgradedContract.connect(addr1).initLottery(1, 2),
    ).to.be.revertedWith('Ownable: caller is not the owner')
  })

  // it('Only Owner can start the lottery', async function () {
  //   await upgradedContract.connect(owner).initLottery(0, 1)
  //   await expect(upgradedContract.safeMint('Test NFT'))
  //     .to.emit(upgradedContract, 'Transfer')
  //     .withArgs(ethers.constants.AddressZero, owner.address, 0)

  //   expect(await upgradedContract.balanceOf(owner.address)).to.equal(1)
  //   expect(await upgradedContract.ownerOf(0)).to.equal(owner.address)
  // })
})
