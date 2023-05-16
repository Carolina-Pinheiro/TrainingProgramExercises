// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";



contract DogGates {
  address public entrant;

  event gasTested(uint256 gas);
  modifier gateOne() {
    require(msg.sender != tx.origin, "Gate one failed");
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0, "GAS");
    _;
  }

  modifier gateThree(bytes8 _gateKey, address actualOrigin) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(actualOrigin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey, address actualOrigin) public gateOne gateTwo gateThree(_gateKey, actualOrigin) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}