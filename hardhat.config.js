require('@nomicfoundation/hardhat-toolbox')
require('@openzeppelin/hardhat-upgrades')
require("hardhat-gas-reporter")

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
      // gas: 800000000,
      // gasPrice: 300000000000000,
    },

    // ganache: {
    //   chainId: 5777,
    //   url: 'http://127.0.0.1:7545',
    // },
  },
}
