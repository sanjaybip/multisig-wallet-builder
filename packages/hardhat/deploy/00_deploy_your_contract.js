// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("MultiSigBuilder", {
    from: deployer,
    log: true,
    waitConfirmations: 4,
  });

  // Getting a previously deployed contract
  const multiSigBuilder = await ethers.getContract("MultiSigBuilder", deployer);

  // Verify from the command line by running `yarn verify`
  //You can also Verify your contracts with Etherscan here...
  //You don't want to verify on localhost
  try {
    if (chainId !== localChainId) {
      await run("verify:verify", {
        address: multiSigBuilder.address,
        contract: "contracts/MultiSigBuilder.sol:MultiSigBuilder",
        constructorArguments: [],
      });
    }
  } catch (error) {
    console.error(error);
  }
};
module.exports.tags = ["all", "MultiSigBuilder"];
