// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20, IERC20Permit, ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

/**
 * @title BallonVault
 */
contract BallonVault is ERC4626 {

    /**
     * @dev Constructor that sets the address of the underlying asset of the Vault (an ERC20 token)
     * @param underlying The address of the underlying asset
     */
    constructor(address underlying) ERC20("BallonVault", "E4626B") ERC4626(ERC20(underlying)) {}

    /**
     * @dev Deposit ERC20 tokens into the Vault
     * @param from The address to deposit the ERC20 tokens from
     * @param amount The amount of ERC20 tokens to deposit
     * @param deadline The deadline for the deposit to be made
     * @param v The v value of the signature
     * @param r The r value of the signature
     * @param s The s value of the signature
     */
    function depositWithPermit(address from, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
    {
        IERC20Permit(address(asset())).permit(from, address(this), amount, deadline, v, r, s);

        _deposit(from, from, amount, previewDeposit(amount));
    }
}
