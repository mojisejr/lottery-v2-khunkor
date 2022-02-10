const { expect } = require("chai");
const { ethers } = require("hardhat");

let nftFactory;
let nft;

let acc1;

describe("Lottery NFT svg Test", () => {
  before(async () => {
    nftFactory = await ethers.getContractFactory("LotteryNFT");
    nft = await nftFactory.deploy();
    await nft.deployed();

    const signers = await ethers.getSigners();
    acc1 = signers[0];

    console.log("lottery deployed address: ", nft.address);
  });

  it("should be able to mint NFT", async () => {
    // function newLotteryItem(address player, uint8[4] memory _lotteryNumbers, uint256 _amount, uint256 _issueIndex)
    let nums = [1, 8, 9, 4];
    await nft.newLotteryItem(acc1.address, nums, 3, 1);
    expect((await nft.totalSupply()).toString()).to.equal("1");
  });

  it("should be able to show tokenURI", async () => {
    const lotteryNumber = await nft.getLotteryNumbers(1);
    console.log("lottery number is: ", lotteryNumber);
    const tokenURI = await nft.tokenURI(1);
    console.log(tokenURI);
    expect(tokenURI.toString()).to.not.equal("");
  });
});
