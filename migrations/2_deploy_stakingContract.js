const BigNumber = require("bignumber.js");
const StakingContract = artifacts.require("./StakingContract.sol");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(
    StakingContract,
    accounts[1],
    new BigNumber(10).pow(18).multipliedBy(525).toString(10)
  );
};
