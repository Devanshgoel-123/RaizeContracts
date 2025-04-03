import { HardhatUserConfig } from "hardhat/config";
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
    // moonbase: {
    //   url: "https://rpc.api.moonbase.moonbeam.network",
    //   accounts: [process.env.PRIVATE_KEY as string], 
    //   chainId: 1287, 
    // },
    // moonbeam: {
    //   url: "wss://moonbeam.unitedbloc.com:3001",
    //   accounts: [process.env.PRIVATE_KEY as string],
    //   chainId: 1284,
    // },
    hardhat: {
      forking: {
        url: 'https://rpc.api.moonbeam.network',
      },
      accounts:[
        {
          privateKey:`${process.env.PRIVATE_KEY}`,
          balance:"100000000000000000000"
        }
      ]
    },
  },

};
export default config;
