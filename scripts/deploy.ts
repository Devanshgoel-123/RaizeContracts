import { ethers } from "hardhat";

async function main() {
  const account=new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
  console.log("Deploying contract from:",account.getAddress());

  const ContractFactory = await ethers.getContractFactory("MarketFactory")
  const admin=account.getAddress();
  const contract = await ContractFactory.deploy(); 

  await contract.deployed();
  console.log("Contract deployed at:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
