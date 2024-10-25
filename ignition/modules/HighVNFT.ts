import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
const hre = require("hardhat");

const fs = require("fs");

const HighVNFT = buildModule("HighVNFT", (m) => {
      const _owner = m.getParameter(
        "_owner",
        "0xF2E7E2f51D7C9eEa9B0313C2eCa12f8e43bd1855"
      );
    
        const _nftURI = m.getParameter(
          "_nftURI",
          "QmX6vbCCvv4K36z7p1ovfEEBf8UVVvqJ74iLfT1TFcNkGb"
        );

  const nft = m.contract("HighVNFT", [_owner, _nftURI]);

  //todo: This code is used to calculate contract bytecode size so it won't be more than the 24,576 bytes size limit
  const contractArtifact = 
        JSON.parse(fs.readFileSync("./artifacts/contracts/HighVNFT.sol/HighVNFT.json", "utf8"));
  const bytecode = contractArtifact.bytecode;
  const bytecodeSize = bytecode.length / 2 - 1; // Each byte is represented by two hex characters
  console.log(`HighVNFT bytecode size: ${bytecodeSize} bytes`);

  return { nft };
});

export default HighVNFT;