const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EvidenceCustody", function () {
  it("registers evidence and transfers custody", async function () {
    const [admin, alice, bob] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("EvidenceCustody");
    const custody = await Factory.deploy();

    await custody.setCustodian(alice.address, true);
    await custody.setCustodian(bob.address, true);

    const evidenceId = ethers.id("EV-001");
    const contentHash = ethers.id("sample-evidence-bytes");

    await custody.registerEvidence(evidenceId, contentHash, alice.address);
    let record = await custody.getEvidence(evidenceId);
    expect(record.custodian).to.equal(alice.address);

    await custody.connect(alice).transferCustody(evidenceId, bob.address);
    record = await custody.getEvidence(evidenceId);
    expect(record.custodian).to.equal(bob.address);
    expect(record.contentHash).to.equal(contentHash);
  });
});
