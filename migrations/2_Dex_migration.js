
const dexMigration = artifacts.require("Dex");

module.exports = function (deployer) {
  deployer.deploy(dexMigration);
};
