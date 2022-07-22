require('@nomiclabs/hardhat-ethers')
const { ethers } = require('hardhat')
const contract = require('../artifacts/contracts/Ticket.sol/Ticket.json')
const contractInterface = contract.abi

// https://hardhat.org/plugins/nomiclabs-hardhat-ethers.html#provider-object
let provider = ethers.provider

const tokenURI0 = 'https://opensea-creatures-api.herokuapp.com/api/creature/0'
const tokenURI1 = 'https://opensea-creatures-api.herokuapp.com/api/creature/1'
const tokenURI2 = 'https://opensea-creatures-api.herokuapp.com/api/creature/2'
const tokenURI3 = 'https://opensea-creatures-api.herokuapp.com/api/creature/3'
const tokenURI4 = 'https://opensea-creatures-api.herokuapp.com/api/creature/4'
const tokenURI5 = 'https://opensea-creatures-api.herokuapp.com/api/creature/5'

const walletOwner = new ethers.Wallet(
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
)

const walletPlayer1 = new ethers.Wallet(
  '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d',
)
const walletPlayer2 = new ethers.Wallet(
  '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a',
)

walletOwner.provider = provider

const signerOwner = walletOwner.connect(provider)

const lotteryContract = new ethers.Contract(
  '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  contractInterface,
  signerOwner,
)

async function main() {
  console.log('Waiting for 1 block for confirmation...')
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

  // lotteryContract
  //   .initLottery(3, 8)
  //   .then((tx) => tx.wait(1))
  //   .then((receipt) =>
  //     console.log(`Your transaction is confirmed, its receipt is:
  //   ${receipt.status}
  //   ${receipt.contractAddress}`),
  //   )
  //   .catch((e) => console.log('something went wrong', e))

  // lotteryContract
  //   .connect(player1)
  //   .mint(tokenURI5, options)
  //   .then((tx) => tx.wait(1))
  //   .then((receipt) =>
  //     console.log(`Your transaction is confirmed, its receipt is:
  //   ${receipt.status}
  //   ${receipt.contractAddress}`),
  //   )
  //   .catch((e) => console.log('something went wrong', e))

  lotteryContract.fallback(options0).then((tx) => tx.wait(1))

  let lotteryContractBalance = lotteryContract.address
  var balanceInWei = await ethers.provider.getBalance(lotteryContractBalance)
  console.log(
    'Balance in lottery contract: ' + ethers.utils.formatUnits(balanceInWei),
  )
}

main()
