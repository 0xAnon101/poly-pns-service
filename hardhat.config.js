require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  solidity: "0.8.4",
  networks: {
    mumbai: {
      url: process.env.ALCHEMY_POLYGON_TESTNET_API_URL,
      accounts: [process.env.RINKEBY_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.RINKEBY_POLYGONSCAN_KEY,
  },
};
