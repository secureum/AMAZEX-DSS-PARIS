// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title ModernWETH: The Insecure Modern Wrapped Ether
 */
contract ModernWETH is ERC20("Modern Insec Wrapped Ether", "mWETH"), ReentrancyGuard {
    
    /**
     * @notice Deposit ether to get wrapped ether
     */
    function deposit() public payable {
        _mint(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw, burn wrapped ether to get ether
     */
    function withdraw(uint256 wad) external nonReentrant {
        (bool success,) = msg.sender.call{value: wad}("");
        require(success, "mWETH: ETH transfer failed");

        _burn(msg.sender, wad);
    }

    /**
     * @notice Withdraw, burn all wrapped ether to get all deposited ether
     */
    function withdrawAll() external nonReentrant {
        (bool success,) = msg.sender.call{value: balanceOf(msg.sender)}("");
        require(success, "mWETH: ETH transfer failed");

        _burnAll();
    }

    /**
     * @notice Burn all internal utility to burn all wrapped ether from the caller
     */
    function _burnAll() internal {
        _burn(msg.sender, balanceOf(msg.sender));
    }
}
