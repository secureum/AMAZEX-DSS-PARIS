// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title VaultFactory
 */
contract VaultFactory {
    // Events
    event Deployed(address indexed addr);

    /**
     * @notice The address of the deployed contract is emitted in the Deployed event
     * @dev Deploys a contract
     * @param code The bytecode of the contract to deploy
     * @param salt The salt to use for the deployment
     * @return addr The address of the deployed contract
     */
    function deploy(bytes memory code, uint256 salt) public returns (address addr) {
        assembly {
            addr := create2(     // Deploys a contract using create2.
                0,               // wei sent with current call
                add(code, 0x20), // Pointer to code, with skip the assembly prefix
                mload(code),     // Length of code
                salt             // The salt used
            )
            if iszero(extcodesize(addr)) { revert(0, 0) } // Check if contract deployed correctly, otherwise revert.
        }
        emit Deployed(addr);
    }

    /**
     * @notice This function is used to call the initialize function of the deployed contract
     * @dev Executes a call to a contract
     * @param addr The address of the contract to call
     * @param data The data to send to the contract
     */
    function callWallet(address addr, bytes memory data) public {
        assembly {
            let result := call(  // Performs a low level call to a contract
                gas(),           // Forward all gas to the call
                addr,            // The address of the contract to call
                0,               // wei passed to the call
                add(data, 0x20), // Pointer to data, with skip the assembly prefix
                mload(data),     // Length of data
                0,               // Pointer to output, we don't use it
                0                // Size of output, we don't use it
            )
            let size := returndatasize() // Get the size of the output
            let ptr := mload(0x40)       // Get a free memory pointer
            returndatacopy(ptr, 0, size) // Copy the output to the pointer
            switch result                 // Check the result:
            case 0 { revert(ptr, size) }  // If failed, revert with the output
            default { return(ptr, size) } // If success, return the output
        }
    }
}
