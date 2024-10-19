import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
const hre = require("hardhat");

const fs = require("fs");


const LockModule = buildModule("LockModule", (m) => {

  const lock = m.contract("StableToken", [
    "0xF2E7E2f51D7C9eEa9B0313C2eCa12f8e43bd1855",
  ]);

  //todo: This code is used to calculate contract bytecode size so it won't be more than the 24,576 bytes size limit
  const contractArtifact = JSON.parse(
    fs.readFileSync("./artifacts/contracts/Lock.sol/Lock.json", "utf8")
  );
  const bytecode = contractArtifact.bytecode;
  const bytecodeSize = bytecode.length / 2 - 1; // Each byte is represented by two hex characters
  console.log(`Bytecode size: ${bytecodeSize} bytes`);

  return { lock };
});

export default LockModule;
