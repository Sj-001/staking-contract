pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract StakingContract is ERC20, Ownable {
    using SafeMath for uint256;

    address[] internal stakeholders;

    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    mapping(address => uint) internal startTime;
  
    constructor(address _owner, uint256 _supply) 
        public
    { 
        _mint(_owner, _supply);
    }

    function stakeToken(uint256 _stake)
        public
    {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) {
          addStakeholder(msg.sender);
          startTime[msg.sender] = block.number;
        }
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }


    function removeTokenStake(uint256 _stake)
        public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) {
          removeStakeholder(msg.sender);
          startTime[msg.sender] = 0;
        }
        _mint(msg.sender, _stake);
    }


    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }


    function addStakeholder(address _stakeholder)
        internal
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }


    function removeStakeholder(address _stakeholder)
        internal
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

  

   
    function calculateReward(address _stakeholder) public view returns(uint256) {
        require(stakes[_stakeholder] > 0);

        uint256 reward;
        /**
         * @notice calculating number of months for which stake has been holded.
         */
        uint256 months = (block.number - startTime[_stakeholder])/uint256(161280);

        uint256 apy;

        if(stakes[_stakeholder] < uint256(500)){
          apy = 8/uint256(100);
        }
        else if (stakes[_stakeholder] >= uint256(500) && stakes[_stakeholder] < uint256(1000)){
          apy = 10/uint256(100);
        }
        else if (stakes[_stakeholder] >= uint256(1000) && stakes[_stakeholder] < uint256(1500)){
          apy = 15/uint256(100);
        }
        else if(stakes[_stakeholder] >= uint256(1500)){
          apy = 25/uint256(100);
        }

        reward = stakes[_stakeholder]*(apy/uint256(12))*months;
        return reward;
    }

    function distributeRewards() 
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    function withdrawReward() 
        public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}