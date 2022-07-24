require('@nomicfoundation/hardhat-toolbox')
require('hardhat-gas-reporter')
require('solidity-coverage')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.12',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    localhost: {
      mining: {
        mempool: {
          order: 'fifo',
        },
      },
    },
  },
}
