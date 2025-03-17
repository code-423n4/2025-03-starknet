# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration. This is your audit repo, which is used for scoping your audit and for providing information to wardens

Some of the checklists in this doc are for our scouts and some of them are for **you as the audit sponsor (⭐️)**.

---

# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Confirm that this repo is a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)

## ⭐️ Sponsor: Repo checklist

- [ ] Modify the [Overview](#overview) section of this `README.md` file. Describe how your code is supposed to work with links to any relevant documentation and any other criteria/details that the auditors should keep in mind when reviewing. (Here are two well-constructed examples: [Ajna Protocol](https://github.com/code-423n4/2023-05-ajna) and [Maia DAO Ecosystem](https://github.com/code-423n4/2023-05-maia))
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] Review and confirm the details created by the Scout (technical reviewer) who was assigned to your contest. *Note: any files not listed as "in scope" will be considered out of scope for the purposes of judging, even if the file will be part of the deployed contracts.*  

---

# StarkWare audit details
- Total Prize Pool: $150,000 in USDC
  - HM awards: up to $140,000 in USDC 
    - If no valid Highs are found, the HM pool is $40,000 in USDC
    - If no valid Highs or Mediums are found, the HM pool is $0
  - QA awards: $1,000 in USDC
  - Judge awards: $5,000 in USDC
  - Validator awards: $3,500 in USDC
  - Scout awards: $500 in USDC
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts March 17, 2025 20:00 UTC 
- Ends April 7, 2025 20:00 UTC 

**Note re: risk level upgrades/downgrades**

Two important notes about judging phase risk adjustments: 
- High- or Medium-risk submissions downgraded to Low-risk (QA) will be ineligible for awards.
- Upgrading a Low-risk finding from a QA report to a Medium- or High-risk finding is not supported.

As such, wardens are encouraged to select the appropriate risk level carefully during the submission phase.

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2025-03-starkware/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._
## 🐺 C4: Begin Gist paste here (and delete this line)





# Scope

*See [scope.txt](https://github.com/code-423n4/2025-03-starknet/blob/main/scope.txt)*

### Files in scope


| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |

| **Totals** | **** | **** | **undefined** | | |

### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2025-03-starknet/blob/main/out_of_scope.txt)*

| File         |
| ------------ |
| ./workspace/apps/perpetuals/contracts/src/tests/components/test_nonce.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/components.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/constants.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/event_test_utils.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/flow_tests/flow_tests.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/flow_tests/flow_tests_infra.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/flow_tests.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/mocks/nonce.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/mocks.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/test_core.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests/test_utils.cairo |
| ./workspace/apps/perpetuals/contracts/src/tests.cairo |
| Totals: 12 |

