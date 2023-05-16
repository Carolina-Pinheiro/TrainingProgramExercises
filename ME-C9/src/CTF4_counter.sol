// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../src/CTF4.sol";

contract theKeys {
    DogGates public gates;
    address public owner;
    event keyStatus(uint64 key);
    event keyStatusBytes(bytes8 key);

    constructor(address _gatesAddress) {
        gates = DogGates(_gatesAddress);
        owner = msg.sender;
    }

    function openGates() public returns(uint256){
        // Set up third key
        bytes8 keyThree;

        uint32 last32bits = uint16(uint160(msg.sender));
        bytes4 lastpartkey = bytes4(last32bits);
        bytes8 shiftedkey = bytes8(lastpartkey) >> 4*8;
        bytes memory array = abi.encodePacked(shiftedkey);
        array[0] = 0xFF;
        keyThree = bytes8(array);
        
        //emit keyStatus(last32bits);
        //emit keyStatus(uint32(lastpartkey));
        //emit keyStatusBytes(keyThree);
        
        gates.enter(keyThree, msg.sender);
        
        return 5;
    }
}