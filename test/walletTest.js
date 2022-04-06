
const walletTest = artifacts.require("Dex");
const linkMigration = artifacts.require("Link");

//new: truffle assertion w/ mocha testing frame
const truffleAssert = require("truffle-assertions");


contract("Dex", accounts => {

it("should only be possible for owner to add tokens", async() => {
// from link migrations
//await deployer.deploy(linkMigration);
//don't need the deployer here, just wait for these two to be
//deployed
let link = await linkMigration.deployed();
let dex = await walletTest.deployed();

//await link.approve(dex.address,500);  dont need approval line rn
await truffleAssert.passes( //NEW: assertion mocha technique
  dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})
);
//missed await and  token "didn't exist": error corrected

await truffleAssert.reverts( //NEW: assumes that this reverts, must fail and we expect it
  dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[1]})
);

})

it("should handle deposits correctly", async() => {

let link = await linkMigration.deployed();
let dex = await walletTest.deployed();
//await these calls because they're asynchronous
await link.approve(dex.address, 500);
await dex.deposit(100, web3.utils.fromUtf8("LINK"));

//assert that our balance is actually one hundred
//use the regular assert that is provided in TRUFFLE
let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"));
assert.equal(balance.toNumber(), 100) //balance was originally a BN, so change toNumber()

})

it("should handle faulty withdrawals correctly", async() => {

let link = await linkMigration.deployed();
let dex = await walletTest.deployed();

await truffleAssert.reverts(
  dex.withdraw(500, web3.utils.fromUtf8("LINK"))
);

})

it("should handle withdrawals correctly", async() => {

let link = await linkMigration.deployed();
let dex = await walletTest.deployed();

await truffleAssert.passes(
  dex.withdraw(100, web3.utils.fromUtf8("LINK"))
);

})

})
