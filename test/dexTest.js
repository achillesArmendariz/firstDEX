const linkMigration = artifacts.require("Link");
const dex = artifacts.require("Dex");
const truffleAssert = require("truffle-assertions");

contract.skip("Dex" accounts => {

    //the user must have an ETH balance such that ETh>= buy order value
    it("should throw an error if ETH balance is too low when creating BUY limit order", async()=>{

      let dex = await dex.deployed()
      let link = await linkMigration.deployed()
      await truffleAssert.reverts(
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
      )

      dex.deposit({value:10})

      await truffleAssert.passes(
        dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 10, 1)
      )
    })

    //the user must have enough tokens deposited such that balance >= SELL order amount
    if("should throw an error if token balance is too low when creating SELL limit order", async() => {

      let dex = await dex.deployed()
      let link = await linkMigration.deployed()

      await truffleAssert.reverts(
        dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
      )

      await link.approve(dex.address,500);
      await dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})
      await dex.deposit(10, web3.utils.fromUtf8("LINK"))
      await truffleAssert.passes(
        dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
      )


    })

    //the BUY order book should be ordered by price from highest to lowest starting at index 0
    it("the BUY order book should be ordered from highest to lowest according to price starting at index 0", async() =>{

      let dex = await dex.deployed()
      let link = await linkMigration.deployed()

      await link.approve(dex.address, 500)
      await dex.deposit({value:3000})
      await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"),1, 300)
      await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"),1, 100)
      await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"),1, 200)

      let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
      console.log(orderbook);
      for(int i=0; i< orderbook.length-1; i++){
          assert(orderbook[i].price >= orderbook[i+1].price, "not right order in buy book")
      }




    })

    //the SELL order book should by ordered on price from lowest to highest starting at index 0
    it("the SELL order book should be ordered from highest to lowest according to price starting at index 0", async() =>{

      let dex = await dex.deployed()
      let link = await linkMigration.deployed()

      await link.approve(dex.address, 500);
      await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300)
      await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 100)
      await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 200)

      let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1)
      for(let i = 0; i i<orderbook.length-1; i++){
        assert(orderbook[i].price <= orderbook[i+1].price, "not right order in sell book")
      }



    } )

})
