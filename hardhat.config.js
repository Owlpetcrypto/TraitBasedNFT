//Goerli testnet
require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()
const dotenv = require('dotenv')

dotenv.config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: process.env.REACT_APP_GOERLI_RPC_URL,
      accounts: [process.env.REACT_APP_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.REACT_APP_ETHERSCAN_KEY,
  },
}

//localhost
// require("@nomicfoundation/hardhat-toolbox");
// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.4",
//   networks: {
//     hardhat: {
//       chainId: 1337
//     }
//   }
// };
