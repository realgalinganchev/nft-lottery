const { ethers } = require('hardhat')

async function main() {
  const Ticket = await ethers.getContractFactory('Ticket')

  // Start deployment, returning a promise that resolves to a contract object
  const ticket = await Ticket.deploy('Ticket', 'TKT')
  await ticket.deployed()
  console.log('Contract deployed to address:', ticket.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
