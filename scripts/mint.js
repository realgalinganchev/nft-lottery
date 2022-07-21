require('@nomiclabs/hardhat-ethers')
const { ethers } = require('hardhat')
const contract = require('../artifacts/contracts/Ticket.sol/Ticket.json')
const contractInterface = contract.abi

// https://hardhat.org/plugins/nomiclabs-hardhat-ethers.html#provider-object
let provider = ethers.provider

const tokenURI = 'https://opensea-creatures-api.herokuapp.com/api/creature/1'
const wallet = new ethers.Wallet(
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
)

wallet.provider = provider
const signer = wallet.connect(provider)

// https://docs.ethers.io/v5/api/contract/contract
const nft = new ethers.Contract(
  '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  contractInterface,
  signer,
)

async function main() {
  console.log('Waiting for 1 block for confirmation...')
  const options = {
    value: ethers.utils.parseEther('1'),
  }
  if (provider) {
    provider.listAccounts().then(function (accounts) {
      provider.getBalance(accounts[0]).then(function (balance) {
        // balance is a BigNumber (in wei); format is as a sting (in ether)
        var etherString = ethers.utils.formatEther(balance)

        console.log('Balance: ' + etherString)
      })
    })
  }

  // nft
  //   .initLottery(5, 10)
  //   .then((tx) => tx.wait(1))
  //   .then((receipt) =>
  //     console.log(`Your transaction is confirmed, its receipt is: 
  //   ${receipt.status}
  //   ${receipt.contractAddress}`),
  //   )
  //   .catch((e) => console.log('something went wrong', e))
  nft
    .mint(tokenURI, options)
    .then((tx) => tx.wait(1))
    .then((receipt) =>
      console.log(`Your transaction is confirmed, its receipt is: 
    ${receipt.status}
    ${receipt.contractAddress}`),
    )
    .catch((e) => console.log('something went wrong', e))

    // nft
    // .fallback(options)
    // .then((tx) => tx.wait(1))
    // .then((receipt) =>
    //   console.log(`Your transaction is confirmed, its receipt is: 
    // ${receipt.status}
    // ${receipt.contractAddress}
    // ${receipt.blockNumber}`),
    // )
    // .catch((e) => console.log('something went wrong', e))

  let ticketBalance = nft.address
  var balanceInWei = await ethers.provider.getBalance(ticketBalance)
  console.log('Balance: ' + ethers.utils.formatUnits(balanceInWei))
}

main()
// .then(() => process.exit(0))
// .catch((error) => {
//   console.error(error)
//   process.exit(1)
// })
