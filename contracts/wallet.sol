pragma solidity >=0.6.0 <=0.8.11;

//importing the interface to interact with the tokens smart contract
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import safeMath library to protect integer storage.
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract myWallet is Ownable{

  using SafeMath for uint256;
  /*
  this balance mapping is going to keep track of the coins a specific address
  holds, the bytes32 will be the ticker id of the coin (i.e. BNB)

  convert to bytes32 and do compare operations.
  */
  mapping(address => mapping(bytes32 => uint256)) public balances;


  //we need a way to store information about the tokens this
  //contracts supports
  struct Token{
    bytes32 ticker; //ticker for the coin
    address tokenAddress; //address for the coin, whenenver you trade
    //something, you need to be able to make transfer calls. in the actual
    //ERC20 token. Call token contract and do those transfers. We need to have
    //the token address saved.
  }

  //save all the tickers, which is like the ID for a token
  //need to be unique
  bytes32[] public tokenList; //ENUMERABLE
  // Map from bytes to struct
  mapping(bytes32 => Token) public tokenMapping;  //UPDATEABLE
  //Save it in a combined structure of array and mapping.

  //Check to see whether the token exists. but why check the 0 address?
  //is this ticker points to an uninitialized struct, then all properties of the
  // struct will be zero. addy= 000000000
  modifier tokenExists(bytes32 ticker){
    require(tokenMapping[ticker].tokenAddress != address(0), "Token does not exist");
    _;
  }


function addToken(bytes32 ticker, address tokenAddress) onlyOwner external{
  //external bc we don't need to call it from here. Saves Gas.
  tokenMapping[ticker] = Token(ticker, tokenAddress); //stores addy for ID.
  tokenList.push(ticker); //upload ID

}

//deposit tokens from the user that is interacting with this contract. into our contract
//from the token contract. Need a reentrency-guard for sure.
function deposit(uint256 amount, bytes32 ticker) tokenExists(ticker) external{
  //call the token contract to transfer here in our SC
  //ORDER OF OPERATIONS MATTER.
  //based on interface specifications, this is allowance, that needs to be granted
  //before hand. Could make another require statement.
  IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender,address(this), amount);
  //update internal balance
  balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);


}

function withdraw(uint256 amount, bytes32 ticker) tokenExists(ticker) external{
  require(balances[msg.sender][ticker] >= amount, "Not sufficient funds for withdrawal"); //CHECK
  // this is one of the crucial processes of deducting and sending money
  //check, effects, interact
  //use safeMath for integer storage protection.
  balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount); //EFFECTS
  //transfer from this smart contract, to it's rightful owner.
  IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount); // INTERACT
}


}
