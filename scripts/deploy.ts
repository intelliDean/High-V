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


// DeploymentLib deployed to 0xC7B5650610912ECb3f6D99b188e43466BB955ef6
//https://sepolia.etherscan.io/address/0xC7B5650610912ECb3f6D99b188e43466BB955ef6#code

// HighVFactoryLib deployed to 0x77b70CAB1E0351035e93D6BCBF3B8de50B42bde9
// https://sepolia.etherscan.io/address/0x77b70CAB1E0351035e93D6BCBF3B8de50B42bde9#code

// HighVPay deployed to 0x1174c5267Ed28E3F17A3b52Aa89368058aCd940e
// https://sepolia.etherscan.io/address/0x1174c5267Ed28E3F17A3b52Aa89368058aCd940e#code

// HighVNFT deployed to 0x53f7Fe126036cDFe01016733ad010F8268E21138
// https://sepolia.etherscan.io/address/0x53f7Fe126036cDFe01016733ad010F8268E21138#code

// HighVFactory contract deployed to:  0xDdA7a1e047deb3eB730aAf6E7B4359F1Ae1D97cE
// https://sepolia.etherscan.io/address/0xDdA7a1e047deb3eB730aAf6E7B4359F1Ae1D97cE#code