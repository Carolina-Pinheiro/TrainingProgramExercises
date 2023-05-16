// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/CTF2.sol";
import "../src/CTF2_counter.sol";
import "../lib/forge-std/src/Test.sol";

contract CTF2_Testing is Test{
    CallMeMaybe callMe;
    attacker attacking;
    address us = address(54678548654543);

    function IGNOREtestAttack() public{
        callMe = new CallMeMaybe();

        vm.deal(address(callMe), 1 ether);
        vm.startPrank(us);
        attacking = new attacker(payable(address(callMe))); 
        assertEq(us.balance, 1 ether );
    }


}