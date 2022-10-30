import chai, { expect } from "chai";
import ChaiAsPromised from "chai-as-promised";
import { ethers } from "hardhat";
import keccak256 from "keccak256";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { AkromaClaimsRegistry } from "../typechain";

chai.use(ChaiAsPromised);

describe("Akroma Claims Registry", function () {
  let owner!: SignerWithAddress;
  let user!: SignerWithAddress;
  let server!: SignerWithAddress;
  let externalUser!: SignerWithAddress;
  let contract!: AkromaClaimsRegistry;
  let noAddress = "0x0000000000000000000000000000000000000000000000000000000000000000";
  let testKey = "username";
  let testValue = "detroitpro";

  before(async function () {
    [owner, user, server, externalUser] = await ethers.getSigners();
  });

  describe("deployment", async () => {

    it("should deploy without exceptions", async () => {
      const Contract = await ethers.getContractFactory("AkromaClaimsRegistry");
      contract = (await Contract.deploy()) as AkromaClaimsRegistry;

      await contract.deployed();
    })

  });

  describe("default state after deployment", async () => {

    it("registry should be empty", async function () {
      expect(await contract.getClaim(server.address, server.address, keccak256("test"))).to.equal(noAddress);
    });

  });

  describe("user using registry", async () => {

    it("should allow any user to store a claim", async function () {
      const subject = user.address;
      const key = ethers.utils.formatBytes32String(testKey);
      const value = ethers.utils.formatBytes32String(testValue);
      await contract.setClaim(subject, key, value);
    });

    it("should be able to look up values based on issuer, subject and key", async function () {
      const issuer = owner.address;
      const subject = user.address;
      const key = ethers.utils.formatBytes32String(testKey);

      // const claim = await contract.getClaim(issuer, subject, key);
      let claim = await contract.registry(issuer, subject, key);
      expect(claim).to.equal(ethers.utils.formatBytes32String(testValue));


      // decode the claim
      const decoded = ethers.utils.parseBytes32String(claim);
      expect(decoded).to.equal(testValue);
    });

  });

});
