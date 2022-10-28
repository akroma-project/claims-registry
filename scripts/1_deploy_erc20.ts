import { ethers } from "hardhat";
import { NftContractType } from "../lib/NftContractProvider";
import ContractArguments from "../config/ContractArguments";

async function main() {
  console.log("Deploying ERC20 contract...");

  // We get the contract to deploy
  const Contract = await ethers.getContractFactory("SampleToken");
  const contract = (await Contract.deploy(
    ...ContractArguments
  )) as NftContractType;

  await contract.deployed();

  console.log("Contract deployed to:", contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
