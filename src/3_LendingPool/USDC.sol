// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title USDC
 */
contract USDC is ERC20 {

    /**
     * @dev Constructor that mints USDC tokens to the contract creator
     * @param amount The amount of USDC tokens to mint
     */
    constructor(uint256 amount) ERC20("USDC stablecoin", "USDC") {
        _mint(msg.sender, amount);
    }
}
