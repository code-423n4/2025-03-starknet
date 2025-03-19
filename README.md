# Starknet Perpetual audit details
- Total Prize Pool: $150,000 in USDC
  - HM awards: up to $140,000 in USDC 
    - If no valid Highs are found, the HM pool is $40,000 in USDC
    - If no valid Highs or Mediums are found, the HM pool is $0
  - QA awards: $1,000 in USDC
  - Judge awards: $5,000 in USDC
  - Validator awards: $3,500 in USDC
  - Scout awards: $500 in USDC
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts March 19, 2025 20:00 UTC 
- Ends April 9, 2025 20:00 UTC

ℹ️ The sponsor team will have access to audit submissions during the submission phase.

**Note re: risk level upgrades/downgrades**

Two important notes about judging phase risk adjustments: 
- High- or Medium-risk submissions downgraded to Low-risk (QA) will be ineligible for awards.
- Upgrading a Low-risk finding from a QA report to a Medium- or High-risk finding is not supported.

As such, wardens are encouraged to select the appropriate risk level carefully during the submission phase.

## Automated Findings / Publicly Known Issues

The 4naly3er report is inapplicable for this contest and there are no explicit known issues. Any issue/behavior that is marked as acknowledged via in-line documentation should be considered out-of-scope for this contest.

# Overview

Starknet Perpetuals enables running a decentralized, perpetuals exchange that provides its users with self-custody, and settles transactions in a trustless manner.

A position includes a collateral asset and one or more synthetic assets. Unlike spot trading, a trader can hold a leveraged position, which enables trading in asset amounts that are greater than the amount of funds actually invested.

## Margin 

When you create a Starknet-Perpetuals-powered exchange, you define the requirements for the initial margin and the maintenance margin.

The maintenance margin determines the amount of leverage that Starknet Perpetuals enforces whenever executing a trade or liquidation transaction. When a position’s value falls below the maintenance margin, it is not well-leveraged. The maintenance margin is similar to total risk.

The application is responsible for enforcing the initial margin before sending a transaction to the Starknet Perpetuals gateway. Starknet Perpetuals enforces the maintenance margin.

## Total Value &amp; Total Risk

The *total value* of a position is the sum of the value of the position’s collateral and synthetic assets, expressed in the collateral currency.

The *total risk* is a measurement that includes the total value of all synthetic assets in a position, and also takes into account a predetermined *risk factor* for each synthetic asset. As the risk factor increases, so does the total risk.

You, the operator, determine the risk factor according to your business logic, and include it in the general configuration for your Starknet Perpetuals instance as `risk_factor`, which is a tiered list that varies depending on the amount of a given synthetic asset. It is equivalent to the term *maintenance margin rate* (MMR), where MMR is expressed as a percentage. For example, if the MMR is 0.7%, then `risk_factor = 0.007`.

Total risk is related to the maintenance margin as follows:
- When a position’s total value is equal to its total risk, it is exactly at the maintenance margin.
- When a position’s total value is less than its total risk, it is below the maintenance margin.
- When a position’s total value is greater than its total risk, it is above the maintenance margin.

## Links

- **Previous audits:** N/A
- **Documentation:** https://github.com/starkware-libs/starknet-perpetual/blob/main/docs/spec.md
- **Website:** https://www.starknet.io/
- **X/Twitter:** https://x.com/starknet
- **Discord:** https://discord.com/invite/starknet-community

---

# Scope

Any files that are not listed explicitly in-scope should be considered out-of-scope.

### Files in scope

| File   | Logic Contracts | Interfaces | nSLOC |
| ------ | --------------- | ---------- | ----- |
| ./workspace/apps/perpetuals/contracts/src/lib.cairo | N/A | **** | 2 |
| ./workspace/apps/perpetuals/contracts/src/core.cairo | N/A | **** | 7 |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/assets.cairo | N/A | **** | 567 |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/errors.cairo | N/A | **** | 43 |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/events.cairo | N/A | **** | 41 |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/interface.cairo | N/A | **** | 55 |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets.cairo | N/A | **** | 5 |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/deposit.cairo | N/A | **** | 220 |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/errors.cairo | N/A | **** | 9 |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/events.cairo | N/A | **** | 27 |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/interface.cairo | N/A | **** | 28 |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit.cairo | N/A | **** | 5 |
| ./workspace/apps/perpetuals/contracts/src/core/components/operator_nonce/interface.cairo | N/A | **** | 3 |
| ./workspace/apps/perpetuals/contracts/src/core/components/operator_nonce/operator_nonce.cairo | N/A | **** | 44 |
| ./workspace/apps/perpetuals/contracts/src/core/components/operator_nonce.cairo | N/A | **** | 3 |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/errors.cairo | N/A | **** | 11 |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/events.cairo | N/A | **** | 35 |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/interface.cairo | N/A | **** | 47 |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/positions.cairo | N/A | **** | 432 |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions.cairo | N/A | **** | 5 |
| ./workspace/apps/perpetuals/contracts/src/core/components.cairo | N/A | **** | 4 |
| ./workspace/apps/perpetuals/contracts/src/core/core.cairo | N/A | **** | 884 |
| ./workspace/apps/perpetuals/contracts/src/core/errors.cairo | N/A | **** | 48 |
| ./workspace/apps/perpetuals/contracts/src/core/events.cairo | N/A | **** | 90 |
| ./workspace/apps/perpetuals/contracts/src/core/interface.cairo | N/A | **** | 84 |
| ./workspace/apps/perpetuals/contracts/src/core/types/asset/synthetic.cairo | N/A | **** | 58 |
| ./workspace/apps/perpetuals/contracts/src/core/types/asset.cairo | N/A | **** | 46 |
| ./workspace/apps/perpetuals/contracts/src/core/types/balance.cairo | N/A | **** | 133 |
| ./workspace/apps/perpetuals/contracts/src/core/types/funding.cairo | N/A | **** | 122 |
| ./workspace/apps/perpetuals/contracts/src/core/types/order.cairo | N/A | **** | 66 |
| ./workspace/apps/perpetuals/contracts/src/core/types/position.cairo | N/A | **** | 70 |
| ./workspace/apps/perpetuals/contracts/src/core/types/price.cairo | N/A | **** | 120 |
| ./workspace/apps/perpetuals/contracts/src/core/types/risk_factor.cairo | N/A | **** | 55 |
| ./workspace/apps/perpetuals/contracts/src/core/types/set_owner_account.cairo | N/A | **** | 33 |
| ./workspace/apps/perpetuals/contracts/src/core/types/set_public_key.cairo | N/A | **** | 30 |
| ./workspace/apps/perpetuals/contracts/src/core/types/transfer.cairo | N/A | **** | 33 |
| ./workspace/apps/perpetuals/contracts/src/core/types/withdraw.cairo | N/A | **** | 34 |
| ./workspace/apps/perpetuals/contracts/src/core/types.cairo | N/A | **** | 11 |
| ./workspace/apps/perpetuals/contracts/src/core/value_risk_calculator.cairo | N/A | **** | 336 |
| **Totals** | 39 |  | 3846 |

### Files out of scope

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

## Scoping Q &amp; A

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       USDC             |
| Test coverage                           | 90.9% (Line Coverage), 83.6% (Function Coverage)                          |
| ERC721 used  by the protocol            |            No              |
| ERC777 used by the protocol             |           No                |
| ERC1155 used by the protocol            |              No            |
| Chains the protocol will be deployed on | Starknet  |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      | No   |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  | No  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) |  No  |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 | No   |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              |   No |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      |  No  |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              |  No  |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            |  No  |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    |  No  |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    |  No  |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    |  No  |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  |  No  |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  No  |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | No   |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 | No   |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              |  No  |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                |  No  |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |


### EIP compliance checklist

Any contracts that mention SNIP-12 should comply with the relevant standard to the extent it is implemented in each `cairo` file.

# Additional context

## Main Invariants

#### **Only Operator Can Call the Following Flows:**
- `process_deposit`
- `withdraw`
- `transfer`
- `trade`
- `liquidate`
- `deleverage`
- `set_public_key`
- `set_owner_account`
- `price_tick`
- `funding_tick`

#### **Only App Governor Can Call the Following Flows:**
- `add_oracle_to_asset`
- `add_synthetic_asset`
- `deactivate_synthetic`
- `remove_oracle_from_asset`
- `update_synthetic_quorum`


## Attack ideas (where to focus for bugs)

Potential ways that rounding errors can be capitalized to harm users, result in fund loss, or otherwise have a financial impact.

## All trusted roles in the protocol


| Role             | Description               |
|------------------|---------------------------|
| **Operator**     | Has control over critical flows like deposit, withdraw, transfer, etc. |
| **App Governor** | Manages synthetic assets and oracles, including updates and deactivations. |
| **Governance Admin** | Oversees governance-related configurations and permissions. |


## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A

## Running tests

```bash
curl –proto '=https' –tlsv1.2 -sSf https://sh.starkup.dev | sh
scarb build
```

To make tests:

```bash
scarb test
```

To make coverage:

```bash
curl -L https://raw.githubusercontent.com/software-mansion/cairo-coverage/main/scripts/install.sh | sh
snforge test --coverage
```

### Code Coverage

| Filename                                                       | Rate   | Num | Rate   | Num | Rate   | Num |
| -------------------------------------------------------------- | ------ | --- | ------ | --- | ------ | --- |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/assets.cairo                                  | 89.9%  | 208 | 71.6%  | 74  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/events.cairo                                  | 87.5%  | 8   | 95.5%  | 22  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/assets/interface.cairo                               | 100%   | 1   | 100%   | 5   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/deposit.cairo                                | 95.3%  | 64  | 73.7%  | 19  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/events.cairo                                 | 100%   | 3   | 100%   | 9   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/deposit/interface.cairo                              | 100%   | 2   | 83.3%  | 6   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/operator_nonce/operator_nonce.cairo                 | 87.5%  | 8   | 75.0%  | 8   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/events.cairo                               | 100%   | 5   | 100%   | 13  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/interface.cairo                            | 100%   | 1   | 100%   | 4   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/components/positions/positions.cairo                            | 80.3%  | 132 | 59.5%  | 42  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/core.cairo                                                      | 88.6%  | 246 | 75.3%  | 81  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/errors.cairo                                                    | 100%   | 9   | 100%   | 2   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/events.cairo                                                    | 87.5%  | 8   | 95.5%  | 22  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/interface.cairo                                                 | 100%   | 1   | 100%   | 7   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/asset.cairo                                               | 100%   | 6   | 94.7%  | 19  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/asset/synthetic.cairo                                     | 66.7%  | 3   | 57.1%  | 7   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/balance.cairo                                             | 100%   | 14  | 89.5%  | 19  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/funding.cairo                                             | 95.5%  | 22  | 80.0%  | 15  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/order.cairo                                               | 100%   | 17  | 85.7%  | 7   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/position.cairo                                            | 90.9%  | 11  | 94.4%  | 18  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/price.cairo                                               | 90.0%  | 20  | 78.9%  | 19  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/risk_factor.cairo                                         | 88.9%  | 9   | 69.2%  | 13  | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/set_owner_account.cairo                                   | 100%   | 5   | 75.0%  | 4   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/set_public_key.cairo                                      | 100%   | 4   | 75.0%  | 4   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/transfer.cairo                                            | 100%   | 4   | 75.0%  | 4   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/types/withdraw.cairo                                            | 100%   | 4   | 75.0%  | 4   | -      | 0   |
| ./workspace/apps/perpetuals/contracts/src/core/value_risk_calculator.cairo                                     | 96.5%  | 86  | 92.9%  | 28  | -      | 0   |
| =============================================================== | ====== | --- | ====== | --- | ====== | --- |
| **Total**                                                       | **90.0%** | 901 | **80.4%** | 475 | -      | 0   |



## Miscellaneous

Employees of Starknet/Starkware and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
