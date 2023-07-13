// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {USDC} from "./USDC.sol";

/**
 * @title LendingPool
 */
contract LendingPool is Ownable {
    mapping(address => uint256) public balances;
    USDC public usdc;
    string public constant name = "LendingPool V1";

    event Deposit(address account, uint256 amount);
    event Withdraw(address account, uint256 amount);

    /**
     * @dev Constructor that sets the owner of the contract
     * @param _owner The address of the owner of the contract
     * @param _usdc The address of the USDC contract to use
     */
    constructor(address _owner, address _usdc) {
        _transferOwnership(_owner);
        usdc = USDC(_usdc);
    }

    /**
     * @dev Deposit USDC into the LendingPool
     * @param _amount The amount of USDC to deposit
     */
    function deposit(uint256 _amount) public {
        address _owner = msg.sender;

        require(_amount > 0, "Deposit amount must be greater than zero");

        balances[_owner] += _amount;
        usdc.transferFrom(_owner, address(this), _amount);

        emit Deposit(_owner, _amount);
    }

    /**
     * @dev Withdraw USDC from the LendingPool
     * @param _amount The amount of USDC to withdraw
     */
    function withdraw(uint256 _amount) public {
        address _owner = msg.sender;

        require(_amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[_owner] >= _amount, "Insufficient balance");

        balances[_owner] -= _amount;
        usdc.transfer(_owner, _amount);

        emit Withdraw(_owner, _amount);
    }

    /**
     * @dev Returns the balance of the given account
     * @param _account The address of the account to check
     * @return The balance of the account
     */
    function getBalance(address _account) public view returns (uint256) {
        return balances[_account];
    }

    /**
     * @dev Stops the pool from functioning
     */
    function emergencyStop() public onlyOwner {
        selfdestruct(payable(0));
    }
}
