// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


interface IAMM {
    function getPriceToken0() external returns (uint256);
}

/**
 * @title Oiler
 */
contract Oiler is ERC20 {
    event Deposited(address depositor, uint256 collateralAmount);
    event Borrowed(address borrower, uint256 borrowedAmount);
    event Withdraw(address user, uint256 withdrawAmount);
    event Liquidated(address liquidator, address userLiquidated, uint256 amount);

    IERC20 public immutable token;
    IAMM public immutable amm;

    // Collateral Factor
    uint256 constant CF = 75;
    // 2 decimal points
    uint256 constant DECIMALS = 10 ** 2;
    // Threshold for health factor under which the position becomes eligible for liquidation
    uint256 constant LIQUIDATION_THRESHOLD = 100;

    struct User {
        uint256 collateral;
        uint256 borrow;
        bool liquidated;
    }

    mapping(address => User) public users;


    constructor(address _token, address _amm) ERC20("Debt Token", "dTOKEN") {
        token = IERC20(_token);
        amm = IAMM(_amm);
    }

    /**
     * @notice Deposits an amount of TOKEN into the contract as collateral
     * @dev Before calling this function, the user must have approved the contract to spend the specified amount of TOKEN
     * @param _amount The amount of TOKEN to deposit as collateral and added to the user's collateral balance
     */
    function deposit(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        users[msg.sender].collateral += _amount;

        emit Deposited(msg.sender, _amount);
    }

    /**
     * @notice Withdraws collateral from the contract given an amount of dTOKENs
     * @param _amount The amount of dTOKENs the user wants to burn in order to withdraw collateral
     */
    function withdraw(uint256 _amount) public {
        require(users[msg.sender].borrow >= _amount, "ERR: Withdraw > borrow");
        uint256 collateralToWithdraw = (_amount * users[msg.sender].collateral) / users[msg.sender].borrow;
        users[msg.sender].collateral -= collateralToWithdraw;
        users[msg.sender].borrow -= _amount;
        _burn(msg.sender, _amount);
        token.transfer(msg.sender, collateralToWithdraw);

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice Borrow desired amount of dTOKENs
     * @dev Must have enough collateral to borrow the desired amount of dTOKENs
     * @param  _amount The amount of dTOKENs to borrow
     */
    function borrow(uint256 _amount) public {
        uint256 maxBorrowAmount = maxBorrow(msg.sender);
        require(maxBorrowAmount >= _amount * DECIMALS, "ERR: Not Enough Collateral");
        _mint(msg.sender, _amount);
        users[msg.sender].borrow += _amount;

        emit Borrowed(msg.sender, _amount);
    }

    /**
     * @notice Calculate the health factor for a user's position
     * @dev If the user hasn't borrowed any tokens, it returns the maximum possible value
     * @param _user The address of the user
     * @return The health factor for the user. The value includes two decimal places
     */
    function healthFactor(address _user) public returns (uint256) {
        if (users[_user].borrow == 0) {
            // User has not borrowed any tokens, so health is theoretically infinite
            return type(uint256).max;
        }
        uint256 collateralValue = users[_user].collateral * getPriceToken();
        uint256 borrowValue = users[_user].borrow;
        uint256 hf = collateralValue * CF / borrowValue;
        // Includes 2 decimals
        return hf;
    }

    /**
     * @notice Fetch the price of the collateral token from the AMM pair oracle
     * @dev The price returned is denominated in 18 decimals
     * @return The price of the token in terms of the other token in the pair
     */
    function getPriceToken() public returns (uint256) {
        return amm.getPriceToken0();
    }

    /**
     * @notice Calculates the maximum amount of dTOKENs that a user can borrow, based on the value of their deposited collateral
     * @dev 2 decimal points precision. e.g., if result is 0.75 the function returns 75
     * @param _user Address of the user
     * @return The maximum amount of dTOKENs that the user can borrow
     */
    function maxBorrow(address _user) public returns (uint256) {
        return (users[_user].collateral * getPriceToken() * CF * DECIMALS / 100) - (users[msg.sender].borrow * DECIMALS);
    }

    /**
     * @notice Fetches the data of a specific user
     * @dev Returns a struct containing the user's collateral, borrowed amount and status
     * @param _user Address of the user
     * @return A struct containing the user's collateral and borrowed amount
     */
    function getUserData(address _user) public view returns (User memory) {
        return users[_user];
    }

    /**
     * @notice  Liquidates a user's position if their health factor falls below the liquidation threshold.
     * @param   _user The address of the user to liquidate.
     *  The process of liquidation involves repaying a portion of the user's debt,
     *  burning debt tokens from the liquidator, and transferring all of 
     *  the user's collateral to the liquidator.
     *  The user's borrow amount and collateral are then updated.
     */
    function liquidate(address _user) public {
        uint256 positionHealth = healthFactor(_user) / 10 ** 18;
        require(positionHealth < LIQUIDATION_THRESHOLD, "Liquidate: User not underwater");
        uint256 repayment = users[_user].borrow * 5 / 100;
        _burn(msg.sender, repayment);
        users[_user].borrow -= repayment;
        uint256 totalCollateralAmount = users[_user].collateral;
        token.transfer(msg.sender, totalCollateralAmount);
        users[_user].collateral = 0;
        users[_user].liquidated = true;

        emit Liquidated(msg.sender, _user, repayment);
    }
}
