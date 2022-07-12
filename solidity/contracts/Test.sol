// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract Test {

    address payable public owner;
    mapping (address payable => uint) balance;

    constructor() payable {
        owner = payable(msg.sender);
    }

    function withdraw() public{
        require(balance[msg.sender]<=address(this).balance);
        owner.transfer(balance[msg.sender])
    }

    function deposit() payable public{
        balance[msg.sender]+=msg.value;
    }

    function checkBlanace(address user) public returns(uint){
        return balance[user];
    }

    function totalBalance() public returns(uint){
        return address(this).balance;
    }
    
    function withdrawAll() public {
        // Uncomment this line to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(msg.sender == owner, "You aren't the owner");
        owner.transfer(address(this).balance);
    }
}
