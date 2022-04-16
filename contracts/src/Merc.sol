// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IMerc.sol";

contract Merc is ERC20, IMerc {
    error SupplyLimit();
    error NotAuthorized();

    uint256 public constant INITIAL_MINT = 1e27;
    uint256 public constant EMISSION_DURATION = 4 * 365 days;
    uint256 public constant EMISSION_RATE = 23456789012345678901;
    uint256 public constant MAX_EMISSION = EMISSION_RATE * EMISSION_DURATION;

    uint256 public maxSupply = INITIAL_MINT + MAX_EMISSION;
    uint256 public lastMint;
    address public mintReceiver;

    constructor() ERC20("Mercenary", "MERC") {
        mintReceiver = msg.sender;
        lastMint = block.timestamp;
        _mint(msg.sender, INITIAL_MINT);
    }

    function setMintReceiver(address _mintReceiver) external {
        if (msg.sender != mintReceiver) {
            revert NotAuthorized();
        }
        mintReceiver = _mintReceiver;
    }

    function mintable() public view returns (uint256 amount) {
        uint256 duration = (block.timestamp - lastMint);
        if (duration > EMISSION_DURATION) {
            duration = EMISSION_DURATION;
        }
        amount = EMISSION_RATE * duration;
        uint256 maxAmount = maxSupply - totalSupply();
        if (amount > maxAmount) {
            amount = maxAmount;
        }
        return amount;
    }

    function mint() external override {
        uint256 amount = mintable();
        if (amount == 0) {
            revert SupplyLimit();
        }
        _mint(mintReceiver, mintable());
        lastMint = block.timestamp;
    }

    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
        maxSupply -= amount;
    }
}
