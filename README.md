# Shardhash

Shardhash is an autonomous proof-of-work protocol deployed on Ethereum. Its native ERC-20 token is SHARDEN.

- Compiler: Solidity 0.8.24
- Framework: Foundry
- License: MIT

---

# Shardhash Protocol Specification

## 1. Overview

Shardhash is an autonomous proof-of-work protocol deployed on Ethereum. Every Ethereum block starts a new mining round in which participants compete to discover cryptographic solutions derived from recent Ethereum block history.

The native token of the protocol is **SHARDEN**.

Shardhash is designed around the following principles:

- Permissionless participation
- Deterministic verification
- Autonomous operation
- Immutable deployment
- First-valid-submission settlement
- Commodity CPU and GPU mining

Mining rewards scale exponentially with solution quality. Higher-quality solutions become exponentially more difficult to discover while earning exponentially larger SHARDEN rewards.

After deployment, the protocol operates entirely according to its immutable on-chain code. No governance, upgrade mechanism, administrator, privileged owner, or emergency controls exist.

---

## 2. Components

### Protocol

- **Name:** Shardhash
- **Purpose:** Autonomous proof-of-work issuance protocol.

### Native Token

- **Name:** SHARDEN
- **Standard:** ERC-20
- **Issuance:** Minted exclusively by the deployed Shardhash contract after successful verification of a valid mining claim.

The mint linkage between SHARDEN and Shardhash is permanent and immutable after deployment.

---

## 3. Round Model

A mining round corresponds to:

```text
round = block.number - 1
```

Every newly produced Ethereum block starts the next round.

The Ethereum block cycle is currently approximately 12 seconds on average. Since Shardhash is synchronized directly to Ethereum blocks, the average duration of a mining round is also currently about 12 seconds, although it naturally follows Ethereum's block production rate over time.

Claims are valid only during the active round.

### Round Overlap

The challenge for round `R` is derived from Ethereum block hashes preceding that round. As a result, miners can begin searching for valid solutions for round `R` immediately after the preceding block is produced, before round `R` itself becomes claimable.

This creates an overlap of approximately one Ethereum block interval between consecutive rounds. During this overlap:

- Round `R−1` remains claimable.
- Round `R` is already mineable.

Since each `(round, tier)` pair may be claimed only once, miners must decide whether to continue searching for additional or higher-tier solutions for the current claimable round or switch their computational resources to the next round.

---

## 4. Challenge Generation

Every round derives a deterministic challenge from the sixteen Ethereum block hashes preceding that round. This allows the challenge for a new round to be known before the round becomes claimable, enabling miners to begin searching immediately.

Conceptually:

```text
n = block.number - 1    // round

challenge =
keccak256(
    blockhash(n−1),
    blockhash(n−2),
    ...
    blockhash(n−16)
)
```

### Properties

- Unpredictable before the round begins.
- Deterministic afterwards.
- Requires no external oracle.
- Entirely reproducible by every node.

---

## 5. Mining

Miners search arbitrary nonce values.

For each nonce:

```text
candidate =
keccak256(
    challenge ||
    round ||
    miner_address ||
    nonce
)
```

Mining consists solely of searching for increasingly rare valid outputs.

---

## 6. Solution Quality

The solution tier equals the number of consecutive matching hexadecimal digits starting from the least significant hexadecimal digit.

Formally:

```text
tier =
trailing_matching_hex_digits(candidate, challenge)
```

Only solutions with

```text
tier ≥ 10
```

produce a reward.

Higher tiers are exponentially rarer.

---

## 7. Reward Schedule

SHARDEN is an ERC-20 token with 18 decimal places. Mining rewards are denominated in the token's smallest indivisible unit (base units).

Reward function:

```text
reward(n) = 10^(n−10)
```

for

```text
n ≥ 10
```

base units.

Since

```text
1 SHARDEN = 10^18 base units
```

the corresponding token amounts displayed by wallets and block explorers are:

| Tier | Base Units | SHARDEN |
|------:|-----------:|--------:|
| 10 | 1 | 0.000000000000000001 |
| 11 | 10 | 0.00000000000000001 |
| 12 | 100 | 0.0000000000000001 |
| 13 | 1,000 | 0.000000000000001 |
| 14 | 10,000 | 0.00000000000001 |
| 15 | 100,000 | 0.0000000000001 |
| 16 | 1,000,000 | 0.000000000001 |

Each additional matching hexadecimal digit increases mining difficulty by approximately **16×**, since every additional hexadecimal digit has a probability of **1/16** of matching.

Rewards increase by **10×** per tier. The objective is for the majority of long-term issuance to originate from the lower and middle reward tiers while preserving substantial incentives for discovering exceptionally rare, high-tier solutions.

---

## 8. Claim Rules

Each tier may be claimed only once per round.

The protocol records:

```text
claimed[round][tier]
```

The first valid transaction submitted for a given tier succeeds.

Subsequent claims for the same tier during the same round are rejected.

Different tiers remain independently claimable for that round.

---

## 9. Token Issuance

When a claim succeeds:

1. The solution is verified.
2. The tier is determined.
3. The reward is calculated.
4. New SHARDEN is minted.
5. The tokens are transferred directly to the successful miner.

There is:

- No premine.
- No treasury.
- No manual minting.

All SHARDEN issuance occurs exclusively through successful proof-of-work.

---

## 10. Mining Hardware

Shardhash is designed for parallel computation.

Supported implementations include:

- Multi-thread CPU
- GPU (CUDA)
- GPU (OpenCL)
- Hybrid CPU + GPU

Mining is stateless and embarrassingly parallel.

> **Note:** The official reference miner is available in the dedicated **sharden-miner** repository:
> 
> https://github.com/babakkarimib/sharden-miner
> 
> It currently provides a Rust-based multi-threaded CPU miner. Future updates will add CUDA and OpenCL GPU backends.


---

## 11. Security Model

Security relies on:

- Ethereum consensus.
- Ethereum block hash unpredictability.
- Keccak-256 cryptographic security.
- Deterministic on-chain verification.

No external randomness is required.

No trusted third party exists.

---

## 12. Autonomy

After deployment:

- Protocol rules cannot change.
- Mint authority cannot change.
- No administrator exists.
- No governance exists.
- No privileged owner exists.
- No upgrade mechanism exists.
- No emergency controls exist.

The protocol operates autonomously according to its immutable deployed code.

---

## 13. Summary

Shardhash is an autonomous, immutable proof-of-work protocol built on Ethereum.

Each Ethereum block begins a new mining round.

Participants search for cryptographic solutions using CPUs or GPUs.

Higher-quality solutions become exponentially more difficult to discover while earning exponentially larger SHARDEN rewards.

Successful claims are verified entirely on-chain, and SHARDEN is minted automatically by the protocol itself.

Once deployed, the protocol functions without governance, administrative control, or privileged ownership, operating solely according to its immutable smart contract logic.
