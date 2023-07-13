// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title VaultWalletTemplate
 * @dev This contract is a template for a safe wallet that can be used to store ERC20 tokens and ETH
 * @notice The owner must initialize the wallet with his address for it to work
 * @notice The owner can withdraw any ERC20 token or ETH from the wallet
 * @notice The owner can change the owner of the wallet
 */
contract VaultWalletTemplate is ReentrancyGuard {
    // The owner of the wallet
    address public owner;
    // Bool that controls whether the wallet is initialized
    bool public initialized;

    // Events
    event ERC20Withdrawn(address indexed token, uint256 amount, address destination);
    event ETHWithdrawn(uint256 amount, address destination);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ETHReceived(address indexed sender, uint256 amount);
    event IsInitialized(address indexed whoDidIt);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier isInitialized() {
        require(initialized, "Wallet is not initialized yet");
        _;
    }

    /**
     * @notice This function can only be called once
     * @dev Initializes the wallet with the owner address
     * @param _owner The address of the owner
     */
    function initialize(address _owner) external {
        require(!initialized, "Wallet is already initialized");
        owner = _owner;
        initialized = true;
        emit OwnershipTransferred(address(0), _owner);
        emit IsInitialized(msg.sender);
    }

    /**
     * @notice The new owner cannot be the zero address
     * @notice The wallet must be initialized
     * @dev Changes the owner of the wallet
     * @param _owner The address of the new owner
     * @notice Only the owner can call this function
     */
    function changeOwner(address _owner) public isInitialized onlyOwner {
        require(_owner != address(0), "New owner cannot be zero address");
        owner = _owner;
        emit OwnershipTransferred(msg.sender, _owner);
    }

    /**
     * @notice Only the owner can call this function
     * @notice The wallet must be initialized
     * @dev Withdraws an ERC20 token from the wallet
     * @param token The address of the ERC20 token
     * @param _amount The amount of the ERC20 token to withdraw
     * @param destination The address to send the ERC20 token to
     */
    function withdrawERC20(address token, uint256 _amount, address destination)
        public
        isInitialized
        nonReentrant
        onlyOwner
    {
        IERC20 TOKEN = IERC20(token);
        require(TOKEN.balanceOf(address(this)) >= _amount, "Insufficient Token balance");
        TOKEN.transfer(destination, _amount);
        emit ERC20Withdrawn(token, _amount, destination);
    }

    /**
     * @notice Only the owner can call this function
     * @notice The wallet must be initialized
     * @dev Withdraws ETH from the wallet
     * @param destination The address to send the ETH to
     * @param _amount The amount of ETH to withdraw
     */
    function withdrawETH(address payable destination, uint256 _amount) public isInitialized nonReentrant onlyOwner {
        require(address(this).balance >= _amount, "Insufficient ETH balance");
        (bool success,) = destination.call{value: _amount}("");
        require(success, "Failed to send Ether");
        emit ETHWithdrawn(_amount, destination);
    }

    receive() external payable {
        emit ETHReceived(msg.sender, msg.value);
    }

    fallback() external payable {
        emit ETHReceived(msg.sender, msg.value);
    }
}
