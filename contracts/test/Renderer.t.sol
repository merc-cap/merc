// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../node_modules/ds-test/src/test.sol";
import "./CheatCodes.sol";
import "../node_modules/solidity-stringutils/src/strings.sol";
import "../node_modules/base64-sol/base64.sol";
import "./console.sol";
import "../src/Renderer.sol";
import "../src/interfaces/IGauge.sol";
import "./MockMerc.sol";
import "./MockGauge.sol";

contract RendererTest is DSTest {
    using strings for *;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Renderer public renderer;

    function setUp() public {
        MockMerc m = new MockMerc();
        MockGauge g = new MockGauge(m);
        renderer = new Renderer(g);
    }

    function testRendersBase64Prefix() public {
        string memory uri = renderer.tokenURI(2);

        assertTrue(
            strings.startsWith(
                uri.toSlice(),
                string("data:application/json;base64,").toSlice()
            )
        );
    }

    function testDecodeableAsBase64() public {
        string memory uri = renderer.tokenURI(2);

        string memory data = uri
            .toSlice()
            .beyond(string("data:application/json;base64,").toSlice())
            .toString();

        bytes memory result = Base64.decode(data);
        assertTrue(result.length > 10);
    }

    function testLogSvgUri() public {
        string memory uri = renderer.dataURISVG(2);
        console.log(uri);
    }

    function testLogSvg() public {
        string memory uri = renderer.svgMarkup(2);
        console.log(uri);
    }
}
