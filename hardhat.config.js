require('@nomicfoundation/hardhat-toolbox')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.1',
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
      gas: 8000000,
      gasPrice: 30000000000,
    },

    // ganache: {
    //   chainId: 5777,
    //   url: 'http://127.0.0.1:7545',
    // },
  },
}
