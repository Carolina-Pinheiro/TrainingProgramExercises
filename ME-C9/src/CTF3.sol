pragma solidity ^0.8.0;

contract HowRandomIsRandom {
  Game[] public games;
  event displayNumber(uint256);
  struct Game {
      address player;
      uint id;
      uint bet;
      uint blockNumber;
  }

  function spin(uint256 _bet) public payable {
    require(msg.value >= 0.01 ether);
    uint gameId = games.length;
    games.push(Game(msg.sender, gameId, _bet, block.number - 1));
    if (gameId > 0) {
      uint lastGameId = gameId - 1;
      uint num = rand(blockhash(games[lastGameId].blockNumber), 100);
      emit displayNumber(num);
      emit displayNumber(games[lastGameId].bet);
      emit displayNumber(games[lastGameId].blockNumber);
      emit displayNumber(rand(blockhash(6533), 100));
      emit displayNumber(uint256(blockhash(6533)));
      emit displayNumber(uint256(blockhash(356795)));
      if(num == games[lastGameId].bet) {
          payable(games[lastGameId].player).transfer(address(this).balance);
      }
    }
  }

  function rand(bytes32 hashValue, uint max) pure private returns (uint256 result){
    return uint256(keccak256(abi.encodePacked(hashValue))) % max;
  }

  receive() external payable {}
}