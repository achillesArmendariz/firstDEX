
pragma solidity >=0.6.0 <=0.8.11;
pragma experimental ABIEncoderV2;

import "./wallet.sol";
contract Dex is myWallet {
  using SafeMath for uint256;

  enum Side {
    BUY,
    SELL
  }

  struct Order{
    uint256 id;
    Side side;
    address trader;
    bytes32 ticker;
    uint256 amount;
    uint256 price;
    uint256 filled;
  }

  //mappings aren't that efficient for DEXs
  //today on uniswap you'll observe them in liquidity pools. 
  mapping(bytes32 => mapping(uint256 => Order[]))orderBook;
  uint256 public nextOrderID = 0;


  function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory){
    return orderBook[ticker][uint256(side)];
  }

  function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public{

      if(side == Side.BUY){
        require(balances[msg.sender]["ETH"] >= amount.mul(price));
      }
      else if (side == Side.SELL){
        require(balances[msg.sender][ticker] >= amount);
  }
      //create a reference to our state var order[] for the token ticker and the
      //side of the orderBook that it's on SELL/BUY
      Order[] storage order = orderBook[ticker][uint(side)];
      order.push(Order(nextOrderID, side, msg.sender, ticker, amount, price));

      //BUBBLE SORT

      // if I is greater than zero, than I equals order.length -1
      //else I equals 0
      uint i = order.length > 0 ? order.length -1 : 0;

      if(side == Side.BUY){
        while(i>0){
          if(order[i-1].price>order[i].price){
            break;
          }
          Order memory orderHolder = order[i-1];
          order[i-1] = order[i];
          order[i] = orderHolder;
          i--;
        }
      }
      else if(side == Side.SELL){
        while(i>0){
          if(order[i-1].price<order[i].price){
            break;
          }
          Order memory orderHolder = order[i-1];
          order[i-1] = order[i];
          order[i] = orderHolder;
          i--;
        }
      }
      nextOrderID++;


}

  function createMarketOrder(Side side, bytes32 ticker, uint amount, uint price)public {

          uint orderBookSide;

          if(side == Side.BUY){
            orderBookSide = 1;
          }else{
            orderBookSide =0
          }

        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint256 totalFilled;
        for(uint256 i=0; i< orders.length && totalFilled < amount; i++){
          uint256 leftToFill = amount.sub(totalFilled);
          uint256 availableToFill = orders[i].amount.sub(orders[i].filled)
          uint256 filled = 0;

          if(availableToFill > leftToFill){
            filled = leftToFill;              //fill the entire market order
          }else{
            filled = availableToFill;         //fill as much of the market order
          }

          totalFilled = totalFilled.add(filled);
          orders[i].filled = orders[i].filled.add(filled);
          uint256 cost = filled.mul(orders[i].price);

          if(side == Side.BUY){
            require(balances[msg.sender]["ETH"]>= cost)

            //msg.sender is the buyer
            balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].sub(cost)
            balances[msg.sender][ticker]= balances[msg.sender][ticker].add(filled)

            balances[orders[i].trader][ticker]= balances[orders[i].trader][ticker].sub(filled)
            balances[orders[i].trader]["ETH"]= balances[orders[i].trader]["ETH"].add(cost);


          }else if(side == Side.SELL){

            //msg.sender is the seller of token
            balances[msg.sender][ticker]= balances[msg.sender][ticker].sub(filled);
            balances[msg.sender][ticker]= balances[msg.sender]["ETH"].add(cost)

            balances[orders[i].trader]["ETH"]= balances[orders[i].trader]["ETH"].sub(cost)
            balances[orders[i].trader][ticker]= balances[orders[i].trader][ticker].add(filled)

          }


  }
          //Loop through the orderbook and remove 100% filled orders.
          //not the most cost efficient, but good for this DEX example


          while(orders.length > 0 && orders[0].filled == orders[0].amount){

            //enter the while loop while we have atleast one element in ordersBook and
            //the zero index is filled currently
            for(int256 i =0; i< orders.length -1; i++){
              orders[i] = orders[i+1];
              //change the entire array to shift down
            }

            orders.pop()
            //pop the topmost element in the array, because it's now an extra copy
            //of its original value. Filled value was changed and erased
            //once we set the value to orders[i+1]. the pop is just a copy of original
            //top value.




          }








}

}
