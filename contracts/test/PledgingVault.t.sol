// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../node_modules/ds-test/src/test.sol";
import "../src/Merc.sol";
import {PledgingVault} from "../src/PledgingVault.sol";
import {MockERC20} from "./MockERC20.sol";
import {Gauge} from "../src/Gauge.sol";
import "./CheatCodes.sol";
import {ERC721TokenReceiver} from "@rari-capital/solmate/src/tokens/ERC721.sol";

contract PledgingVaultTest is DSTest, ERC721TokenReceiver {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Merc merc;
    MockERC20 staked;
    PledgingVault pMERC;
    Gauge gauge;
    uint256 gaugeId;

    function setUp() public {
        merc = new Merc();
        staked = new MockERC20();
        gauge = new Gauge(merc);
        merc.setMintReceiver(address(gauge));
        merc.approve(address(gauge), 1e18);
        gaugeId = gauge.mint(address(this), staked);
        pMERC = gauge.pledgingVaultOf(gaugeId);
    }

    function testCanDepositAndWithdraw() public {
        uint256 holdings = merc.balanceOf(address(this));

        merc.approve(address(pMERC), 100e18);
        pMERC.deposit(100e18, address(this));
        assertEq(merc.balanceOf(address(this)), holdings - 100e18);
        assertEq(pMERC.balanceOf(address(this)), 100e18);
        assertEq(merc.balanceOf(address(gauge)), 100e18);
        assertEq(pMERC.totalAssets(), 100e18);

        pMERC.withdraw(100e18, address(this), address(this));
        assertEq(pMERC.balanceOf(address(this)), 0);
        assertEq(pMERC.totalAssets(), 0);
        assertEq(merc.balanceOf(address(this)), holdings);
        assertEq(merc.balanceOf(address(gauge)), 0);
    }
}
