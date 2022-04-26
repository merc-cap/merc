// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IRenderer {
    function tokenURI(uint256 gaugeId) external view returns (string memory);
}
