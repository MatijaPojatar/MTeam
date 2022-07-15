require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "kovan",
  networks: {
    hardhat: {},
    kovan: {
      url: "https://kovan.infura.io/v3/d535298504ac468eb14672b06e22469a",
      accounts: ["ab934778c81f2e6c63b9ce6ac731e36e86301d93cc13df2376c5ee51487a1412"]
    },
    local: {
      url: "http://127.0.0.1:8545",
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "PNK2JB8N1QI4U7WFYHF2YSJI7J77X2I9TG"
  },
  solidity: "0.8.9",
};
