// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./PledgingVault.sol";
import "./StakingVault.sol";

import "./interfaces/IMerc.sol";
import "./interfaces/IRenderer.sol";
import "./interfaces/IGauge.sol";
import "../test/console.sol";

contract Gauge is Ownable, ERC721Enumerable, IGauge {
    using SafeERC20 for IERC20Metadata;
    using SafeERC20 for IMerc;

    error NotFound();
    error OnlyOwner();
    error AmountTooHigh();
    error InvalidStakingToken();
    error DeactivatedGauge();
    error InvalidSender();
    error NullRenderer();

    event Pledge(uint256 gaugeId, address account, uint256 amount);
    event Depledge(uint256 gaugeId, address account, uint256 amount);
    event Burn(uint256 gaugeId, address account, uint256 amount);
    event Stake(uint256 gaugeId, address account, uint256 amount);
    event Unstake(uint256 gaugeId, address account, uint256 amount);
    event RewardPaid(uint256 gaugeId, address account, uint256 amount);

    // Staking state

    struct WalletState {
        uint256 pledged;
        uint256 balance;
        uint256 rewards;
        uint256 userRewardPerTokenPaid;
    }

    struct State {
        IERC20Metadata stakingToken;
        StakingVault stakingVault;
        PledgingVault pledgingVault;
        uint256 totalStaked;
        mapping(address => WalletState) wallets;
        uint256 totalRewarded;
        uint256 weight;
        uint256 totalPledged;
        uint256 rewardPerWeightPaid;
        uint256 rewards;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    uint256 public constant REWARD_PER_GAUGE_WEIGHT_PRECISION = 1e18;
    uint256 public constant REWARD_PER_TOKEN_PRECISION = 1e36;

    uint256 public rewardRate = 23456789012345678901; // TODO - get this from Merc.
    uint256 public lastUpdateTime;
    uint256 public immutable createTime;
    uint256 public rewardPerGaugeWeightStored;
    uint256 public totalWeight;

    // ERC-721 minting stuff

    uint8 public constant BURN_WEIGHT_COEFF = 10;

    IMerc public immutable override merc;
    PledgingVault private immutable defaultPledgingVault;
    StakingVault private immutable defaultStakingVault;

    uint256 public tokenCount;
    uint256 public mintPrice;

    IRenderer public renderer;

    mapping(uint256 => State) public gauges;

    constructor(IMerc _merc) ERC721("Mercenary Gauge", "G-MERC") {
        merc = _merc;
        mintPrice = 10**merc.decimals();
        defaultPledgingVault = new PledgingVault();
        // economically impossible to mint uint256.max gauges
        defaultPledgingVault.initialize(
            Gauge(address(0)),
            type(uint256).max,
            IERC20Metadata(address(0)),
            "",
            ""
        );

        defaultStakingVault = new StakingVault();
        defaultStakingVault.initialize(
            Gauge(address(0)),
            type(uint256).max,
            IERC20Metadata(address(0)),
            "",
            ""
        );
        createTime = block.timestamp;
    }

    function tokenURI(uint256 gaugeId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (address(renderer) == address(0)) {
            revert NullRenderer();
        }
        return renderer.tokenURI(gaugeId);
    }

    function setRenderer(IRenderer _renderer) public onlyOwner {
        renderer = _renderer;
    }

    function mint(address to, IERC20Metadata _stakingToken)
        public
        returns (uint256 id)
    {
        if (address(_stakingToken) == address(0)) {
            revert InvalidStakingToken();
        }
        id = tokenCount++;
        merc.safeTransferFrom(msg.sender, address(this), mintPrice);
        merc.burn(mintPrice);

        _safeMint(to, id);
        gauges[id].stakingToken = _stakingToken;
        gauges[id].weight = mintPrice;
        gauges[id].lastUpdateTime = block.timestamp;
        totalWeight += mintPrice;
        mintPrice = mintPrice * 2;

        string memory idStr = Strings.toString(id);
        gauges[id].pledgingVault = PledgingVault(
            Clones.clone(address(defaultPledgingVault))
        );
        gauges[id].pledgingVault.initialize(
            this,
            id,
            merc,
            string.concat("Pledged Merc Gauge ", idStr),
            string.concat("pMERC-", idStr)
        );

        gauges[id].stakingVault = StakingVault(
            Clones.clone(address(defaultStakingVault))
        );
        gauges[id].stakingVault.initialize(
            this,
            id,
            _stakingToken,
            string.concat("Merc Gauge ", idStr, " ", _stakingToken.name()),
            string.concat("MG-", idStr, "-", _stakingToken.symbol())
        );

        return id;
    }

    function recycle(uint256 gaugeId, IERC20Metadata _stakingToken)
        public
        gaugeExists(gaugeId)
        returns (uint256 id)
    {
        if (ownerOf(gaugeId) != msg.sender) {
            revert OnlyOwner();
        }
        State storage original = gauges[gaugeId];
        uint256 transferrableWeight = burnedWeightOf(gaugeId);
        // TODO - recycle fee?
        // merc.transferFrom(msg.sender, address(this), recycleFee);

        id = tokenCount++;
        _safeMint(msg.sender, id);
        gauges[id].stakingToken = _stakingToken;
        gauges[id].weight = transferrableWeight;

        original.weight -= transferrableWeight;
        _burn(gaugeId);

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

    function pledged(uint256 gaugeId) public view returns (uint256) {
        return gauges[gaugeId].totalPledged;
    }

    function burnedWeightOf(uint256 gaugeId) public view returns (uint256) {
        State storage g = gauges[gaugeId];
        return g.weight - g.totalPledged;
    }

    function pledgingVaultOf(uint256 gaugeId)
        public
        view
        returns (PledgingVault)
    {
        State storage g = gauges[gaugeId];
        return g.pledgingVault;
    }

    function pledge(
        uint256 gaugeId,
        uint256 amount,
        address who
    )
        public
        gaugeExists(gaugeId)
        gaugeActive(gaugeId)
        updateGaugeReward(gaugeId)
    {
        State storage g = gauges[gaugeId];
        if (msg.sender != address(g.pledgingVault)) {
            revert InvalidSender();
        }
        g.wallets[who].pledged += amount;
        g.weight += amount;
        g.totalPledged += amount;
        totalWeight += amount;

        merc.safeTransferFrom(msg.sender, address(this), amount);

        emit Pledge(gaugeId, who, amount);
    }

    function pledged(uint256 gaugeId, address account)
        public
        view
        returns (uint256)
    {
        State storage g = gauges[gaugeId];
        return g.wallets[account].pledged;
    }

    function depledge(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public gaugeExists(gaugeId) updateGaugeReward(gaugeId) {
        State storage g = gauges[gaugeId];
        if (msg.sender != address(g.pledgingVault)) {
            revert InvalidSender();
        }
        if (amount > g.wallets[who].pledged) {
            revert AmountTooHigh();
        }
        g.wallets[who].pledged -= amount;
        g.weight -= amount;
        g.totalPledged -= amount;
        totalWeight -= amount;

        merc.safeTransfer(msg.sender, amount);

        emit Depledge(gaugeId, who, amount);
    }

    function burn(uint256 gaugeId, uint256 amount)
        public
        gaugeExists(gaugeId)
        gaugeActive(gaugeId)
        updateGaugeReward(gaugeId)
    {
        State storage g = gauges[gaugeId];
        uint256 w = amount * BURN_WEIGHT_COEFF;
        g.weight += w;
        totalWeight += w;

        merc.transferFrom(msg.sender, address(this), amount);
        merc.burn(amount);
        emit Burn(gaugeId, msg.sender, amount);
    }

    function stakingToken(uint256 gaugeId)
        public
        view
        returns (IERC20Metadata)
    {
        return gauges[gaugeId].stakingToken;
    }

    function stakingVaultOf(uint256 gaugeId)
        public
        view
        returns (StakingVault)
    {
        State storage g = gauges[gaugeId];
        return g.stakingVault;
    }

    function stake(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public gaugeExists(gaugeId) updateStakingReward(gaugeId, who) {
        State storage g = gauges[gaugeId];

        if (msg.sender != address(g.stakingVault)) {
            revert InvalidSender();
        }

        g.totalStaked += amount;
        g.wallets[who].balance += amount;
        g.stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Stake(gaugeId, who, amount);
    }

    function totalStaked(uint256 gaugeId) public view returns (uint256) {
        return gauges[gaugeId].totalStaked;
    }

    function staked(uint256 gaugeId, address account)
        public
        view
        returns (uint256)
    {
        return gauges[gaugeId].wallets[account].balance;
    }

    function unstake(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public gaugeExists(gaugeId) updateStakingReward(gaugeId, who) {
        State storage g = gauges[gaugeId];

        if (msg.sender != address(g.stakingVault)) {
            revert InvalidSender();
        }

        if (amount > g.wallets[who].balance) {
            revert AmountTooHigh();
        }

        g.totalStaked -= amount;
        g.wallets[who].balance -= amount;
        g.stakingToken.safeTransfer(msg.sender, amount);
        emit Unstake(gaugeId, who, amount);
    }

    function claimReward(uint256 gaugeId)
        public
        gaugeExists(gaugeId)
        updateStakingReward(gaugeId, msg.sender)
        returns (uint256)
    {
        State storage g = gauges[gaugeId];

        uint256 reward = g.wallets[msg.sender].rewards;
        if (reward != 0) {
            g.wallets[msg.sender].rewards = 0;
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
        State storage g = gauges[gaugeId];

        return
            ((g.weight * (rewardPerGaugeWeight() - g.rewardPerWeightPaid)) /
                REWARD_PER_GAUGE_WEIGHT_PRECISION) + g.rewards;
    }

    function _updateGaugeReward(uint256 gaugeId) private {
        State storage g = gauges[gaugeId];

        rewardPerGaugeWeightStored = rewardPerGaugeWeight();
        lastUpdateTime = block.timestamp;
        g.rewards = gaugeEarned(gaugeId);
        g.totalRewarded += gaugeEarned(gaugeId);
        g.rewardPerWeightPaid = rewardPerGaugeWeightStored;
    }

    modifier updateGaugeReward(uint256 gaugeId) {
        _updateGaugeReward(gaugeId);
        _;
    }

    /// Gauge staking rewards per account

    function rewardPerToken(uint256 gaugeId) public view returns (uint256) {
        State storage g = gauges[gaugeId];
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
        State storage g = gauges[gaugeId];
        return
            ((g.wallets[account].balance *
                (rewardPerToken(gaugeId) -
                    g.wallets[account].userRewardPerTokenPaid)) /
                REWARD_PER_TOKEN_PRECISION) + g.wallets[account].rewards;
    }

    modifier updateStakingReward(uint256 gaugeId, address account) {
        _updateGaugeReward(gaugeId);

        State storage g = gauges[gaugeId];

        g.rewardPerTokenStored = rewardPerToken(gaugeId);
        g.lastUpdateTime = block.timestamp;
        g.wallets[account].rewards = earned(gaugeId, account);
        g.wallets[account].userRewardPerTokenPaid = g.rewardPerTokenStored;

        _;
    }

    function _exists(uint256 tokenId) internal view override returns (bool) {
        return address(gauges[tokenId].stakingToken) != address(0);
    }

    modifier gaugeExists(uint256 gaugeId) {
        if (!_exists(gaugeId)) {
            revert NotFound();
        }
        _;
    }

    modifier gaugeActive(uint256 gaugeId) {
        if (!super._exists(gaugeId)) {
            revert DeactivatedGauge();
        }
        _;
    }
}
