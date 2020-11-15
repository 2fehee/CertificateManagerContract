const BdcCertificateManager = artifacts.require("BdcCertificateManager");

module.exports = function(deployer) {
  deployer.deploy(BdcCertificateManager);
};
