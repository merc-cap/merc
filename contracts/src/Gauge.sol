// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "openzeppelin/contracts/token/ERC721/ERC721.sol";
import "openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IMerc.sol";

contract Gauge is IERC721, ERC721Enumerable {
    using SafeERC20 for IERC20;

    error NotFound();
    error OnlyOwner();
    error AmountTooHigh();

    event Pledge(address account, uint256 gaugeId, uint256 amount);
    event Depledge(address account, uint256 gaugeId, uint256 amount);
    event Burn(address account, uint256 gaugeId, uint256 amount);

    // Staking state

    uint8 constant REWARD_RATE = 100;

    uint256 public lastUpdateTime;
    uint256 public rewardPerWeightStored;
    uint256 private totalWeight;

    // ERC-721 minting stuff

    uint8 constant BURN_WEIGHT_COEFF = 10;

    IMerc public immutable merc;

    uint256 public tokenCount;
    uint256 public mintPrice;

    struct GaugeStakerState {
        uint256 balance;
        uint256 rewards;
        uint256 rewardsPerTokenPaid;
    }

    struct GaugeState {
        // Token we're using to stake
        IERC20 stakingToken;
        // Total amount of stakingToken deposited
        uint256 totalStaked;
        // State of each staker in this gauge, including balance, accumulated rewards
        mapping(address => GaugeStakerState) stakers;
        // Current rewards per token stored
        uint256 rewardPerTokenStored;
        // Last time the state was updated
        uint256 lastUpdateTime;
        // How much weight this gauge has
        uint256 weight;
        mapping(address => uint256) pledges;
        uint256 rewardPerMercPaid;
        uint256 reward;
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
        return "some-svg-here";
    }

    function mint(address to) public returns (uint256 id) {
        id = tokenCount++;
        merc.transferFrom(msg.sender, address(this), mintPrice);

        _safeMint(to, id);
        gauges[id].weight = mintPrice;
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

        emit Pledge(msg.sender, gaugeId, amount);
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

        emit Depledge(msg.sender, gaugeId, amount);
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
        emit Burn(msg.sender, gaugeId, amount);
    }

    modifier gaugeExists(uint256 gaugeId) {
        if (!_exists(gaugeId)) {
            revert NotFound();
        }
        _;
    }

    modifier updateGaugeReward(uint256 gaugeId) {
        // TODO
        _;
    }
}
