// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Vault.sol";
import "../src/ThreeSigmaNFT.sol";
import "../lib/forge-std/src/Test.sol";


contract VaultTest is Test{
    ExposedCompetition comp;
    EtherCompetition etherComp;
    NFTCompetition nftComp;
    ThreeSigmaNFT nftCollection;

    uint256 constant timeElapsedWanted = 86400; 
    address payable address1 = payable(address(25031999));
    address payable address2 = payable(address(17012023));

    function testResetTimer() public{
        comp = new ExposedCompetition();
        uint256 currentCountdown = comp.resetTimer();
        assertEq(currentCountdown, block.timestamp);
    }

    function testCheckTimerNotEnoughTime() public{
        comp = new ExposedCompetition();

        uint256 currentCountdown = comp.resetTimer();

        vm.warp(block.timestamp + timeElapsedWanted - 200); // Not enough time

        bool result = comp.checkTimer(currentCountdown);
        assertEq(result, false);
    }

    function testCheckTimerEnoughTime() public{
        comp = new ExposedCompetition();

        uint256 currentCountdown = comp.resetTimer();

        vm.warp(block.timestamp + timeElapsedWanted + 100); // Enough time

        bool result = comp.checkTimer(currentCountdown);
        assertEq(result, true);
    }

    function testDeposit() public{
        etherComp = new EtherCompetition();

        vm.deal(address1, 0.1 ether);
        vm.startPrank(address1);
        etherComp.deposit{value: 0.1 ether}();
        vm.stopPrank();

        //Check that timer was reseted
        assertEq(etherComp.getCurrentCountdown(), block.timestamp);
        assertEq(etherComp.getLastDepositAddress(), address1);
    } 

    
    function testEtherCompetition() public{
        etherComp = new EtherCompetition();

        vm.deal(address1, 0.1 ether);
        vm.startPrank(address1);
        etherComp.deposit{value: 0.1 ether}();
        vm.stopPrank();
        
        vm.deal(address2, 0.1 ether);
        vm.startPrank(address2);
        etherComp.deposit{value: 0.1 ether}();
        assertEq(address(etherComp).balance, 0.2 ether);
        vm.stopPrank();


        vm.startPrank(address1);
        vm.expectRevert(bytes("Not the winner"));
        etherComp.withdraw();
        vm.stopPrank();

        vm.warp(block.timestamp + timeElapsedWanted - 100); // Not enough time has passed
        vm.deal(address2, 0 ether);
        vm.startPrank(address2);
        vm.expectRevert(bytes("Not enough time has passed"));
        etherComp.withdraw();
        vm.stopPrank();

        vm.warp(block.timestamp + 200); // Enough time has passed
        vm.deal(address2, 0 ether);
        vm.startPrank(address2);
        etherComp.withdraw();
        assertEq(address2.balance, 0.2 ether); // Received all the funds
        vm.stopPrank();
    }


    function testNFTCompetition() public{
        nftCollection = new ThreeSigmaNFT();
        nftComp = new NFTCompetition(address(nftCollection));
        
        vm.deal(address1, 1 ether);
        vm.deal(address2, 1 ether);
        vm.startPrank(address1);
        uint token1 = nftCollection.buyItem{value: 0.1 ether}(address1);
        nftCollection.buyItem{value: 0.1 ether}(address1);
        vm.stopPrank();

        vm.startPrank(address2);
        uint token3 = nftCollection.buyItem{value: 0.1 ether}(address2);
        nftCollection.buyItem{value: 0.1 ether}(address2);
        vm.stopPrank();

        vm.startPrank(address1);
        nftCollection.transferItem(address1, address(nftComp), token1);
        vm.stopPrank();
        assertEq(nftCollection.ownerOf(token1),address(nftComp));

        vm.startPrank(address2);
        nftCollection.transferItem(address2, address(nftComp), token3);
        vm.stopPrank();
        assertEq(nftCollection.ownerOf(token3),address(nftComp));

        vm.warp(block.timestamp + timeElapsedWanted + 100); // Enough time
        vm.startPrank(address2);
        nftComp.withdraw();
        vm.stopPrank();

        assertEq(nftCollection.ownerOf(token1),address2);
        
    }
}
