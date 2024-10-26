import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("hardhat-contract-sizer");

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100,
      },
    },
  },
  contractSizer: {
    alphaSort: true, // Sort contracts alphabetically
    runOnCompile: true, // Automatically run size check on compile
    disambiguatePaths: false, // Resolve any duplicate contract names
  },

  networks: {
    sepolia: {
      url: vars.get("SEPOLIA_URL"),
      accounts: [`0x${vars.get("PRIVATE_KEY")}`],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: vars.get("ETHERSCAN_API_KEY"),
    },
  },
};

export default config;
