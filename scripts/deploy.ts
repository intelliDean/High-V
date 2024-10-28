import hre from "hardhat";
import {vars } from "hardhat/config";
import HighVNFTModule from "../ignition/modules/HighVNFT";
import HighVPayModule from "../ignition/modules/HighVPay";
import DeploymentLib from "../ignition/modules/DeploymentLib";
import HighVFactoryLib from "../ignition/modules/HighVFactoryLib";

//I had to make the functions of this library internal
//because I found it difficult to link it with the HighV contract
//being that it's being deployed in a factory contract and not through script
// import HighV from "../ignition/modules/HighVLib";

async function main() {
  
  const deploy = await hre.ignition.deploy(DeploymentLib);
  const deployAddress = deploy.deployment.target;
  console.log(`DeploymentLib deployed to ${deployAddress}`);

  const factoryLib = await hre.ignition.deploy(HighVFactoryLib);
  const factoryLibdeployAddress = factoryLib.highVFactory.target;
  console.log(`HighVFactoryLib deployed to ${factoryLibdeployAddress}`);

  const highVPay = await hre.ignition.deploy(HighVPayModule);
  const highVPayAddress = highVPay.pay.target;
  console.log(`HighVPay deployed to ${highVPayAddress}`);

  const highVNFT = await hre.ignition.deploy(HighVNFTModule);
  const nftAddress = highVNFT.nft.target;
  console.log(`HighVNFT deployed to ${nftAddress}`);

  const HighVFactory = await hre.ethers.getContractFactory("HighVFactory", {
    libraries: {
      DeploymentLib: deployAddress,
      HighVFactoryLib: factoryLibdeployAddress,
    },
  });

  const owner = vars.get("ACCOUNT_ADDRESS");
  const res = await HighVFactory.deploy(owner, highVNFT.nft.target);

  console.log("HighVFactory contract deployed to: ", res.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});



// DeploymentLib deployed to 0x31de5697a0C375b7842126Fb6964713535FA7604
// HighVFactoryLib deployed to 0x92B8c6fb3E1a8988e9eb8Afcfb6895c839470708

// HighVPay deployed to 0xE0fd265B43d5820957E1f0306f370Ca7f7dadf1F
// https://sepolia.etherscan.io/address/0xE0fd265B43d5820957E1f0306f370Ca7f7dadf1F#code

// HighVNFT deployed to 0x76cF9b8290824B73A477125ba322E13ab455d584
// https://sepolia.etherscan.io/address/0x76cF9b8290824B73A477125ba322E13ab455d584#code

// HighVFactory contract deployed to:  0xC4D840Ec9dAf12395B35Db6FA6A37D703f7F9284
// https://sepolia.etherscan.io/address/0xC4D840Ec9dAf12395B35Db6FA6A37D703f7F9284#code
