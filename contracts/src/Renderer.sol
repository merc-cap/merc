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
        string memory svgData = svgDataURI(gaugeId);
        string memory json = Base64.encode(
            bytes.concat(
                '{"name": "MY NFT", "description": "", "image_data": "',
                bytes(svgData),
                '"}'
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function svgDataURI(uint256 gaugeId) public view returns (string memory) {
        return
            string.concat(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(svgMarkup(gaugeId)))
            );
    }

    function svgMarkup(uint256 gaugeId) public view returns (string memory) {
        string memory symbol = gauge.stakingToken(gaugeId).symbol();
        string memory weight = utils.uint2str(
            gauge.weightOf(gaugeId) / (10**gauge.merc().decimals())
        );

        return
            string.concat(
                "<svg xmlns='http://www.w3.org/2000/svg' width='300' height='300' style='background:#000'>",
                svg.text(
                    string.concat(
                        svg.prop("x", "20"),
                        svg.prop("y", "40"),
                        svg.prop("font-size", "22"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Gauge #"), utils.uint2str(gaugeId))
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "20"),
                        svg.prop("y", "80"),
                        svg.prop("font-size", "22"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Token: "), symbol)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "20"),
                        svg.prop("y", "120"),
                        svg.prop("font-size", "22"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Weight: "), weight)
                ),
                svg.rect(
                    string.concat(
                        svg.prop("fill", "purple"),
                        svg.prop("x", "20"),
                        svg.prop("y", "150"),
                        svg.prop("width", utils.uint2str(160)),
                        svg.prop("height", utils.uint2str(10))
                    ),
                    utils.NULL
                ),
                "</svg>"
            );
    }
}
