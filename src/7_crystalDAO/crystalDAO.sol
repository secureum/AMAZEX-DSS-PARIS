// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Initializable} from "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {EIP712Upgradeable} from "@openzeppelin-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol";

/**
 * @title DaoVault interface.
 */
interface IDaoVault {
    /**
     * @dev Executes an order.
     * @param v v component of the signature.
     * @param r r component of the signature.
     * @param s s component of the signature.
     * @param target Address of the contract to be called.
     * @param val Value to be sent to the contract.
     * @param execOrder Encoded order to be executed.
     * @param deadline Deadline for the order to be executed.
     */
    function execWithSignature(
        uint8 v,
        bytes32 r,
        bytes32 s,
        address target,
        uint256 val,
        bytes memory execOrder,
        uint256 deadline
    ) external payable;

    /**
     * @dev Returns the domain separator.
     * @return bytes32 Domain separator.
     */
    function getDomainSeparator() external view returns (bytes32);
}

/**
 * @title DaoVaultImplementation.
 * @dev Implementation of a vault for DAOs.
 * @dev This contract is meant to be used via proxy by a `DaoVault` contract.
 */
contract DaoVaultImplementation is Initializable, EIP712Upgradeable {
    // Owner of the vault
    address public owner;

    // Mapping of used signatures
    mapping(bytes32 => bool) private usedSigs;
    mapping(address => uint256) public nonces;

    // _EXEC_TYPEHASH
    bytes32 private constant _EXEC_TYPEHASH =
        keccak256("Exec(address target,uint256 value,bytes memory execOrder,uint256 nonce,uint256 deadline)");

    constructor() {
        // disable owner
        owner = msg.sender;
        _disableInitializers();
    }

    /**
     * @dev Initializes the vault.
     * @param _owner Owner of the vault.
     */
    function initialize(address _owner) public initializer {
        // EIP712 init: name DaoWallet, version 1.0
        __EIP712_init("DaoWallet", "1.0");

        // postInit: set owner with gas optimizations
        assembly {
            sstore(0, _owner)
        }
        
    }

    /**
     * @dev Returns the domain separator.
     * @return bytes32 Domain separator.
     */
    function getDomainSeparator() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev Executes a transaction from the vault.
     * @param target Address of the contract to execute the transaction on.
     * @param val Value to send with the transaction.
     * @param execOrder Encoded transaction to execute.
     */
    function execWithSignature(
        uint8 v,
        bytes32 r,
        bytes32 s,
        address target,
        uint256 val,
        bytes memory execOrder,
        uint256 deadline
    ) external payable {
        require(deadline > block.timestamp, "Execution window expired!");

        // Construct the message struct
        bytes32 structHash = keccak256(abi.encode(_EXEC_TYPEHASH, target, val, execOrder, nonces[owner]++, deadline));

        // Hash the struct and add EIP712 prefix
        bytes32 hash = _hashTypedDataV4(structHash);

        // Recover signer from signature
        address signer = ecrecover(hash, v, r, s);

        require(owner == signer, "Only owner can execute!");
        require(!usedSigs[hash], "Signature has already been used!");

        // Mark signature as used
        usedSigs[hash] = true;

        // Execute transaction
        (bool success, bytes memory data) = target.call{value: val}(execOrder);
        require(success, string(data));
    }

    receive() external payable {
        // donations come here
    }
}

/**
 * @title FactoryDao.
 * @dev Factory contract for DaoVaults.
 */
contract FactoryDao {
    // Address of the implementation contract
    address payable public immutable walletImplementation;

    constructor() {
        // Deploy implementation contract
        walletImplementation = payable(address(new DaoVaultImplementation()));
    }

    /**
     * @dev Creates a new wallet.
     * @return wallet Address of the new wallet.
     */
    function newWallet() public returns (address payable wallet) {
        // Deploy clone
        wallet = payable(Clones.clone(walletImplementation));
        // Initialize clone
        DaoVaultImplementation(wallet).initialize(msg.sender);
    }
}
