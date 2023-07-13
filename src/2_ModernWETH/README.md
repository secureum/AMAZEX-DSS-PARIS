## **Challenge 2: Mission Modern WETH: Rescue the Ether** 🧗🧭

In the ever-evolving world of decentralized finance, an ambitious developer took it upon himself to update the well-established WETH9. The result was ModernWETH, a modernized version in Solidity, that rapidly attracted deposits of over 1000 Ether.

However, we've encountered a challenge. Hidden within the code, a potential vulnerability threatens the security of the funds locked within the contract. This situation calls for the dedication and expertise of blockchain security auditors. Are you ready to step up, solve this issue, and play a crucial role in preserving the sanctity of the Ethereum ecosystem? This is the test of our resolve and adaptability, something I've seen in this community time and again.


📌 Starting with **10 ETH**, recover `1000 ETH` from the `ModernWETH` contract.

📌 Recover all `ETH` to avoid further losses from `ModernWETH` contract. Whitehat hacker should end up with **1010 ETH**.

<details>
<summary>🗒️ <i>Concepts you should be familiar with (spoilers!)</i></summary>
    <ul>
    <li><i>The concept of <a href=https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-04-cross-function-reentrancy>cross-function reentrancy</a>.</i></li>
    <li><i>This <a href="https://inspexco.medium.com/cross-contract-reentrancy-attack-402d27a02a15">article</a> could be useful</i></li>
    </ul>
</details>

-------------
**The contracts that you will hack are**:

- **[`ModernWETH.sol`](./ModernWETH.sol)**

**The test script where you will have to write your solution is**:
- **[`Challenge2.t.sol`](../../test/Challenge2.t.sol)**

-------------
