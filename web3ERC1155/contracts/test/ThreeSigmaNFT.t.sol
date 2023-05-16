// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ThreeSigmaNFT.sol";
import "../lib/forge-std/src/Test.sol";


contract ThreeSigmaNFTTest is Test{
    ThreeSigmaNFT testNFT;
    address payable address1 = payable(address(1500));
    address address2 = address(356532);
    uint256 basePrice = 0.01 ether;

    function testBuyItem() public{
        testNFT = new ThreeSigmaNFT();
        vm.deal(address1, 1 ether);
        vm.prank(address1);
        uint returnID = testNFT.buyItem{value: basePrice}(address1);
        
        address owner_of = testNFT.ownerOf(returnID);
        assertEq(address1, owner_of);

        //vm.roll & vm.warp
    }

    function testBuyItemInsufficientFunds() public{
        testNFT = new ThreeSigmaNFT();
        vm.deal(address1, 1 ether);
        vm.prank(address1);

        vm.expectRevert(bytes("Insuficcient funds"));
        testNFT.buyItem{value: 0.005 ether}(address1);
    }


    function testSellItem() public{
        testNFT = new ThreeSigmaNFT();

        uint tokenID = testNFT.buyItem{value: 0.01 ether}(address1);
        // testNFT._mint(address1, tokenID);
        
        vm.prank(address1);
        testNFT.sellItem(address1, tokenID);

        uint256 balance = testNFT.balanceOf(address1);
        assertEq(address1.balance, basePrice);
        assertEq(balance, 0);
    }

    function testTransferItem() public{
        testNFT = new ThreeSigmaNFT();

        vm.deal(address1, 1 ether);
        uint tokenID = testNFT.buyItem{value: 0.01 ether}(address1);
        
        vm.prank(address1);
        testNFT.transferItem(address1,address2, tokenID);

        address ownerOf = testNFT.ownerOf(tokenID);

        assertEq(address2, ownerOf);
    }

}