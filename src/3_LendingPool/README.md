## **Challenge 3: LendEx pool hack** 🤺🃏

In the realm of decentralized finance, where trust is often bestowed upon code, a groundbreaking borrowing and lending platform known as LendEx was created.

Unbeknownst to the LendEx team, a hacker hide a bug in the LendingPool smart contract with a intention to exploit the bug later. LendEx team reviewed smart contract source code, approved it for the usage and deposited the funds from the LendExGovernor contract to the LendingPool contract.

Do you have what it takes to spot how hacker is planning to exploit the LendEx?

📌 You have to fill the shoes of the hacker and execute the exploit by stealing stablecoins from a lending pool.  
📌 Note: Foundry has a bug. If a selfdestruct() is triggered in a test script then it has to be done in the setUp() function and the rest of the code should be in a different function otherwise foundry test script does not see that selfdestruct happened to a contract.
📌 You have to modify LendingHack.sol and setUp(), testExploit() functions for Challenge3.t.sol.

<details>
<summary>🗒️ <i>Concepts you should be familiar with (spoilers!)</i></summary>
    <ul>
    <li><i><a href=https://neptunemutual.com/blog/understanding-tornado-cash-exploit>The TornadoCash Governance Exploit</a>.</i></li>
    <li><i>How to <a href=https://solidity-by-example.org/hacks/deploy-different-contracts-same-address>deploy different contracts on the same address</a>.</i></li>
    </ul>
</details>

---

**The contract that you will hack is**:

- **[`LendingHack.sol`](./LendingHack.sol)**

**Which have interactions with the following contracts:**

- **[`LendExGovernor.sol`](./LendExGovernor.sol)**
- **[`LendingPool.sol`](./LendingPool.sol)**
- **[`Create2Deployer.sol`](./Create2Deployer.sol)**
- **[`CreateDeployer.sol`](./CreateDeployer.sol)**
- **[`USDC.sol`](./USDC.sol)**

**The test script where you will have to write your solution is**:

- **[`Challenge3.t.sol`](../../test/Challenge3.t.sol)**

---
