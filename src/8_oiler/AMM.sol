// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AMM
 * @notice ASSUME THIS CONTRACT DOES NOT HAVE TECHNICAL VULNERABILITIES. 
 * Modified from: https://solidity-by-example.org/defi/constant-product-amm/
 */
contract AMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    /**
     * @dev Constructor that sets the addresses of the two tokens in the AMM
     * @param _token0 The address of the first token
     * @param _token1 The address of the second token
     */
    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    /**
     * @dev Mint new shares
     * @param _to The address to mint the shares to
     * @param _amount The amount of shares to mint
     * @notice This function is an utility function used by other functions in the contract
     */
    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    /**
     * @dev Burn shares
     * @param _from The address to burn the shares from
     * @param _amount The amount of shares to burn
     */
    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    /**
     * @dev Update the reserves of the AMM
     * @param _reserve0 The new reserve of the first token
     * @param _reserve1 The new reserve of the second token
     */
    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    /**
     * @dev Swap tokens
     * @param _tokenIn The address of the token to swap in
     * @param _amountIn The amount of tokens to swap in
     */
    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");
        require(_amountIn > 0, "amount in = 0");

        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) =
            isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        uint256 amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        tokenOut.transfer(msg.sender, amountOut);

        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    /**
     * @dev Add liquidity to the AMM
     * @param _amount0 The amount of the first token to add
     * @param _amount1 The amount of the second token to add
     */
    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "x / y != dx / dy");
        }

        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min((_amount0 * totalSupply) / reserve0, (_amount1 * totalSupply) / reserve1);
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    /**
     * @dev Remove liquidity from the AMM
     * @param _shares The amount of shares to remove
     */
    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        // bal0 >= reserve0
        // bal1 >= reserve1
        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        amount0 = (_shares * bal0) / totalSupply;
        amount1 = (_shares * bal1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(msg.sender, _shares);
        _update(bal0 - amount0, bal1 - amount1);

        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }

    /**
     * @dev Calculate the square root of a number
     * @param y The number to calculate the square root of
     */
    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev Calculate the minimum of two numbers
     * @param x The first number
     * @param y The second number
     */
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    /**
     * @dev Get the price of the first token
     * @return The price of the first token
     */
    function getPriceToken0() public view returns (uint256) {
        return (reserve1 * 1e18) / reserve0;
    }

    /**
     * @dev Get the price of the second token
     * @return The price of the second token
     */
    function getPriceToken1() public view returns (uint256) {
        return (reserve0 * 1e18) / reserve1;
    }
}
