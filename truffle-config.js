const PrivateKeyProvider = require("@truffle/hdwallet-provider");
 
const privateKey = "0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63";
const privateKeyProviderMainnet = new PrivateKeyProvider(privateKey, "https://besu.chainz.network");
 
module.exports = {
 
  networks: {
    // mainnet
    besu: {
      provider: privateKeyProviderMainnet,
      gasPrice: 0,
      network_id: "2020"
    },

    
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.5.8",    // Fetch exact version from solc-bin (default: truffle's version)
      docker: false,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {           // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: false,
         runs: 200
       },
       evmVersion: "constantinople"
      }
    }
  }
};
