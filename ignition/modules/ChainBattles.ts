// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {BigNumberish} from "ethers";

const ChainBattlesMOdule = buildModule("ChainBattlesMOdule", (m) => {
  const subId: BigNumberish = "9018649917588802380560221254434479688035158009258620595895018759960165471622"
  //passing constructor parameters
  const chainBattles = m.contract("ChainBattles", [subId]);

  return { chainBattles };
});

export default ChainBattlesMOdule;
