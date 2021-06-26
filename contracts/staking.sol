pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Staking is ERC20, Ownable{
  using SafeMath for uint256;

  address[] internal stakeholders;
  mapping(address => uint256) stakesmap;
  mapping(address => uint256) rewardsmap;
  mapping(address => uint) startTime;
  constructor(address _owner, uint256 _supply) public{
    _mint(_owner, _supply);
  }

  function stakeToken(uint256 _amount) public{
    _burn(msg.sender, _amount);
    stakesmap[msg.sender] = stakesmap[msg.sender].add(_amount);
    startTime[msg.sender] = block.number; 
  }

  function unstakeToken(uint256 _amount) public{
    require(stakesmap[msg.sender] >= _amount);
    stakesmap[msg.sender] = stakesmap[msg.sender].sub(_amount);
    assignReward(msg.sender);
    _mint(msg.sender, _amount);
  }

  function calculateReward(address _stakeholder) public view returns(uint256) {
    require(stakesmap[_stakeholder] > 0);

    uint256 reward;
    uint256 months = uint256((block.number - startTime[_stakeholder])*16/uint256(60*60*24*30));

    uint256 apy;
    
    if(stakesmap[_stakeholder] < uint256(500)){
      apy = uint256(8/100);
    }
    else if (stakesmap[_stakeholder] >= uint256(500) && stakesmap[_stakeholder] < uint256(1000)){
      apy = uint256(10/100);
    }
    else if (stakesmap[_stakeholder] >= uint256(1000) && stakesmap[_stakeholder] < uint256(1500)){
      apy = uint256(15/100);
    }
    else if(stakesmap[_stakeholder] >= uint256(1500)){
      apy = uint256(25/100);
    }

    reward = stakesmap[_stakeholder]*(apy/12)*months;
    return reward;
  }

  function assignReward(address _redeemer) internal{
    uint256 reward = calculateReward(_redeemer);
    rewardsmap[_redeemer] = reward;
  }  

  function withdrawReward() public{
    uint256 reward = rewardsmap[msg.sender];
    rewardsmap[msg.sender] = 0;
    _mint(msg.sender, reward);
  }
}