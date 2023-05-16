// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/CTF1.sol";
import "../src/CTF1_counter.sol";
import "../lib/forge-std/src/Test.sol";


contract CTF1_testing is Test{
    Vault ctf1;
    CTF1_Attack attacker;
    address us = address(54678548654543);
    address address2 = address(19012023); 
    address address3 = address(20231901);

    function IGNOREtestAttack() public{
        // Initialize the vault contract
        ctf1 = new Vault();

        // Initialize the attacker
        vm.prank(us);
        attacker = new CTF1_Attack(address(ctf1));

        // Two players (not the attacker) deposit ether in the vault
        vm.deal(address2, 0.1 ether);
        vm.deal(address3, 0.1 ether);

        vm.prank(address2);
        ctf1.deposit{value: 0.1 ether}(address2);
        
        vm.prank(address3);
        ctf1.deposit{value: 0.1 ether}(address3);
        
        // Make sure that the funds are in the vault
        assertEq(address(ctf1).balance, 0.2 ether);

        // Time to attack
        vm.deal(us, 0.1 ether);
        vm.prank(us);
        attacker.attackVault{value: 0.1 ether}();

        // Make sure that the attack was successful
        assertEq(address(attacker).balance, 0.3 ether);

        // Withdraw funds
        vm.prank(us);
        attacker.withdraw();
        assertEq(us.balance, 0.3 ether);
    }
}
