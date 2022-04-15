// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../Merc.sol";
import "./CheatCodes.sol";
import "./console.sol";

contract MercTest is DSTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Merc merc;

    function setUp() public {
        merc = new Merc();
    }

    function testInitialValues() public {
        assertEq(merc.mintReceiver(), address(this));
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
        address mintReceiver = address(0x9);
        merc.setMintReceiver(mintReceiver);
        cheats.warp(block.timestamp + offset);

        uint256 mintable = merc.mintable();
        if (mintable == 0) {
            cheats.expectRevert(abi.encodeWithSignature("SupplyLimit()"));
            merc.mint();
        } else {
            merc.mint();
            assertEq(merc.balanceOf(mintReceiver), mintable);
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
}
