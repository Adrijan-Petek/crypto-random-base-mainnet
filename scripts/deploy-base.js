const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const vrfCoordinator = process.env.VRF_COORDINATOR || "0xYourBaseVrfCoordinator";
  const subscriptionId = process.env.VRF_SUBSCRIPTION_ID || "0";
  const keyHash = process.env.VRF_KEY_HASH || "0xYourKeyHash";

  console.log("Using VRF Coordinator:", vrfCoordinator);
  console.log("Using subscription ID:", subscriptionId);
  console.log("Using keyHash:", keyHash);

  const RandomVRFGame = await hre.ethers.getContractFactory("RandomVRFGame");
  const game = await RandomVRFGame.deploy(vrfCoordinator, subscriptionId, keyHash);
  await game.deployed();

  console.log("RandomVRFGame deployed to:", game.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
