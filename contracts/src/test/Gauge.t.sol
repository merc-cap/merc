// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../Gauge.sol";
import "./MockMerc.sol";
import "./CheatCodes.sol";

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";

contract GaugeTest is DSTest, ERC721TokenReceiver {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    MockMerc merc;
    Gauge gauge;

    function setUp() public {
        merc = new MockMerc();
        merc.mint(address(this), 100e18);
        gauge = new Gauge(merc);
    }

    function testInitialValues() public {
        assertEq(gauge.mintPrice(), 1e18);
    }

    function testRevertsPledgeNotFound() public {
        cheats.expectRevert(abi.encodeWithSignature("NotFound()"));
        gauge.pledge(10, 1000);
    }

    function testRevertsBurnNotFound() public {
        cheats.expectRevert(abi.encodeWithSignature("NotFound()"));
        gauge.burn(10, 1000);
    }

    function testMint() public {
        merc.approve(address(gauge), 10e18);
        uint256 gaugeId = gauge.mint(address(this));
        assertEq(gauge.ownerOf(gaugeId), address(this));
        assertEq(gauge.weightOf(gaugeId), 1e18);
        assertEq(gauge.mintPrice(), 2e18);
    }

    function testPledge() public {
        merc.approve(address(gauge), 10e18);
        uint256 gaugeId = gauge.mint(address(this));
        gauge.pledge(gaugeId, 1000);
        assertEq(gauge.weightOf(gaugeId), 1e18 + 1000);
        assertEq(gauge.pledged(gaugeId, address(this)), 1000);

        gauge.depledge(gaugeId, 1000);
        assertEq(gauge.weightOf(gaugeId), 1e18);
        assertEq(gauge.pledged(gaugeId, address(this)), 0);
    }

    function testBurn() public {
        merc.approve(address(gauge), 10e18);
        uint256 gaugeId = gauge.mint(address(this));
        gauge.burn(gaugeId, 1000);
        assertEq(gauge.weightOf(gaugeId), 1e18 + 10000);
        assertEq(gauge.pledged(gaugeId, address(this)), 0);
    }
}
