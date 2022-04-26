// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract IMerc is IERC20Metadata {
    function mint() external virtual;

    function burn(uint256 amount) external virtual;
}
