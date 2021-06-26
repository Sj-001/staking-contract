pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Staking is ERC20, Ownable{
  constructor(address _owner, uint256 _supply) public{
    _mint(_owner, _supply);
  }
}