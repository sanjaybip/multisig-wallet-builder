# 👛 MultiSigBuilder (Create MultiSig Wallets)

This builder helps to create MultiSig Wallets. It has front-end based on [scaffold-eth | BuidlGuidl](https://github.com/scaffold-eth/scaffold-eth-challenges) which let you create a multisig wallets along with the owner and minimum number of signer required. The front-end also allow to create proposal, sign it and execute it.

Contract is deployed at [Goerli testnet](https://goerli.etherscan.io/address/0x6dfd19094e714221b8c4b59f3399cdcedbc4dc92).
Frontend : [multisig-sanjaydefi.surge.sh](https://multisig-sanjaydefi.surge.sh/)

# 🏄‍♂️ Quick Start

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone MultiSigBuilder:

```shell
git clone https://github.com/sanjaydefidev/multisig-wallet-builder.git
```

> install and start Hardhat chain locally:

```shell
cd multisig-wallet-builder
yarn install
yarn chain
```

> in a second terminal window, start the frontend:

```shell
yarn start
```

> in a third terminal window, deploy the contract:

```shell
yarn deploy
```

> in a fourth terminal window, start the node backend server:

```shell
yarn backend
```

---

Thanks to [Austin Griffith](https://github.com/austintgriffith) and [Steven Slade](https://github.com/stevenpslade).
