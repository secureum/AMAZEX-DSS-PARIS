// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LendingPool} from "./LendingPool.sol";
import {LendingHack} from "./LendingHack.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CreateDeployer
 */
contract CreateDeployer is Ownable {

    /**
     * @dev Constructor that sets the owner of the contract
     * @param _owner The address of the owner of the contract
     */
    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    /**
     * @dev Deploys a LendingPool or LendingHack contract
     * @param deployPool Whether to deploy a LendingPool or LendingHack contract
     * @param _usdc The address of the USDC contract to use for the LendingPool or LendingHack contracts
     */
    function deploy(bool deployPool, address _usdc) public onlyOwner returns (address contractAddress) {
        if (deployPool) {
            contractAddress = address(new LendingPool(owner(), _usdc));
        } else {
            contractAddress = address(new LendingHack(owner(), _usdc));
        }
    }


    function cleanUp() public onlyOwner {
        selfdestruct(payable(address(0)));
    }
}
