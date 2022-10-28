import chai, { expect } from "chai";
import ChaiAsPromised from "chai-as-promised";
import { BigNumber, utils } from "ethers";
import { ethers } from "hardhat";
import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";
import CollectionConfig from "../config/CollectionConfig";
import ContractArguments from "../config/ContractArguments";
import { NftContractType } from "../lib/NftContractProvider";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

chai.use(ChaiAsPromised);

describe(CollectionConfig.contractName, function () {
  let owner!: SignerWithAddress;
  let whitelistedUser!: SignerWithAddress;
  let holder!: SignerWithAddress;
  let externalUser!: SignerWithAddress;
  let contract!: NftContractType;

  before(async function () {
    [owner, whitelistedUser, holder, externalUser] = await ethers.getSigners();
  });

  it("Contract deployment", async function () {
    const Contract = await ethers.getContractFactory(
      CollectionConfig.contractName
    );
    contract = (await Contract.deploy(...ContractArguments)) as NftContractType;

    await contract.deployed();
  });

  it("Token URI generation", async function () {
    // const uriPrefix = "ipfs://__COLLECTION_CID__/";
    // const uriSuffix = ".json";
    // const totalSupply = await contract.totalSupply();

    // expect(await contract.tokenURI(1)).to.equal(
    //   CollectionConfig.hiddenMetadataUri
    // );

    // // Reveal collection
    // await contract.setUriPrefix(uriPrefix);
    // await contract.setRevealed(true);

    // // ERC721A uses token IDs starting from 0 internally...
    // await expect(contract.tokenURI(0)).to.be.revertedWith(
    //   "ERC721Metadata: URI query for nonexistent token"
    // );

    // // Testing first and last minted tokens
    // expect(await contract.tokenURI(1)).to.equal(`${uriPrefix}1${uriSuffix}`);
    // expect(await contract.tokenURI(totalSupply)).to.equal(
    //   `${uriPrefix}${totalSupply}${uriSuffix}`
    // );
  });
});
