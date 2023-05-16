// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/CTF3.sol";
import "../src/CTF3_counter.sol";
import "../lib/forge-std/src/Test.sol";

contract CTF3_Testing is Test{
    HowRandomIsRandom randomContract;
    attacker attacking;
    address player1 = address(6879864516574);
    address player2 = address(98764537641);
    address us = address(54678548654543);

    event displayNumber(uint256);

    function testAttack() public {
        randomContract = new HowRandomIsRandom();
        attacking = new attacker(payable(randomContract));

        // Give ether to the accounts
        vm.deal(us, 1 ether);
        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        
        // Make two bets to populate the array
        vm.roll(1000);
        vm.prank(player1);
        randomContract.spin{value: 0.05 ether}(5);
        
        vm.roll(1001);
        vm.deal(address(us), 0.1 ether);
        vm.prank(us);
        attacking.attackCTF3{value: 0.1 ether}();

        vm.roll(1260);
        vm.prank(player2);
        randomContract.spin{value: 0.03 ether}(10);

        //console.log("---------------Hacker Balance:", us.balance);
        console.log("---------------Vault:", address(randomContract).balance);
        console.log("---------------Attack Random Balance:", address(attacking).balance);
        //assertGt(address(attacking).balance, 0);
    }


}