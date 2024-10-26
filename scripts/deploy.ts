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



// DeploymentLib deployed to 0x142b3fA9917052573bd6480adeed0E4599A230b3
// https://sepolia.etherscan.io/address/0x142b3fA9917052573bd6480adeed0E4599A230b3#code

// HighVFactoryLib deployed to 0x614Bb1a5ED065afc98C4419BFd293f1AE04A19BE
// https://sepolia.etherscan.io/address/0x614Bb1a5ED065afc98C4419BFd293f1AE04A19BE#code

// HighVPay deployed to 0x5386d78CDec42F022521113Ec2A783ABd9Eb50f3
// https://sepolia.etherscan.io/address/0x5386d78CDec42F022521113Ec2A783ABd9Eb50f3#code

// HighVNFT deployed to 0xd727e7aF56EF80180098617239Fd9d7F8961B8b1
// https://sepolia.etherscan.io/address/0xd727e7aF56EF80180098617239Fd9d7F8961B8b1#code

// HighVFactory contract deployed to:  0x6f4AffD4FABbbd742533109b3b9FD1E7Fcc93aa6
// https://sepolia.etherscan.io/address/0x6f4AffD4FABbbd742533109b3b9FD1E7Fcc93aa6#code