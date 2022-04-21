// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC4626 } from "./ERC4626.sol";
import { IMerc } from "./interfaces/IMerc.sol";
import { Gauge } from "./Gauge.sol";

contract PledgedMerc is ERC4626, Initializable {

    Gauge public gauge;
    uint256 public gaugeId;
    string private name_;
    string private symbol_;
    uint256 private pledgedMerc;

    constructor(
        IMerc _merc
    ) ERC4626(_merc, "", "") {
    }

    function initialize(Gauge _gauge, uint256 _gaugeId, string memory _name, string memory _symbol) public initializer {
        gauge = _gauge;
        gaugeId = _gaugeId;
        name_ = _name;
        symbol_ = _symbol;

        if (address(gauge) != address(0)) {
            // need to handle the case where we initialize with all zeros
            asset.approve(address(gauge), type(uint256).max);
        }
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return name_;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return symbol_;
    }


    /**
     * @dev Returns the amount of Merc in this vault
     */
    function totalAssets() public override view returns (uint256) {
        return pledgedMerc;
    }

    function beforeWithdraw(uint256 assets, uint256 shares, address owner) internal override {
        shares;
        pledgedMerc -= assets;
        gauge.depledge(gaugeId, assets, owner);
    }

    function afterDeposit(uint256 assets, uint256 shares, address receiver) internal override {
        shares;
        pledgedMerc += assets;
        gauge.pledge(gaugeId, assets, receiver);
    }
}