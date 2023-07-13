// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

/**
 * @title WETH contract
 */
contract WETH is ERC20("WETH", "WETH") {

    /**
     * @dev Mint WETH tokens to the function caller
     */
    function deposit() public payable {
        _mint(msg.sender, msg.value);
    }

    /**
     * @dev Burn WETH tokens from the function caller to receive ETH back
     * @param amount The amount of WETH tokens to burn
     */
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }


    receive() external payable {
        deposit();
    }


    fallback() external payable {
        deposit();
    }
}
