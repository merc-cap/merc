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

    constructor(IMerc _merc) ERC721("Mock Gauge", "mGauge") {
        _stakingToken = new MockERC20();
        _mockMerc = new MockMerc();
    }

    function merc() external view override returns (IMerc) {
        return _mockMerc;
    }

    function stakingToken(uint256 gaugeId)
        external
        view
        override
        returns (IERC20Metadata)
    {
        return IERC20Metadata(_stakingToken);
    }

    function weightOf(uint256 gaugeId)
        external
        pure
        override
        returns (uint256)
    {
        return 1e18;
    }
}
