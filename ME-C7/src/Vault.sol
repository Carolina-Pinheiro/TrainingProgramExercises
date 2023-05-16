// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../src/ThreeSigmaNFT.sol";


contract Competition{

    uint256 constant timeElapsedWanted = 86400; // one day in seconds
    uint256 currentCountdown = 100000000000000000000000000000;

    function _resetTimer() internal {
        currentCountdown = block.timestamp; 
    }

    function _checkTimer() internal view returns(bool){
        if (block.timestamp >= currentCountdown + timeElapsedWanted){
            return (true);
        }else {
            return (false);
        }
    }

}

contract ExposedCompetition is Competition{

    function resetTimer() public returns (uint256){
        _resetTimer();
        return currentCountdown;
    }

    function checkTimer(uint256 currentCountdownTest) public returns(bool){
        currentCountdown = currentCountdownTest;
        return(_checkTimer());
    }
}

contract EtherCompetition is Competition{
    
    address private lastDepositAddress;

    function getCurrentCountdown() public view returns(uint256){
        return currentCountdown;
    }

    function getLastDepositAddress() public view returns(address){
        return lastDepositAddress;
    }


    function deposit() public payable{
        _resetTimer();
        lastDepositAddress = msg.sender;
    }

    function withdraw() public{
        require(msg.sender == lastDepositAddress, "Not the winner");
        require(_checkTimer() == true, "Not enough time has passed");
        payable(msg.sender).transfer(address(this).balance);
        currentCountdown = 100000000000000000000000000000;
    }
}

contract NFTCompetition is Competition, IERC721Receiver{

    address private lastDepositAddress;
    event Response(bool success, bytes data);
    uint256[] public tokenPool;
    address addressCollection;

    constructor(address nftContract){
        addressCollection = nftContract;
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns (bytes4){
        require(_checkTimer() == false, "Contest is over");
        tokenPool.push(tokenId);
        _resetTimer();
        lastDepositAddress = from;
        return IERC721Receiver.onERC721Received.selector;
    }


    function withdraw() public{
        require(msg.sender == lastDepositAddress, "Not the winner");
        require(_checkTimer() == true, "Not enough time has passed");

        // Transfer all the NFTs
        for(uint256 i=tokenPool.length; i>0; i--){
            (bool success, ) = 
            addressCollection.call(abi.encodeWithSignature(
                "transferItem(address,address,uint256)", 
                address(this), lastDepositAddress, tokenPool[i-1]));
            require(success == true, "Failed to transfer back the NFT");
            tokenPool.pop();
        }
        currentCountdown = 100000000000000000000000000000;
    }
}