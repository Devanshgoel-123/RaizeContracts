import { ethers } from "hardhat";
import hre from "hardhat";
import dotenv from "dotenv";
dotenv.config();
async function main() {
  //const provider = new ethers.JsonRpcProvider("https://rpc.api.moonbase.moonbeam.network");
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545/");
  const wallet = new ethers.Wallet(`${process.env.PRIVATE_KEY}`, provider);

  console.log("Deploying contract from:",await wallet.getAddress());

  const ContractFactory = await ethers.getContractFactory("MarketFactory",wallet)
 
  const contract = await ContractFactory.deploy(wallet.getAddress()); 
  await contract.waitForDeployment();

  console.log("contract deployed at",contract.target)
// //   await hre.network.provider.send("evm_increaseTime", [3600]); // Increase time by 1 hour
// // await hre.network.provider.send("evm_mine");
// await hre.network.provider.send("evm_setNextBlockTimestamp", [1743691805]); 
// await hre.network.provider.send("evm_mine");  // Mine a new block to apply the time change
   
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
