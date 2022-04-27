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

    function svgMarkup(uint256 gaugeId) public view returns (string memory) {
        uint256 weight = (1e4 * gauge.weightOf(gaugeId)) / gauge.totalWeight();

        string memory gradientColor = string.concat(
            "hsl(",
            utils.uint2str(100 + (260 * weight) / 1e4),
            ",100%,50%)"
        );
        string memory color = string.concat(
            "hsla(",
            // "0",
            utils.uint2str(100 + (260 * weight) / 1e4),
            ",100%,50%,10%)"
        );

        string memory header = string.concat(
            '<svg width="500" height="500" viewBox="0 0 500 500" fill="none" xmlns="http://www.w3.org/2000/svg">',
            "<style>",
            ".text { font-family: monospace; fill: white; font-size: 22px }",
            ".title { font-size: 22px }",
            ".bold { font-weight: bold }",
            ".card { fill: url(#gradient) black }",
            "</style>"
        );

        string memory footer = string.concat(
            "<defs>",
            '<radialGradient id="gradient" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(500 0) rotate(135) scale(600)">',
            '<stop stop-color="',
            gradientColor,
            '"/>',
            '<stop offset="1"/>',
            "</radialGradient>",
            "</defs>"
            "</svg>"
        );

        string memory background = string.concat(
            svg.rect(
                string.concat(
                    svg.prop("class", "card"),
                    svg.prop("x", "1"),
                    svg.prop("y", "1"),
                    svg.prop("width", "498"),
                    svg.prop("height", "498"),
                    svg.prop("rx", "24"),
                    svg.prop("stroke", color)
                ),
                utils.NULL
            )
        );
        for (uint256 i = 25; i <= 475; i += 25) {
            background = string.concat(
                background,
                svg.line(
                    string.concat(
                        svg.prop("x1", "0"),
                        svg.prop("y1", utils.uint2str(i)),
                        svg.prop("x2", "500"),
                        svg.prop("y2", utils.uint2str(i)),
                        svg.prop("stroke", color)
                    ),
                    utils.NULL
                ),
                svg.line(
                    string.concat(
                        svg.prop("x1", utils.uint2str(i)),
                        svg.prop("y1", "0"),
                        svg.prop("x2", utils.uint2str(i)),
                        svg.prop("y2", "500"),
                        svg.prop("stroke", color)
                    ),
                    utils.NULL
                )
            );
        }

        return
            string.concat(
                header,
                background,
                titleSvg(gaugeId, 75),
                weightSvg(gaugeId, 125),
                mercSvg(gaugeId, 175),
                burnRatioSvg(gaugeId, 225),
                stakingTokenSvg(gaugeId, 275),
                footer
            );
    }

    function titleSvg(uint256 gaugeId, uint256 y)
        private
        view
        returns (string memory)
    {
        IERC20Metadata t = gauge.stakingToken(gaugeId);
        return
            svg.text(
                string.concat(
                    svg.prop("class", "bold text title"),
                    svg.prop("x", "50"),
                    svg.prop("y", utils.uint2str(y - 1))
                ),
                string.concat(svg.cdata("MERC-GAUGE-"), t.symbol())
            );
    }

    function weightSvg(uint256 gaugeId, uint256 y)
        private
        view
        returns (string memory)
    {
        uint256 weight = (1e4 * gauge.weightOf(gaugeId)) / gauge.totalWeight();
        return
            textSvg(
                string.concat(
                    "Weight: ",
                    utils.uint2str(weight / 100),
                    ".",
                    utils.uint2str(weight % 100),
                    "%"
                ),
                y
            );
    }

    function mercSvg(uint256 gaugeId, uint256 y)
        private
        view
        returns (string memory)
    {
        uint256 merc = (gauge.weightOf(gaugeId)) /
            (10**gauge.merc().decimals());
        uint256 pledged = (gauge.pledged(gaugeId)) /
            (10**gauge.merc().decimals());
        uint256 burned = (gauge.burnedWeightOf(gaugeId)) /
            (4 * 10**gauge.merc().decimals());
        return
            textSvg(
                string.concat(
                    utils.uint2str(merc),
                    " MERC (4 * ",
                    utils.uint2str(burned),
                    " + ",
                    utils.uint2str(pledged),
                    ")"
                ),
                y
            );
    }

    function stakingTokenSvg(uint256 gaugeId, uint256 y)
        private
        view
        returns (string memory)
    {
        IERC20Metadata t = gauge.stakingToken(gaugeId);

        string memory stakedTokenInfo;
        if (address(t) != address(0)) {
            uint256 staked = (100 * gauge.totalStaked(gaugeId)) /
                (10**t.decimals());
            stakedTokenInfo = string.concat(
                utils.uint2str(staked / 100),
                ".",
                utils.uint2str(staked % 100),
                " ",
                t.symbol(),
                " staked"
            );
        } else {
            stakedTokenInfo = "Farming Gague (0x0)";
        }

        return textSvg(stakedTokenInfo, y);
    }

    function burnRatioSvg(uint256 gaugeId, uint256 y)
        private
        view
        returns (string memory)
    {
        uint256 burned = gauge.burnedWeightOf(gaugeId);
        uint256 pledged = gauge.pledged(gaugeId);
        uint256 ratio = pledged == 0 ? 0 : (100 * burned) / pledged;
        return
            textSvg(
                string.concat(
                    "Burn Ratio: ",
                    utils.uint2str(ratio / 100),
                    ".",
                    utils.uint2str(ratio % 100),
                    ""
                ),
                y
            );
    }

    function textSvg(string memory content, uint256 y)
        private
        pure
        returns (string memory)
    {
        return
            svg.text(
                string.concat(
                    svg.prop("class", "text"),
                    svg.prop("x", "50"),
                    svg.prop("y", utils.uint2str(y - 1))
                ),
                content
            );
    }
}
