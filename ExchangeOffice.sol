pragma solidity ^0.8.0;

contract CurrencyExchangeOffice {

    // Declare state variables of the contract
    address public owner;
    // map from (address, string) to uint
    mapping (address => mapping (string => uint)) public balances;
    mapping (string => uint) public exchangeRates;

    // When 'VendingMachine' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's cupcake balance to 100
    constructor() {
        owner = msg.sender;
        // (address, currency) => amount
        balances[address(this)]["ETH"] = 100;
        balances[address(this)]["DAI"] = 100;
        balances[address(this)]["USDC"] = 100;
        balances[address(this)]["USDT"] = 100;
        balances[address(this)]["WBTC"] = 100;
        balances[address(this)]["UNI"] = 100;
        // currency => exchange rate (in ETH)
        exchangeRates["ETH"] = 1;
        exchangeRates["DAI"] = 2;
        exchangeRates["USDC"] = 3;
        exchangeRates["USDT"] = 4;
        exchangeRates["WBTC"] = 5;
        exchangeRates["UNI"] = 6;
    }

    // Allow the owner to increase the smart contract's cupcake balance
    function refill(uint amount, string currency) public {
        require(msg.sender == owner, "Only the owner can refill.");
        balances[address(this)][currency] += amount;
    }

    // Allow anyone to purchase currency from the smart contract
    function purchase() public payable {
        uint e = exchangeRates[msg.currency];
        require(msg.value >= (msg.amount * e * 1 ether), "You must pay at least the total price in ETH.");
        // string with variable inside syntax: "string" + variable + "string"
        require(balances[address(this)][msg.currency] >= msg.amount, "Not enough " + msg.currency + " in stock to complete this purchase.");
        balances[address(this)] -= amount;
        balances[msg.sender] += amount;
    }

    // Allow anyone to sell currency to the smart contract
    function sell(uint amount, string currency) public {
        require(amount > 0, "You must sell at least one unit.");
        require(balances[msg.sender][currency] >= amount, "You do not have enough " + currency + " to complete this sale.");

        uint e = exchangeRates[currency];
        require(balances[address(this)] >= (amount * e), "The smart contract does not have enough ETH to complete this sale.");

        (bool success, ) = msg.sender.call{value: amount * e * 1 ether}("Currency sold successfully.");
        require(success, "The transaction was not successful.");

        balances[msg.sender][currency] -= amount;
    }

    // Allow anyone to withdraw the smart contract's ETH balance
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw.");
        (bool success, ) = msg.sender.call{value: address(this).balance}("ETH withdrawn successfully.");
        require(success, "The transaction was not successful.");
    }
}
