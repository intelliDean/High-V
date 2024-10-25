// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const HighVFactory = buildModule("HighVFactory", (m) => {
  const highVFactory = m.contract("HighVFactoryLib");

  return { highVFactory };
});

export default HighVFactory;
