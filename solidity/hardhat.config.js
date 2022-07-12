require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "kovan",
  networks: {
    hardhat: {},
    kovan: {
      url: "kovan url https",
      accounts: ["Kovan metamask private key"]
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "etherscan apikey"
  },
  solidity: "0.8.9",
};
