const BdcBPT = artifacts.require("BdcBPT");

module.exports = function(deployer) {
  deployer.deploy(BdcBPT);
};
