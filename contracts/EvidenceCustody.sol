// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EvidenceCustody
 * @notice Minimal chain-of-custody registry for digital evidence hashes.
 *         Stores integrity hashes + custodians; emits an auditable transfer log.
 *         Portfolio / education use — not production DFIR tooling.
 */
contract EvidenceCustody {
    address public admin;

    struct Evidence {
        bytes32 contentHash;
        address custodian;
        uint256 registeredAt;
        bool exists;
    }

    mapping(bytes32 => Evidence) private evidences;
    mapping(address => bool) public isCustodian;

    event EvidenceRegistered(
        bytes32 indexed evidenceId,
        bytes32 contentHash,
        address indexed custodian,
        uint256 timestamp
    );
    event CustodyTransferred(
        bytes32 indexed evidenceId,
        address indexed from,
        address indexed to,
        uint256 timestamp
    );
    event CustodianUpdated(address indexed account, bool allowed);

    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }

    modifier onlyCurrentCustodian(bytes32 evidenceId) {
        require(evidences[evidenceId].exists, "unknown evidence");
        require(msg.sender == evidences[evidenceId].custodian, "not custodian");
        _;
    }

    constructor() {
        admin = msg.sender;
        isCustodian[msg.sender] = true;
    }

    function setCustodian(address account, bool allowed) external onlyAdmin {
        isCustodian[account] = allowed;
        emit CustodianUpdated(account, allowed);
    }

    function registerEvidence(
        bytes32 evidenceId,
        bytes32 contentHash,
        address initialCustodian
    ) external onlyAdmin {
        require(!evidences[evidenceId].exists, "already registered");
        require(contentHash != bytes32(0), "empty hash");
        require(isCustodian[initialCustodian], "custodian not allowed");

        evidences[evidenceId] = Evidence({
            contentHash: contentHash,
            custodian: initialCustodian,
            registeredAt: block.timestamp,
            exists: true
        });

        emit EvidenceRegistered(
            evidenceId,
            contentHash,
            initialCustodian,
            block.timestamp
        );
    }

    function transferCustody(bytes32 evidenceId, address to)
        external
        onlyCurrentCustodian(evidenceId)
    {
        require(isCustodian[to], "recipient not allowed");
        address from = evidences[evidenceId].custodian;
        evidences[evidenceId].custodian = to;
        emit CustodyTransferred(evidenceId, from, to, block.timestamp);
    }

    function getEvidence(bytes32 evidenceId)
        external
        view
        returns (bytes32 contentHash, address custodian, uint256 registeredAt)
    {
        require(evidences[evidenceId].exists, "unknown evidence");
        Evidence storage e = evidences[evidenceId];
        return (e.contentHash, e.custodian, e.registeredAt);
    }
}
