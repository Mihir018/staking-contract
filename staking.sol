// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract StakingContract {
    // Token information
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakeTime;

    // Staking rewards information
    uint256 public rewardRate = 1; // Rate of rewards per second
    mapping(address => uint256) public totalRewards;

    event TokensMinted(address indexed to, uint256 amount);
    event TokensStaked(address indexed staker, uint256 amount);
    event TokensUnstaked(address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed staker, uint256 amount);
    event RewardRateChanged(uint256 newRate);

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    function mint(address _to, uint256 _amount) external {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit TokensMinted(_to, _amount);
    }

    function stake(uint256 _amount) external {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");

        balanceOf[msg.sender] -= _amount;
        stakedAmount[msg.sender] += _amount;
        stakeTime[msg.sender] = block.timestamp;

        emit TokensStaked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(stakedAmount[msg.sender] >= _amount, "Insufficient staked amount");

        uint256 stakedTime = block.timestamp - stakeTime[msg.sender];
        uint256 rewards = stakedAmount[msg.sender] * rewardRate * stakedTime;

        balanceOf[msg.sender] += _amount;
        stakedAmount[msg.sender] -= _amount;
        stakeTime[msg.sender] = 0;
        totalRewards[msg.sender] += rewards;

        emit TokensUnstaked(msg.sender, _amount);
        emit RewardsClaimed(msg.sender, rewards);
    }

    function claimRewards() external {
        uint256 stakedTime = block.timestamp - stakeTime[msg.sender];
        uint256 rewards = stakedAmount[msg.sender] * rewardRate * stakedTime;

        stakeTime[msg.sender] = block.timestamp;
        totalRewards[msg.sender] += rewards;

        emit RewardsClaimed(msg.sender, rewards);
    }

    function changeRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
        emit RewardRateChanged(_newRate);
    }
}
