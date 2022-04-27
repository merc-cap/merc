// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../src/interfaces/IGauge.sol";
import "../src/interfaces/IMerc.sol";

import "./MockERC20.sol";
import "./MockMerc.sol";

contract MockGauge is ERC721Enumerable, IGauge {
    MockERC20 _stakingToken;
    MockMerc _mockMerc;

    constructor(IMerc) ERC721("Mock Gauge", "mGauge") {
        _stakingToken = new MockERC20();
        _mockMerc = new MockMerc();
    }

    function merc() external view override returns (IMerc) {
        return _mockMerc;
    }

    function totalWeight() external view returns (uint256) {
        return 1000e18;
    }

    function weightOf(uint256) public pure returns (uint256) {
        return 8789e17;
    }

    function pledged(uint256) public pure returns (uint256) {
        return 1254e17;
    }

    function burnedWeightOf(uint256) public pure returns (uint256) {
        return weightOf(0) - pledged(0);
    }

    // function pledgingVaultOf(uint256 gaugeId)
    //     public
    //     view
    //     returns (PledgingVault)
    // {
    //     return PledgingVault(address(0));
    // }

    function pledge(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public {}

    function pledged(uint256 gaugeId, address account)
        public
        view
        returns (uint256)
    {}

    function depledge(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public {}

    function burn(uint256 gaugeId, uint256 amount) public {}

    function stakingToken(uint256)
        external
        view
        override
        returns (IERC20Metadata)
    {
        return IERC20Metadata(_stakingToken);
    }

    // function stakingVaultOf(uint256 gaugeId)
    //     public
    //     view
    //     returns (StakingVault)
    // {
    //     return StakingVault(address(0));
    // }

    function stake(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public {}

    function totalStaked(uint256) public pure returns (uint256) {
        return 1;
    }

    function staked(uint256, address) public pure returns (uint256) {
        return 1;
    }

    function unstake(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) public {}

    function claimReward(uint256) public pure returns (uint256) {
        return 100;
    }

    function rewardPerToken(uint256) public pure returns (uint256) {
        return 1;
    }

    function earned(uint256, address) public pure returns (uint256) {
        return 1;
    }
}
