// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./IMerc.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IGauge is IERC721Enumerable {
    function merc() external view returns (IMerc);

    function stakingToken(uint256 gaugeId)
        external
        view
        returns (IERC20Metadata);

    function weightOf(uint256 gaugeId) external view returns (uint256);
}
