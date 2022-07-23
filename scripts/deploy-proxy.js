const { ethers, upgrades } = require('hardhat')

async function main() {
  const Factory = await ethers.getContractFactory('Factory')
  const factory = await Factory.deploy()
  await factory.deployed()

  const Proxy = await ethers.getContractFactory('Proxy')
  const proxy = await Proxy.deploy()
  await proxy.deployed()

  const computedAddress = await factory.computeAddress(42, proxy.address)
  console.log('computedAddress :>> ', computedAddress)
  await factory.deploy(42, proxy.address)
  const proxy1 = proxy.attach(computedAddress)

  const LogicV2 = await ethers.getContractFactory('TicketV2')
  const logicv2 = await LogicV2.deploy('TicketV2', 'TKTV2')
  await logicv2.deployed()
  console.log(
    'current Implementation address',
    await proxy1.getImplementation(),
  )
  await proxy1.setImplementation(logicv2.address)
  console.log(
    'current Implementation address',
    await proxy1.getImplementation(),
  )
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
