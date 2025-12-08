# RandomVRFGame – Secure On-Chain Randomness on Base

This repository contains a minimal, production-style example of how to use
[Chainlink VRF v2](https://docs.chain.link/vrf/v2) to request secure on-chain randomness
for a game or dApp running on the **Base mainnet** (or any EVM-compatible network
that supports VRF v2).

The core contract, `RandomVRFGame.sol`, demonstrates:

- Requesting random words from Chainlink VRF
- Storing the results on-chain
- Deriving random numbers in a given range (e.g. picking a random index, winner, etc.)
- Basic owner-only configuration of VRF parameters

> ⚠️ **Important:** You must always verify the VRF coordinator address, key hash, and subscription
> configuration against the official Chainlink documentation for the network you deploy to.
> The values in this repository are placeholders and MUST be updated for mainnet.

---

## 📦 Project Structure

```text
crypto-random-base-mainnet/
├─ contracts/
│  └─ RandomVRFGame.sol        # Main VRF-based randomness contract
├─ scripts/
│  └─ deploy-base.js           # Example deploy script for Base
├─ test/
│  └─ RandomVRFGame.test.js    # Minimal Hardhat test
├─ .github/
│  └─ workflows/
│     └─ ci.yml                # GitHub Actions workflow (build + test)
├─ hardhat.config.js           # Hardhat configuration (Base + Hardhat networks)
├─ package.json                # Node.js / Hardhat dependencies and scripts
└─ README.md                   # This file
```

---

## 🛠 Prerequisites

- Node.js (>= 18.x recommended)
- npm or yarn
- A Base RPC URL (for deployment to Base mainnet)
- A funded deployer wallet private key
- A Chainlink VRF v2 subscription on the target network

---

## 🚀 Getting Started

### 1. Install Dependencies

```bash
npm install
# or
yarn install
```

### 2. Compile Contracts

```bash
npx hardhat compile
```

### 3. Run Tests

```bash
npx hardhat test
```

The included test only checks that the contract deploys correctly on the local
Hardhat network. Real VRF behavior requires a live network and a valid VRF setup.

---

## 🌐 Network Configuration (Base)

The `hardhat.config.js` file defines a `base` network entry:

```js
base: {
  url: process.env.BASE_RPC_URL || "",
  accounts: process.env.DEPLOYER_PRIVATE_KEY ? [process.env.DEPLOYER_PRIVATE_KEY] : [],
}
```

Create a `.env` file in the project root (do **not** commit this to Git):

```bash
BASE_RPC_URL="https://base-mainnet.your-provider.io"
DEPLOYER_PRIVATE_KEY="0xyour_private_key"
VRF_COORDINATOR="0xYourBaseVrfCoordinator"
VRF_SUBSCRIPTION_ID="1234"
VRF_KEY_HASH="0xYourKeyHash"
```

Then export it into your shell or use something like `dotenv-cli` when running commands.

---

## 📡 Deploying to Base

Once your `.env` is configured:

```bash
npx hardhat run scripts/deploy-base.js --network base
```

You should see output similar to:

```text
Deploying with: 0xYourDeployerAddress
Using VRF Coordinator: 0x...
Using subscription ID: 1234
Using keyHash: 0x...
RandomVRFGame deployed to: 0xYourContractAddress
```

---

## 🔐 VRF Concepts (Short Overview)

- **VRF Coordinator** – The Chainlink contract that receives requests and returns verified randomness.
- **Subscription ID** – VRF v2 uses a subscription model to pay for randomness requests.
- **Key Hash (Gas Lane)** – Identifier for the specific VRF key / gas pricing configuration.
- **Callback Gas Limit** – Maximum gas used by `fulfillRandomWords`.
- **numWords** – How many random words you want per request.

In `RandomVRFGame.sol` you’ll find:

```solidity
uint64 public subscriptionId;
bytes32 public keyHash;
uint16 public requestConfirmations = 3;
uint32 public callbackGasLimit = 200_000;
uint32 public numWords = 1;
```

The owner can adjust these via:

- `setSubscriptionId`
- `setKeyHash`
- `setCallbackGasLimit`
- `setNumWords`
- `setRequestConfirmations`

---

## 🎲 Using the Randomness

1. Call `requestRandomWords()`  
   This sends a request to the VRF coordinator. Once fulfilled, `fulfillRandomWords`
   is called by the coordinator and stores the random words on-chain.

2. After the request is fulfilled, use:

```solidity
uint256 result = game.getRandomInRange(requestId, maxExclusive);
```

This returns a number in `[0, maxExclusive)` derived from the stored word.

> ❗ Never rely on `block.timestamp`, `blockhash`, etc. for secure randomness
> in adversarial or value-bearing contexts. Use VRF for anything where fairness
> matters (games, lotteries, random winners, etc.).

---

## ✅ GitHub Actions CI

This repository includes a minimal GitHub Actions workflow in
`.github/workflows/ci.yml` that will:

- Install dependencies
- Compile contracts
- Run tests

On every push and pull request.

---

## 📄 License

This project is released under the [MIT License](./LICENSE) and is intended as a
reference / boilerplate for secure on-chain randomness using Chainlink VRF.
Feel free to fork, adapt, and extend it for your own projects.
