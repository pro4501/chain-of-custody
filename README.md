# Chain of Custody Management System

Ethereum DApp for **tamper-evident digital evidence tracking**. Evidence hashes and custody transfers are recorded on-chain so integrity and access history can be verified independently of any single database.

Built to mirror real DFIR chain-of-custody principles: who held the exhibit, when, and whether the hash still matches.

## Why recruiters care

| Skill | How this repo shows it |
|-------|-------------------------|
| Digital forensics | Exhibit registration, hash binding, custody handoff |
| Smart contracts | Solidity access control + event log |
| Security thinking | Least privilege roles, immutable audit trail |

## Architecture

```text
Evidence registered → SHA-256 hash stored on-chain
       ↓
Custodian transfer (role-gated) → Transfer event emitted
       ↓
Anyone can verify hash / custody history from the ledger
```

### Roles
- **Admin** — register exhibits, assign initial custodian
- **Custodian** — transfer custody to another authorised address
- **Auditor** (read-only off-chain) — verify hashes and timeline from events

## Repo layout

```text
chain-of-custody/
├── contracts/
│   └── EvidenceCustody.sol   # Core contract
├── scripts/
│   └── deploy.js             # Deploy helper (Hardhat)
├── test/
│   └── EvidenceCustody.js    # Basic role + transfer tests
├── hardhat.config.js
└── README.md
```

## Quick start

```bash
npm install
npx hardhat compile
npx hardhat test
npx hardhat node          # local chain
npx hardhat run scripts/deploy.js --network localhost
```

## On-chain data model (high level)

- `evidenceId` — unique exhibit id
- `contentHash` — SHA-256 (or keccak of content hash) of the evidence blob **off-chain**
- `custodian` — current holder address
- `createdAt` / transfer timestamps via events
- **No raw evidence on-chain** — only hashes and custody metadata (privacy + cost)

## Demo flow

1. Admin registers exhibit `EV-001` with hash `0x…`
2. Custodian A transfers to Custodian B
3. Auditor recomputes local file hash and compares to on-chain value
4. Mismatch ⇒ integrity failure; match + transfer log ⇒ verifiable CoC

## Stack

`Solidity` · `Hardhat` · `Ethereum` · cryptographic hashing · role-based access control

## Disclaimer

Educational / portfolio project. Not a production evidence management system. Do not put personal data or real case files on a public chain.

## Author

**Pratham Brahmbhatt** — Cybersecurity Analyst · London  
[github.com/pro4501](https://github.com/pro4501)
