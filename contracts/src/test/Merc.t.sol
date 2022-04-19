// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Merc.sol";
import "./CheatCodes.sol";
import "./console.sol";

contract MercTest is DSTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Merc merc;
    address gauge = address(0x01);
    address user = address(0x02);

    function setUp() public {
        merc = new Merc(gauge);
    }

    function testInitialValues() public {
        assertEq(merc.gauge(), gauge);
        assertEq(merc.balanceOf(address(this)), merc.INITIAL_MINT());
        assertEq(merc.lastMint(), block.timestamp);
        assertEq(merc.mintable(), 0);
    }

    function testMintable(uint256 offset) public {
        cheats.warp(block.timestamp + offset);
        if (offset >= merc.EMISSION_DURATION()) {
            assertEq(merc.mintable(), merc.MAX_EMISSION());
        } else {
            assertEq(merc.mintable(), merc.EMISSION_RATE() * offset);
        }
    }

    function testMint(uint256 offset) public {
        cheats.warp(block.timestamp + offset);

        uint256 mintable = merc.mintable();
        if (mintable == 0) {
            cheats.expectRevert(abi.encodeWithSignature("SupplyLimit()"));
            merc.mint();
        } else {
            merc.mint();
            assertEq(merc.balanceOf(gauge), mintable);
        }
    }

    function testBurn(uint256 amount) public {
        if (amount > merc.balanceOf(address(this))) {
            cheats.expectRevert(bytes("ERC20: burn amount exceeds balance"));
            merc.burn(amount);
        } else {
            uint256 supply = merc.totalSupply();
            uint256 maxSupply = merc.maxSupply();
            merc.burn(amount);
            assertEq(merc.totalSupply(), supply - amount);
            assertEq(merc.maxSupply(), maxSupply - amount);
        }
    }

    function testGaugeAllowance() public {
        assertEq(merc.allowance(user, gauge), type(uint256).max);
    }
}
