## **Challenge 7: Crystal DAO** 💎💎

The Crystal DAO is a transparent and non-profit DAO whose mission is to gather funds to support the development of different public goods in the Ethereum ecosystem. These funds are stored in custom treasury contracts that follow the ERC1176 minimal proxy standard, and are controlled by one DAO admin.

One of such treasuries was recently deployed, and has reached the target amount of 100 ETH in its balance. Therefore, the DAO admin has tried to retrieve the funds for their subsequent donations. However, the admin's signature is not being recognized by the treasury clone contract, and the funds are now stuck, putting the DAO's reputation at risk.

Can you help the DAO admin to retrieve the funds?

📌 Rescue `100 ETH` from the DAO treasury.

**_Initial context_**

- You will be in control of the `whitehat` address.
- The `whitehat` address has an initial balance of `0 ether`.

<details>
<summary>🗒️ <i>Concepts you should be familiar with (spoilers!)</i></summary>
    <ul>
    <li><i><a href=https://coinsbench.com/minimal-proxy-contracts-eip-1167-9417abf973e3>ERC1167 Minimal Proxy Contract</a>.</i></li>
    <li><i><a href=https://medium.com/metamask/eip712-is-coming-what-to-expect-and-how-to-use-it-bb92fd1a7a26>EIP712 Signatures</a>.</i></li>
    <li><i><a href=https://soliditydeveloper.com/ecrecover>The `ecrecover()` function</a>.</i></li>
    </ul>
</details>


-------------
**The contracts that you will hack are**:

- **[`crystalDAO.sol`](./crystalDAO.sol)**

**The test script where you will have to write your solution is**:

- **[`Challenge7.t.sol`](../../test/Challenge7.t.sol)**

-------------
