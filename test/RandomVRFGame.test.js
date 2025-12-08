const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RandomVRFGame", function () {
  it("deploys successfully", async function () {
    const [deployer] = await ethers.getSigners();

    const vrfCoordinator = ethers.constants.AddressZero; // dummy for local
    const subscriptionId = 0;
    const keyHash = ethers.constants.HashZero;

    const RandomVRFGame = await ethers.getContractFactory("RandomVRFGame");
    const game = await RandomVRFGame.deploy(vrfCoordinator, subscriptionId, keyHash);
    await game.deployed();

    expect(await game.owner()).to.equal(deployer.address);
  });
});
