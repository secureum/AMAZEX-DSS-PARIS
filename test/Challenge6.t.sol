// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {YieldPool, SecureumToken, IERC20} from "../src/6_yieldPool/YieldPool.sol";
import {IERC3156FlashLender, IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/

contract AttackerContract is IERC3156FlashBorrower{
    YieldPool public victim;
    address _owner=msg.sender;
    address constant ethToken=0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    event balance_(uint);
    event tokenBalance(uint);
    function executeAttack(address  protocolAddress,address tokenAddress)external payable{
        victim=YieldPool(payable(protocolAddress));
        victim.flashLoan(IERC3156FlashBorrower(address(this)),ethToken, 99,"");

    }
function withdraw()external payable{
    payable(_owner).transfer(address(this).balance);
}

function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){


    // uint bal=IERC20(token).balanceOf(address(this));
    // emit tokenBalance( bal);

    // IERC20(token).approve(address(victim),1);
    // victim.addLiquidity(1);
    // victim.totalSupply();
    // victim.removeLiquidity(10000 ether);
    // emit balance_(address(this).balance);

    // IERC20(token).transfer(address(victim),IERC20(token).balanceOf(address(this)));

    return keccak256("ERC3156FlashBorrower.onFlashLoan");
    
}
// 8319
fallback()external payable{
    // emit balance_(address(this).balance);

}
    
}


/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge6Test is Test {
    SecureumToken public token;
    YieldPool public yieldPool;

    address public attacker = makeAddr("attacker");
    address public owner = makeAddr("owner");

    function setUp() public {
        // setup pool with 10_000 ETH and ST tokens
        uint256 start_liq = 10000 ether;
        vm.deal(address(owner), start_liq);
        vm.prank(owner);
        token = new SecureumToken(start_liq);
        yieldPool = new YieldPool(token);
        vm.prank(owner);
        token.increaseAllowance(address(yieldPool), start_liq);
        vm.prank(owner);
        yieldPool.addLiquidity{value: start_liq}(start_liq);

        // attacker starts with 0.1 ether
        vm.deal(address(attacker), 0.1 ether);
    }


    function testExploitPool() public {
        vm.startPrank(attacker);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge6Test -vvvv //
        ////////////////////////////////////////////////////*/

        AttackerContract zombie=new AttackerContract();
        zombie.executeAttack{value:0.1 ether}(address(yieldPool),address(token));

        // i was able to get 5000 ETH and 10000 Tokens but i was not able to pay back
        


        //==================================================//
        vm.stopPrank();

        // assertGt(address(attacker).balance, 100 ether, "hacker should have more than 100 ether");
    }
}
