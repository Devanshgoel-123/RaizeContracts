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
    // moonbeamAlpha: {
    //   url: "https://rpc.api.moonbase.moonbeam.network",
    //   accounts: [process.env.PRIVATE_KEY as string],
    //   chainId: 1287,
    // },
    // hardhat: {
    //   forking: {
    //     url: 'https://rpc.api.moonbeam.network',
    //   },
    //   accounts:[
    //     {
    //       privateKey:`${process.env.PRIVATE_KEY}`,
    //       balance:"100000000000000000000"
    //     },{
    //       privateKey:"0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd",
    //       balance:"10000000000000000000"
    //     },
    //     {
    //       privateKey:"0xde9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0",
    //       balance:"10000000000000000000"
    //     }
    //   ]
    // },
  },

};
export default config;
