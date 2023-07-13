// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {CreateDeployer} from "./CreateDeployer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Create2Deployer
 */
contract Create2Deployer is Ownable {
    /**
     * @dev Constructor that sets the owner of the contract as the deployer
     */
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Deploys a CreateDeployer contract using the CREATE2 opcode
     */
    function deploy() external returns (address) {
        bytes32 salt = keccak256(abi.encode(uint256(1)));
        return address(new CreateDeployer{salt: salt}(owner()));
    }
}
