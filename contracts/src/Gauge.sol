// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "openzeppelin/contracts/token/ERC721/ERC721.sol";
import "openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IMerc.sol";
import "./test/console.sol";

contract Gauge is IERC721, ERC721Enumerable {
    using SafeERC20 for IERC20;

    error NotFound();
    error OnlyOwner();
    error AmountTooHigh();

    event Pledge(uint256 gaugeId, address account, uint256 amount);
    event Depledge(uint256 gaugeId, address account, uint256 amount);
    event Burn(uint256 gaugeId, address account, uint256 amount);
    event Stake(uint256 gaugeId, address account, uint256 amount);
    event Unstake(uint256 gaugeId, address account, uint256 amount);
    event RewardPaid(uint256 gaugeId, address account, uint256 amount);

    // Staking state

    uint256 public constant REWARD_PER_GAUGE_WEIGHT_PRECISION = 1e18;
    uint256 public constant REWARD_PER_TOKEN_PRECISION = 1e36;

    uint256 public rewardRate = 23456789012345678901; // TODO - get this from Merc.
    uint256 public lastUpdateTime;
    uint256 public rewardPerGaugeWeightStored;
    uint256 private totalWeight;

    // ERC-721 minting stuff

    uint8 constant BURN_WEIGHT_COEFF = 10;

    IMerc public immutable merc;

    uint256 public tokenCount;
    uint256 public mintPrice;

    struct GaugeStakerState {
        uint256 balance;
        uint256 rewards;
        uint256 userRewardPerTokenPaid;
    }

    struct GaugeState {
        IERC20 stakingToken;
        uint256 totalStaked;
        mapping(address => GaugeStakerState) stakers;
        uint256 weight;
        mapping(address => uint256) pledges;
        uint256 rewardPerWeightPaid;
        uint256 rewards;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    mapping(uint256 => GaugeState) public gauges;

    constructor(IMerc _merc) ERC721("Mercenary Gauge", "gMERC") {
        merc = _merc;
        mintPrice = 10**merc.decimals();
    }

    function tokenURI(uint256)
        public
        pure
        virtual
        override
        returns (string memory)
    {
        return "TODO";
    }

    function mint(address to, IERC20 stakingToken) public returns (uint256 id) {
        id = tokenCount++;
        merc.transferFrom(msg.sender, address(this), mintPrice);

        _safeMint(to, id);
        gauges[id].stakingToken = stakingToken;
        gauges[id].weight = mintPrice;
        totalWeight += mintPrice;
        mintPrice = mintPrice * 2;

        return id;
    }

    ///// PLEDGING + BURNING MERC

    function weightOf(uint256 gaugeId)
        public
        view
        gaugeExists(gaugeId)
        returns (uint256)
    {
        return gauges[gaugeId].weight;
    }

    function pledge(uint256 gaugeId, uint256 amount)
        public
        gaugeExists(gaugeId)
        updateGaugeReward(gaugeId)
    {
        GaugeState storage g = gauges[gaugeId];
        g.pledges[msg.sender] += amount;
        g.weight += amount;
        totalWeight += amount;

        merc.transferFrom(msg.sender, address(this), amount);

        emit Pledge(gaugeId, msg.sender, amount);
    }

    function pledged(uint256 gaugeId, address account)
        public
        view
        returns (uint256)
    {
        GaugeState storage g = gauges[gaugeId];
        return g.pledges[account];
    }

    function depledge(uint256 gaugeId, uint256 amount)
        public
        gaugeExists(gaugeId)
        updateGaugeReward(gaugeId)
    {
        GaugeState storage g = gauges[gaugeId];
        if (amount > g.pledges[msg.sender]) {
            revert AmountTooHigh();
        }
        g.pledges[msg.sender] -= amount;
        g.weight -= amount;
        totalWeight -= amount;

        merc.transferFrom(msg.sender, address(this), amount);

        emit Depledge(gaugeId, msg.sender, amount);
    }

    function burn(uint256 gaugeId, uint256 amount)
        public
        gaugeExists(gaugeId)
        updateGaugeReward(gaugeId)
    {
        GaugeState storage g = gauges[gaugeId];
        uint256 w = amount * BURN_WEIGHT_COEFF;
        g.weight += w;
        totalWeight += w;

        merc.transferFrom(msg.sender, address(this), amount);
        merc.burn(amount);
        emit Burn(gaugeId, msg.sender, amount);
    }

    function stake(uint256 gaugeId, uint256 amount)
        public
        gaugeExists(gaugeId)
        updateStakingReward(gaugeId, msg.sender)
    {
        GaugeState storage g = gauges[gaugeId];

        g.totalStaked += amount;
        g.stakers[msg.sender].balance += amount;
        g.stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Stake(gaugeId, msg.sender, amount);
    }

    function staked(uint256 gaugeId, address account)
        public
        view
        returns (uint256)
    {
        return gauges[gaugeId].stakers[account].balance;
    }

    function unstake(uint256 gaugeId, uint256 amount)
        public
        gaugeExists(gaugeId)
        updateStakingReward(gaugeId, msg.sender)
    {
        GaugeState storage g = gauges[gaugeId];

        g.totalStaked += amount;
        g.stakers[msg.sender].balance += amount;
        g.stakingToken.safeTransfer(msg.sender, amount);
        emit Unstake(gaugeId, msg.sender, amount);
    }

    function claimReward(uint256 gaugeId)
        public
        gaugeExists(gaugeId)
        updateStakingReward(gaugeId, msg.sender)
        returns (uint256)
    {
        GaugeState storage g = gauges[gaugeId];

        uint256 reward = g.stakers[msg.sender].rewards;
        if (reward != 0) {
            g.stakers[msg.sender].rewards = 0;
            merc.mint();
            merc.transfer(msg.sender, reward);
            emit RewardPaid(gaugeId, msg.sender, reward);
        }
        return reward;
    }

    /// Weight rewards per gauge

    function rewardPerGaugeWeight() public view returns (uint256) {
        if (totalWeight == 0) {
            return rewardPerGaugeWeightStored;
        }
        return
            rewardPerGaugeWeightStored +
            ((rewardRate *
                (block.timestamp - lastUpdateTime) *
                REWARD_PER_GAUGE_WEIGHT_PRECISION) / totalWeight);
    }

    function gaugeEarned(uint256 gaugeId) public view returns (uint256) {
        GaugeState storage g = gauges[gaugeId];

        return
            ((g.weight * (rewardPerGaugeWeight() - g.rewardPerWeightPaid)) /
                REWARD_PER_GAUGE_WEIGHT_PRECISION) + g.rewards;
    }

    function _updateGaugeReward(uint256 gaugeId) private {
        GaugeState storage g = gauges[gaugeId];

        rewardPerGaugeWeightStored = rewardPerGaugeWeight();
        lastUpdateTime = block.timestamp;
        g.rewards = gaugeEarned(gaugeId);
        g.rewardPerWeightPaid = rewardPerGaugeWeightStored;
    }

    modifier updateGaugeReward(uint256 gaugeId) {
        _updateGaugeReward(gaugeId);
        _;
    }

    /// Gauge staking rewards per account

    function rewardPerToken(uint256 gaugeId) public view returns (uint256) {
        GaugeState storage g = gauges[gaugeId];
        if (g.totalStaked * totalWeight == 0) {
            return g.rewardPerTokenStored;
        }
        uint256 gaugeRewardRate = (rewardRate *
            g.weight *
            REWARD_PER_TOKEN_PRECISION) / totalWeight;
        return
            g.rewardPerTokenStored +
            (gaugeRewardRate * (block.timestamp - g.lastUpdateTime)) /
            g.totalStaked;
    }

    function earned(uint256 gaugeId, address account)
        public
        view
        returns (uint256)
    {
        GaugeState storage g = gauges[gaugeId];
        return
            ((g.stakers[account].balance *
                (rewardPerToken(gaugeId) -
                    g.stakers[account].userRewardPerTokenPaid)) /
                REWARD_PER_TOKEN_PRECISION) + g.stakers[account].rewards;
    }

    modifier updateStakingReward(uint256 gaugeId, address account) {
        _updateGaugeReward(gaugeId);

        GaugeState storage g = gauges[gaugeId];

        g.rewardPerTokenStored = rewardPerToken(gaugeId);
        g.lastUpdateTime = block.timestamp;
        g.stakers[account].rewards = earned(gaugeId, account);
        g.stakers[account].userRewardPerTokenPaid = g.rewardPerTokenStored;

        _;
    }

    modifier gaugeExists(uint256 gaugeId) {
        if (!_exists(gaugeId)) {
            revert NotFound();
        }
        _;
    }
}
