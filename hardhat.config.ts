import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const PRIVATE_KEY = vars.get("PRIVATE_KEY")
const  ALCHEMY_API_KEY = vars.get("ALCHEMY_API_KEY")
const POLYGONSCAN_API_KEY = vars.get("POLYGONSCAN_API_KEY")

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    amoy: {
      url: `https://polygon-amoy.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: `${POLYGONSCAN_API_KEY}`,
  },
};


export default config;
