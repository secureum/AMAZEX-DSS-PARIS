// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {USDC} from "./USDC.sol";

/**
 * @title IPool
 * @dev IPool is an interface for interacting with lending pool contracts
 */
interface IPool {
    function name() external view returns (string memory);
    function deposit() external;
    function withdraw(uint256 _amount) external;
    function getBalance(address _account) external view returns (uint256);
    function emergencyStop() external;
}

/**
 * @title LendExGovernor
 */
contract LendExGovernor is Ownable {

    mapping(address => bool) public acceptedContracts;
    USDC public usdc;

    event ContractAdded(address contractAddress);
    event ContractRemoved(address contractAddress);

    /**
     * @param _usdc The address of the USDC contract to use
     */
    constructor(address _usdc) {
        _transferOwnership(msg.sender);
        usdc = USDC(_usdc);
    }

    /**
     * @param _contractAddress The address of the contract to check
     */
    modifier onlyValidAddress(address _contractAddress) {
        require(acceptedContracts[_contractAddress], "Contract address is not currently accepted");
        _;
    }

    /**
     * @dev Adds a contract address to the whitelist
     * @param _contractAddress The address of the contract to add to the whitelist
     */
    function addContract(address _contractAddress) public onlyOwner {
        require(!acceptedContracts[_contractAddress], "Contract address is already accepted");
        acceptedContracts[_contractAddress] = true;

        emit ContractAdded(_contractAddress);
    }

    /**
     * @dev Removes a contract address from the whitelist
     * @param _contractAddress The address of the contract to remove from the whitelist
     */
    function removeContract(address _contractAddress) public onlyOwner {
        require(acceptedContracts[_contractAddress], "Contract address is not currently accepted");
        acceptedContracts[_contractAddress] = false;

        emit ContractRemoved(_contractAddress);
    }

    /**
     * @dev Returns the name of a pool
     * @param _contractAddress The address of the pool contract
     * @return The name of the pool
     */
    function getPoolName(address _contractAddress)
        public
        view
        onlyValidAddress(_contractAddress)
        returns (string memory)
    {
        return IPool(_contractAddress).name();
    }

    /**
     * @dev Deposits funds into a pool
     * @param _contractAddress The address of the pool contract
     * @param _amount The amount of funds to deposit
     */
    function fundLendingPool(address _contractAddress, uint256 _amount)
        public
        onlyOwner
        onlyValidAddress(_contractAddress)
    {
        usdc.transfer(_contractAddress, _amount);
    }

    /**
     * @dev withdraws funds from a pool
     * @param _contractAddress The address of the pool contract
     * @param _amount The amount of funds to withdraw
     */
    function withdrawFromLendingPool(address _contractAddress, uint256 _amount)
        public
        onlyOwner
        onlyValidAddress(_contractAddress)
    {
        IPool(_contractAddress).withdraw(_amount);
    }
}
