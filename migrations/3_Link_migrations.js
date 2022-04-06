

const linkMigration = artifacts.require("Link");
const dexMigration = artifacts.require("Dex");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(linkMigration);
};
