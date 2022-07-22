const { ethers, upgrades } = require('hardhat')

async function main() {
  const Contract = await ethers.getContractFactory('Lottery1')
  const contract = await upgrades.deployProxy(Contract, [], {
    initializer: 'initialize',
    kind: 'uups',
  })

  await contract.deployed()
  console.log('Lottery1 Proxy Contract deployed to:', contract.address)
  await upgrades.erc1967
    .getImplementationAddress(contract.address)
    .then((data) => {
      console.log('Lottery1 Implementation Contract deployed to:', contract.address)
    })
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
