## **Challenge 8: Liquidatoooor** 🔱🔱

The favorite lending protocol in town has opened its doors and is allowing anyone to deposit collateral to borrow debt tokens! The Risk analysis department assures the protocol is sound as a Swiss banking system, and the Tokenomic analysis team argues that if a user's position becomes under-collateralized, the liquidator must receive all of the users collateral as a reward for keeping the protocol vault from bad debt, while punishing the borrower for not managing his positions accordingly!

As users start opening debt positions, you notice something unusual in the way that the protocol calculates user account health... something is off here... and it seems that the consequences can result in user positions being liquidated by the attacker who will also make a profit out of it!

Can you demonstrate the viability of this attack to convince the Risk and Tokenomic departments to urgently update the protocol?

📌 Drop the borrower's health account.

📌 Liquidate the borrower and get as much of his collateral as possible.


<details>
<summary>🗒️ <i>Concepts you should be familiar with (spoilers!)</i></summary>
    <ul>
    <li><i><a href=https://docs.aave.com/risk/asset-risk/risk-parameters#health-factor>General understanding of Health Factor, Collateral Factor and Liquidation Threshold</a>.</i></li>
    <li><i><a href=https://extropy-io.medium.com/price-oracle-manipulation-d46fd413cc17>AMM spot price manipulation</a>.</i></li>
    </ul>
</details>

-------------

**The contract that you will hack is**:

- **[`Oiler.sol`](./Oiler.sol)**

**The test script where you will have to write your solution is**:

- **[`Challenge8.t.sol`](../../test/Challenge8.t.sol)**

-------------
