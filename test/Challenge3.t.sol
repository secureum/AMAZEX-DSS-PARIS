// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {LendingPool} from "../src/3_lendingPool/LendingPool.sol";
import {Create2Deployer} from "../src/3_lendingPool/Create2Deployer.sol";
import {CreateDeployer} from "../src/3_lendingPool/CreateDeployer.sol";
import {LendingHack} from "../src/3_lendingPool/LendingHack.sol";
import {USDC} from "../src/3_lendingPool/USDC.sol";
import {LendExGovernor} from "../src/3_lendingPool/LendExGovernor.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/



/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge3Test is Test {
    USDC public usdc;
    uint256 public usdcAmount = 100000;
    LendExGovernor public lendExGovernor;
    CreateDeployer public createDeployer;
    Create2Deployer public create2Deployer;

    LendingPool public lendingPool;
    LendingHack public lendingHack;

    address public hacker = makeAddr("hacker");
    address public governanceOwner = makeAddr("governanceOwner");

    function setUp() public {
        /* set up actions */
        usdc = new USDC(usdcAmount);
        usdc.transfer(governanceOwner, usdcAmount);

        /* sending transactions as hacker */
        // deploying the LendingPool contract
        vm.startPrank(hacker);
        create2Deployer = new Create2Deployer();
        createDeployer = CreateDeployer(create2Deployer.deploy());
        lendingPool = LendingPool(createDeployer.deploy(true, address(usdc)));
        vm.stopPrank();

        /* sending transactions as the governance owner */
        // deploying the LendingPool contract
        vm.startPrank(governanceOwner);
        lendExGovernor = new LendExGovernor(address(usdc));
        lendExGovernor.addContract(address(lendingPool));
        usdc.transfer(address(lendExGovernor), usdcAmount);
        // funding the LendingPool contract with USDC
        lendExGovernor.fundLendingPool(address(lendingPool), usdcAmount);
        vm.stopPrank();

        assertEq(
            lendExGovernor.getPoolName(address(lendingPool)),
            "LendingPool V1",
            "lendingPool contract has the original name"
        );
        vm.startPrank(hacker);
        /*//////////////////////////////////////////////////////////////////////
        //                      Add your hack below!                          //
        //                          Hack part #1                              //
        // NOTE!!! Foundry has a bug                                          //
        // anything selfdestruct() related has to be in the setUp() function  //
        //                                                                    //
        // terminal command to run the speciffic test:                        //
        // forge test --match-contract Challenge3Test -vvvv                   //
        //////////////////////////////////////////////////////////////////////*/



    
        //====================================================================//
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(hacker);
        /*//////////////////////////////////////////////////////////////
        //                    Add your hack below!                    //
        //                        Hack part #2                        //
        // Please implement necessary changes also to LendingHack.sol //
        // terminal command to run the specific test:                 //
        // forge test --match-contract Challenge3Test -vvvv           //
        //////////////////////////////////////////////////////////////*/




        //=============================================================//
        vm.stopPrank();

        assertEq(
            lendExGovernor.getPoolName(address(lendingPool)),
            "LendingPool hack",
            "lendingPool contract address now gives a different name"
        );
        assertEq(usdc.balanceOf(hacker), usdcAmount, "Hacker has to steal all the stablecoin tokens");
    }
}
