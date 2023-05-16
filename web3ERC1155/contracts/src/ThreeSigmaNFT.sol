// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";

/// @title ThreeSigmaNFT ME:C7
/// @author Carolina P.
/// @notice Contract used to deploy a basic NFT 
contract ThreeSigmaNFT is ERC721 {

    // Event definition
    event Log(string func, uint gas);
    
    // Keep track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Base price for a NFT in wei
    uint public basePrice;

    // Owner of the contract
    address owner;

    /// @notice Initializes the contract by setting a name and a symbol to the token collection.
    constructor() ERC721("ThreeSigmaNFT", "3SIG"){
        // Base Price of a NFT set by the contract
        basePrice = 0.01 ether; 
        owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }


    /// @notice Permits the airdropping of new tokens
    /// question: how to add onlyOwner has a modifier
    function airdropBatch(address newOwner, uint256[] calldata tokenIds) external {
        // change to dynamic array
        for(uint256 i = 0; i < tokenIds.length; i++){
            _mint(newOwner, tokenIds[i]);
        }
    }

    ///@notice Airdrops a single token
    function airdropSingle(address newOwner, uint256 tokenId) external{
        _mint(newOwner, tokenId); 
    }

    function eventLog() public{
        emit Log("teste", 1234);
    }

    /// @notice Allows to buy an NFT if enough ether is provided
    /// @param buyer The address of the buyer of the NFT
    /// @return newItemID ID of the token bought
    function buyItem(address payable buyer) payable public returns(uint256) {
        // Requires the buyer to have enough funds to buy the NFT
        require(msg.value >= basePrice, "Insuficcient funds");
       
        // Create and assign the new NFT
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(buyer, newItemId);

        // Return ether not spent on the NFT
        buyer.transfer(msg.value-basePrice);
        return newItemId;
    }

    /// @notice Allows to sell an NFT for the base price, the NFT is then burned
    /// @param seller The address of the seller of the NFT
    /// @param tokenID TokenID of the NFT to be sold
    function sellItem(address payable seller, uint256 tokenID) public {
        // Burn the sold Item (a check for the ownership of the NFT is made inside)
        _burn(tokenID);

        // Transfer the amount to the seller
        seller.transfer(basePrice);
    }


    /// @notice Allows to transfer a NFT from an adress to another
    /// @param from The address of the owner of the NFT
    /// @param to The address of the recipient of the NFT
    /// @param tokenID TokenID of the NFT to be sold
    function transferItem(address from, address to, uint256 tokenID) public{
        _safeTransfer(from, to, tokenID, "");
    }

    // Receive 
    receive() external payable {
        emit Log("receive", gasleft());
    }
}