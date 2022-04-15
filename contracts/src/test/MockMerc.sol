// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../interfaces/IMerc.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockMerc is ERC20, IMerc {
    constructor() ERC20("Mock", "Mock Merc") {
        // TODO - define emission schedule
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }
}
