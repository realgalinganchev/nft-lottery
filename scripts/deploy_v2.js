const { ethers, upgrades } = require('hardhat')

const PROXY_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512' //Address of version 1
const VERSION1 = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512' //Address of the version 1 implementation

async function main() {
  const Contract = await ethers.getContractFactory('Lottery2')
  const contract = await upgrades.upgradeProxy(PROXY_ADDRESS, Contract, {
    call: { fn: 'reInitialize' },
    kind: 'uups',
  })
  console.log('Lottery 2 deployed to:', contract.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
