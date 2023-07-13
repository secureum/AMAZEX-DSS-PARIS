// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MagicETH: The Insecure Wrapped Ether   
 */
contract MagicETH is ERC20("Magic insecure ETH", "mETH") {
    
    /**
     * @notice Deposit ether to get wrapped ether
     */
    function deposit() public payable {
        _mint(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw, burn Magic Ether to get Ether
     */
    function withdraw(uint256 amount) external {
        // _value is the amount of ether to withdraw
        uint256 _value = address(this).balance * amount / totalSupply();

        _burn(msg.sender, amount);

        (bool success,) = msg.sender.call{value: _value}("");
        require(success, "ETH transfer failed");
    }

    /**
     * @dev Burn Magic Ether
     */
    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(msg.sender, account);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");

        // decrease allowance
        _approve(account, msg.sender, currentAllowance - amount);

        // burn
        _burn(account, amount);
    }
}