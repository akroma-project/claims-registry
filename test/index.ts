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
  let contract!: AkromaClaimsRegistry;
  let testKey = "username";
  let testValue = "detroitpro";
  const pausedMessage = "Paused: the contract is paused, no claims can be set";

  before(async function () {
    [owner, user, server] = await ethers.getSigners();
  });

  describe("deployment", async () => {

    it("should deploy without exceptions", async () => {
      const Contract = await ethers.getContractFactory("AkromaClaimsRegistry");
      contract = (await Contract.deploy('unit-test', 'url', 2.0)) as AkromaClaimsRegistry;

      await contract.deployed();

      expect(contract.address).to.be.properAddress;

      expect(await contract.name()).to.equal('unit-test');
      expect(await contract.url()).to.equal('url');
      expect(await contract.id()).to.equal('0xa550e5a5'); // updated contract id with new methods.
      expect(await contract.cost()).to.equal(2.0);
    })

  });

  describe("default state after deployment", async () => {

    it("registry should be empty", async function () {
      expect(await contract.getClaim(server.address, server.address, keccak256("test"))).to.equal('');
    });

  });

  describe("user using registry", async () => {

    it("should allow any user to store a claim", async function () {
      const subject = user.address;
      const key = keccak256(testKey);
      const value = ethers.utils.formatBytes32String(testValue);
      console.debug(`Subject: ${subject} Key: ${testKey} Value: ${value}`);
      await contract.connect(owner).setClaim(subject, key, value, { value: 2 });
    });

    it("should be able to look up values based on issuer, subject and key", async function () {
      const issuer = owner.address;
      const subject = user.address;
      const key = keccak256(testKey)
      console.debug(`Issuer: ${issuer} Subject: ${subject} Key: ${testKey}`);
      const claim = await contract.getClaim(issuer, subject, key);
      // let claim = await contract.registry(issuer, subject, key);
      
      const encoded = ethers.utils.formatBytes32String(testValue);
      console.debug(`Claim: ${claim} testValue: ${testValue} encoded: ${encoded}`);
      expect(claim).to.equal(encoded);


      // decode the claim
      const decoded = ethers.utils.parseBytes32String(claim);
      expect(decoded).to.equal(testValue);
    });

    it("not require encoding string", async function () {
      const issuer = owner.address;
      const subject = user.address;
      const key = keccak256(testKey);
      const value = ethers.utils.formatBytes32String(testValue);
      console.debug(`Subject: ${subject} Key: ${testKey} Value: ${value}`);
      await contract.connect(owner).setClaim(subject, key, value, { value: 2 });

      const claim = await contract.getClaim(issuer, subject, key);
      const decoded = ethers.utils.parseBytes32String(claim);
      expect(decoded).to.equal(testValue);
    });

  });

  describe("when someone tries to use registry with invalid params", async () => {

    it("should now allow any user to store a claim without paying AKA", async function () {
      const subject = user.address;
      const key = ethers.utils.formatBytes32String(testKey);
      const value = ethers.utils.formatBytes32String(testValue);

      await expect(
        contract.connect(owner).setClaim(subject, key, value, { value: 1 })
      ).to.be.revertedWith("Not enough AKA sent to set claim, check cost");
    });

  });

  describe("when contract is paused", async () => {

    it("should not allow any user to store a claim", async function () { 
      await contract.connect(owner).setPaused(true);

      const subject = user.address;
      const key = ethers.utils.formatBytes32String(testKey);
      const value = ethers.utils.formatBytes32String(testValue);

      await expect(
        contract.connect(owner).setClaim(subject, key, value, { value: 2 })
      ).to.be.revertedWith(pausedMessage);
    });

    it("should now allow any user to store a claim no matter how much AKA they send", async function () {
      const subject = user.address;
      const key = ethers.utils.formatBytes32String(testKey);
      const value = ethers.utils.formatBytes32String(testValue);

      await expect(
        contract.connect(owner).setClaim(subject, key, value, { value: 10 })
      ).to.be.revertedWith(pausedMessage);
    });

  });

});
