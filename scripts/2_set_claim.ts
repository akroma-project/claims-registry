import { ethers } from "hardhat";
import keccak256 from "keccak256";
import { AkromaClaimsRegistry } from "../typechain";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  console.log("Setting claim...");
  const key = keccak256('profile');
  // We get the contract to deploy
  const contract = await ethers.getContractAt("AkromaClaimsRegistry", "0xB557A2968776123eb2DC402eb5D5E123c2d6c7E0") as AkromaClaimsRegistry;
  const name = await contract.name();
  const claim = await contract.setClaim(
    '0x17218eDBBa1cEc8623D7c82ab995B0B759aB9FF6',
    key,
    "eyJ1c2VybmFtZSI6ImFzZGEiLCJpbnZpdGVkIjpbXSwib3duZWQiOltdfQ==",
  { value: '10000000000000000'});
  console.log("Claim:", claim);
  console.log("Contract name:", name);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
