import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const fs = require('fs');

const JAN_1ST_2030 = 1893456000;
const ONE_GWEI: bigint = 1_000_000_000n;

const LockModule = buildModule("LockModule", (m) => {
  const unlockTime = m.getParameter("unlockTime", JAN_1ST_2030);
  const lockedAmount = m.getParameter("lockedAmount", ONE_GWEI);

  const lock = m.contract("Lock", [unlockTime], {
    value: lockedAmount,
  });


  //todo: This code is used to calculate contract bytecode size so it won't be more than the 24,576 bytes size limit
  const contractArtifact = JSON.parse(fs.readFileSync('./artifacts/contracts/Lock.sol/Lock.json', 'utf8'));
  const bytecode = contractArtifact.bytecode;
  const bytecodeSize = bytecode.length / 2 - 1; // Each byte is represented by two hex characters
  console.log(`Bytecode size: ${bytecodeSize} bytes`);


  return { lock };
});

export default LockModule;
