
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-verify"
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config()
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.21",
    settings: {
      viaIR: true, 
      optimizer: {
        enabled: true,
        runs: 200,  
      },
    },
  },
  networks: {
    moonbeam: {
      url: "https://rpc.api.moonbeam.network",
      accounts: [process.env.PRIVATE_KEY as string], 
      chainId: 1284, 
    },
  },
  etherscan:{
    apiKey:{
      moonbeam:`${process.env.ETHERSCAN_API_KEY as string}`
    },
    customChains:[
      {
        network: "moonbeam",
        chainId: 1284,
        urls: {
          apiURL: "https://api-moonbeam.moonscan.io/api",
          browserURL: "https://moonscan.io/",
        }
      }
    ]
  }
};
export default config;
