// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC3156FlashLender, IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";

/**
 * @title SecureumToken
 */
contract SecureumToken is ERC20("Secureum Token", "ST") {
    constructor(uint256 amount) {
        _mint(msg.sender, amount);
    }
}

/**
 * @title YieldPool
 */
contract YieldPool is ERC20("Safe Yield Pool", "syLP"), IERC3156FlashLender {
    // The token address
    IERC20 public immutable TOKEN;
    // An arbitrary address to represent Ether 
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    // A constant to indicate a successful callback, according to ERC3156
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    /**
     * @dev Initializes the pool with the token address
     * @param _token The address of the token contract
     */
    constructor(IERC20 _token) {
        TOKEN = _token;
    }

    //////// ERC3156 interface functions

    /// @inheritdoc IERC3156FlashLender
    function maxFlashLoan(address token) public view returns (uint256) {
        if (token == ETH) {
            return address(this).balance;
        } else if (token == address(TOKEN)) {
            return getReserve();
        }
        revert("Unknown token");
    }

    /**
    * @notice The fee is 1%
    * @inheritdoc IERC3156FlashLender
    */
    function flashFee(address, uint256 amount) public pure returns (uint256) {
        return amount / 100;
    }

    /// @inheritdoc IERC3156FlashLender
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data)
        external
        returns (bool)
    {
        require(amount <= maxFlashLoan(token), "not enough currency");

        uint256 expected;
        if (token == ETH) {
            expected = address(this).balance + flashFee(token, amount);
            (bool success,) = address(receiver).call{value: amount}("");
            require(success, "ETH transfer failed");
            success = false;
        } else if (token == address(TOKEN)) {
            expected = getReserve() + flashFee(token, amount);
            require(TOKEN.transfer(address(receiver), amount), "Token transfer failed");
        } else {
            revert("Wrong token");
        }

        require(
            receiver.onFlashLoan(msg.sender, token, amount, flashFee(token, amount), data) == CALLBACK_SUCCESS,
            "Invalid callback return value"
        );

        if (token == ETH) {
            require(address(this).balance >= expected, "Flash loan not repayed");
        }
        else {
            require(getReserve() >= expected, "Flash loan not repayed");
        }
        return true;
    }

    // custom functions
    /**
     * @dev Preview the amount of TOKEN in the liquidity pool
     * @return Amount of TOKEN in the protocol
     */
    function getReserve() public view returns (uint256) {
        return TOKEN.balanceOf(address(this));
    }

    /**
     * @dev Add liquidity, which allows earning fees
     * @param _amount The (maximum) amount of TOKEN that shall be provided as liquidity
     * @notice The actual amount of transferred TOKEN is based on the amount of ETH sent along
     * @return Amount of liquidity tokens which represent the users share of the pool
     */
    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        uint256 liquidity;
        uint256 ethBalance = address(this).balance;
        uint256 tokenReserve = getReserve();

        if (tokenReserve == 0) {
            TOKEN.transferFrom(msg.sender, address(this), _amount);

            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint256 ethReserve = ethBalance - msg.value;

            uint256 tokenAmount = (msg.value * tokenReserve) / (ethReserve);
            require(_amount >= tokenAmount, "Amount of tokens sent is less than the minimum tokens required");

            TOKEN.transferFrom(msg.sender, address(this), tokenAmount);

            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    /**
     * @dev Removes liquidity which has been provided before
     * @param _amount Amount of liquidity tokens to be turned in
     * @return Amount of (ETH, TOKEN) which have been returned
     */
    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(_amount > 0, "_amount should be greater than zero");
        uint256 ethReserve = address(this).balance;
        uint256 _totalSupply = totalSupply();
        uint256 ethAmount = (ethReserve * _amount) / _totalSupply;
        uint256 tokenAmount = (getReserve() * _amount) / _totalSupply;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        TOKEN.transfer(msg.sender, tokenAmount);
        return (ethAmount, tokenAmount);
    }

    /**
     * @dev Calculates the swap output amount based on reserves. Used to preview amount of TOKEN or ETH to be bought before execution
     * @param _inputAmount Amount of input tokens (which should be sold)
     * @param _inputReserve Amount of input reserves in the protocol
     * @param _outputReserve Amount of output reserves in the protocol
     * @return Amount of output tokens (which would be bought)
     */
    function getAmountOfTokens(uint256 _inputAmount, uint256 _inputReserve, uint256 _outputReserve)
        public
        pure
        returns (uint256)
    {
        require(_inputReserve > 0 && _outputReserve > 0, "invalid reserves");
        uint256 inputAmountWithFee = _inputAmount * 99;
        uint256 numerator = inputAmountWithFee * _outputReserve;
        uint256 denominator = (_inputReserve * 100) + inputAmountWithFee;
        return numerator / denominator;
    }

    /**
     * @dev Swap ETH to TOKEN
     * @notice Provided ETH will be sold for TOKEN
     */
    function ethToToken() public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value, tokenReserve);

        TOKEN.transfer(msg.sender, tokensBought);
    }

    /**
     * @dev Swap TOKEN to ETH
     * @param _tokensSold The amount of TOKEN that should be sold
     */
    function tokenToEth(uint256 _tokensSold) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmountOfTokens(_tokensSold, tokenReserve, address(this).balance);
        TOKEN.transferFrom(msg.sender, address(this), _tokensSold);
        payable(msg.sender).transfer(ethBought);
    }


    receive() external payable {}
}
