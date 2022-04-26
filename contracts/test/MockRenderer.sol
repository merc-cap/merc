// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../src/interfaces/IRenderer.sol";

contract MockRenderer is IRenderer {
    function tokenURI(uint256) public pure override returns (string memory) {
        return "foo://bar";
    }
}
