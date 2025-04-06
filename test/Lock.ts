import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lock", function () {
  async function deployContractAndSetVariables() {
    const MarketFactory = await ethers.getContractFactory("MarketFactory");
    const marketFactory = await MarketFactory.deploy(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    );

    return { marketFactory };
  }
 
  it("Should set the right admin of the contract correctly", async function () {
    const {marketFactory} = await loadFixture(deployContractAndSetVariables);
    console.log("the value is",await marketFactory.admin())
    expect(await marketFactory.admin()).to.equal("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  });
  

  it("Should create a normal market correctly",async function (){
    const wallet=await ethers.getSigner("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    const {marketFactory} = await loadFixture(deployContractAndSetVariables);
    console.log("creating market")
    const tx=await marketFactory.connect(wallet).create_market(
      "Will Trump Win the elections ?",
      "Will Doland Trump win the 2024 elections in US?",
      "Yes",
      "No",
      "Politics",
      "https://stellaswap.medium.com/",
      1759401081
    )
    await tx.wait()
    console.log("Market created")
    expect(tx).to.be.ok;
  })


  it("Should Be able to buy shares",async function BuyShares(){
    const wallet=await ethers.getSigner("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    const {marketFactory} = await loadFixture(deployContractAndSetVariables);
    console.log("creating market")
    const tx=await marketFactory.connect(wallet).create_market(
      "Will Trump Win the elections ?",
      "Will Doland Trump win the 2024 elections in US?",
      "Yes",
      "No",
      "Politics",
      "https://stellaswap.medium.com/",
      1744024798
    )
    await tx.wait()
    const buy=await marketFactory.connect(wallet).buy_shares(
      0,
      0,
      2,
      {
        value: ethers.parseEther("10") // sending 0.1 ETH
      }
    )
    await buy.wait()
    expect(buy).to.be.ok;
  })


  it("should be able to show user positions",async function(){
    const wallet=await ethers.getSigner("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    const {marketFactory} = await loadFixture(deployContractAndSetVariables);
    const tx=await marketFactory.connect(wallet).create_market(
      "Will Trump Win the elections ?",
      "Will Doland Trump win the 2024 elections in US?",
      "Yes",
      "No",
      "Politics",
      "https://stellaswap.medium.com/",
      1744024798
    )
    await tx.wait()
    const buy=await marketFactory.connect(wallet).buy_shares(
      0,
      0,
      2,
      {
        value: ethers.parseEther("10") // sending 0.1 ETH
      }
    )
    await buy.wait()
    const buy2=await marketFactory.connect(wallet).buy_shares(
      0,
      1,
      2,
      {
        value: ethers.parseEther("5") // sending 0.1 ETH
      }
    )
    await buy2.wait()
    expect(buy2).to.be.ok;

    const user_markets=await marketFactory.connect(wallet).get_user_positions_market(wallet.address);
    console.log("The user markets are:",user_markets)
  })
});




// describe("Withdrawals", function () {
//   describe("Validations", function () {
//     it("Should revert with the right error if called too soon", async function () {
//       const { lock } = await loadFixture(deployOneYearLockFixture);

//       await expect(lock.withdraw()).to.be.revertedWith(
//         "You can't withdraw yet"
//       );
//     });

//     it("Should revert with the right error if called from another account", async function () {
//       const { lock, unlockTime, otherAccount } = await loadFixture(
//         deployOneYearLockFixture
//       );

//       // We can increase the time in Hardhat Network
//       await time.increaseTo(unlockTime);

//       // We use lock.connect() to send a transaction from another account
//       await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
//         "You aren't the owner"
//       );
//     });

//     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
//       const { lock, unlockTime } = await loadFixture(
//         deployOneYearLockFixture
//       );

//       // Transactions are sent using the first signer by default
//       await time.increaseTo(unlockTime);

//       await expect(lock.withdraw()).not.to.be.reverted;
//     });
//   });

//   describe("Events", function () {
//     it("Should emit an event on withdrawals", async function () {
//       const { lock, unlockTime, lockedAmount } = await loadFixture(
//         deployOneYearLockFixture
//       );

//       await time.increaseTo(unlockTime);

//       await expect(lock.withdraw())
//         .to.emit(lock, "Withdrawal")
//         .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
//     });
//   });

//   describe("Transfers", function () {
//     it("Should transfer the funds to the owner", async function () {
//       const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
//         deployOneYearLockFixture
//       );

//       await time.increaseTo(unlockTime);

//       await expect(lock.withdraw()).to.changeEtherBalances(
//         [owner, lock],
//         [lockedAmount, -lockedAmount]
//       );
//     });
//   });
// });