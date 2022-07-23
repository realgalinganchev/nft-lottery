require('@nomiclabs/hardhat-ethers')
const { ethers } = require('hardhat')
const contract = require('../artifacts/contracts/Ticket.sol/Ticket.json')
const contractInterface = contract.abi

let provider = ethers.provider
const tokenURI0 = 'https://opensea-creatures-api.herokuapp.com/api/creature/0'
const walletOwner = new ethers.Wallet(
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
)
walletOwner.provider = provider
const signerOwner = walletOwner.connect(provider)
const lotteryContract = new ethers.Contract(
  '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  contractInterface,
  signerOwner,
)

async function main() {
  const options = {
    gasPrice: ethers.getDefaultProvider().getGasPrice(),
    gasLimit: 5000000,
    value: ethers.utils.parseEther('1'),
  }
  const options0 = {
    value: ethers.utils.parseEther('0'),
  }

  ;[owner, player1, player2] = await ethers.getSigners()

  if (provider) {
    provider.listAccounts().then(function (accounts) {
      provider.getBalance(accounts[0]).then(function (balance) {
        console.log('Balance Owner: ' + ethers.utils.formatEther(balance))
      })
      provider.getBalance(accounts[1]).then(function (balance) {
        console.log('Balance Player 1: ' + ethers.utils.formatEther(balance))
      })
      provider.getBalance(accounts[2]).then(function (balance) {
        console.log('Balance Player 2: ' + ethers.utils.formatEther(balance))
      })
    })
  }
  let lotteryContractBalance = lotteryContract.address
  var balanceInWei = await ethers.provider.getBalance(lotteryContractBalance)
  console.log(
    'Balance in lottery contract: ' + ethers.utils.formatUnits(balanceInWei),
  )

  // lotteryContract
  //   .initLottery(4, 8)
  //   .then((tx) => tx.wait(1))

  // lotteryContract
  //   .connect(player2)
  //   .safeMint(tokenURI0, options)
  //   .then((tx) => tx.wait(1))

  lotteryContract.fallback(options0).then((tx) => tx.wait(1))
}
main()
