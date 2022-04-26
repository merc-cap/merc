// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "base64-sol/base64.sol";
import "hot-chain-svg/contracts/SVG.sol";
import "./interfaces/IGauge.sol";
import "./interfaces/IRenderer.sol";

contract Renderer is IRenderer {
    IGauge public immutable gauge;

    constructor(IGauge _gauge) {
        gauge = _gauge;
    }

    function tokenURI(uint256 gaugeId)
        public
        view
        override
        returns (string memory)
    {
        string memory svgData = dataURISVG(gaugeId);

        string memory json = Base64.encode(
            bytes.concat(
                '{"name": "MY NFT", "description": "", "image_data": "',
                bytes(svgData),
                '"}'
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function dataURISVG(uint256 gaugeId) public view returns (string memory) {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(svgMarkup(gaugeId)))
            );
    }

    function svgMarkup(uint256 gaugeId) private view returns (string memory) {
        // uint256 pledged = gauge.pledged(gaugeId);
        // uint256 totalStaked = gauge.totalStaked(gaugeId);

        string memory header = string.concat(
            '<svg width="400" height="400" viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg">',
            "<style>",
            ".text { font-family: monospace; fill: white; font-size: 16px }",
            ".bold { font-weight: bold }",
            ".card { fill: url(#gradient) black }",
            "</style>"
        );

        string memory footer = string.concat(
            "<defs>",
            '<radialGradient id="gradient" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(383 28) rotate(135) scale(541.644)">',
            '<stop stop-color="#990000"/>',
            '<stop offset="1"/>',
            "</radialGradient>",
            "</defs>"
            "</svg>"
        );

        string memory background = string.concat(
            svg.rect(
                string.concat(
                    svg.prop("class", "card"),
                    svg.prop("width", "400"),
                    svg.prop("height", "400"),
                    svg.prop("rx", "24")
                ),
                utils.NULL
            ),
            svg.rect(
                string.concat(
                    svg.prop("x", "11.5"),
                    svg.prop("y", "11.5"),
                    svg.prop("width", "377"),
                    svg.prop("height", "377"),
                    svg.prop("rx", "17.5"),
                    svg.prop("stroke", "white")
                ),
                utils.NULL
            )
        );
        string memory title = svg.text(
            string.concat(
                svg.prop("class", "bold text"),
                svg.prop("x", "30"),
                svg.prop("y", "50")
            ),
            string.concat(
                svg.cdata("Mercenary Capital Gauge #"),
                utils.uint2str(gaugeId)
            )
        );

        string memory power = svg.text(
            string.concat(
                svg.prop("class", "text"),
                svg.prop("x", "30"),
                svg.prop("y", "80")
            ),
            string.concat(
                "Weight: ",
                utils.uint2str(
                    (100 * gauge.weightOf(gaugeId)) /
                        gauge.totalWeight() /
                        (10**gauge.merc().decimals())
                ),
                "%"
            )
        );

        string memory burnedWeight = svg.text(
            string.concat(
                svg.prop("class", "text"),
                svg.prop("x", "30"),
                svg.prop("y", "110")
            ),
            string.concat(
                "Permanent: ",
                utils.uint2str(
                    gauge.burnedWeightOf(gaugeId) /
                        (10**gauge.merc().decimals())
                )
            )
        );

        string memory pledged = svg.text(
            string.concat(
                svg.prop("class", "text"),
                svg.prop("x", "30"),
                svg.prop("y", "155")
            ),
            string.concat("x", " pledged")
        );

        string memory totalStaked = svg.text(
            string.concat(
                svg.prop("class", "text"),
                svg.prop("x", "30"),
                svg.prop("y", "215")
            ),
            string.concat(utils.uint2str(gauge.totalStaked(gaugeId)), " staked")
        );

        string memory symbol = svg.text(
            string.concat(
                svg.prop("class", "bold text"),
                svg.prop("x", "30"),
                svg.prop("y", "270")
            ),
            gauge.stakingToken(gaugeId).symbol()
        );

        return
            string.concat(
                header,
                background,
                title,
                power,
                burnedWeight,
                pledged,
                totalStaked,
                symbol,
                footer
            );
    }
}
