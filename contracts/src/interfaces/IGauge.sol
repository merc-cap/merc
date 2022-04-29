// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./IMerc.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IGauge {
    function merc() external view returns (IMerc);

    function totalWeight() external view returns (uint256);

    function weightOf(uint256 gaugeId) external view returns (uint256);

    function pledged(uint256 gaugeId) external view returns (uint256);

    function burnedWeightOf(uint256 gaugeId) external view returns (uint256);

    // function pledgingVaultOf(uint256 gaugeId)
    //     external
    //     view
    //     returns (PledgingVault);

    function pledge(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) external;

    function pledged(uint256 gaugeId, address account)
        external
        view
        returns (uint256);

    function depledge(
        uint256 gaugeId,
        uint256 amount,
        address who
    ) external;

    function burn(uint256 gaugeId, uint256 amount) external;

    function stakingToken(uint256 gaugeId)
        external
        view
        returns (IERC20Metadata);

    function stake(
        uint256 gaugeId,
        uint256 amount
    ) external;

    function totalStaked(uint256 gaugeId) external view returns (uint256);

    function staked(uint256 gaugeId, address account)
        external
        view
        returns (uint256);

    function unstake(
        uint256 gaugeId,
        uint256 amount
    ) external;

    function claimReward(uint256 gaugeId) external returns (uint256);
}
