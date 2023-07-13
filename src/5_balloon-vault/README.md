## **Challenge 5: Balloon Vault** 🎈🎈

A ERC4626 vault known as the "Balloon Vault" has been built to gather WETH and invest it on multiple strategies. This vault was thought to be impenetrable, designed meticulously to maintain the security and integrity of the tokens stored within.

The process was straightforward: individuals deposited their digital assets into the Balloon Vault, receiving shares in return. These shares represented their holdings and served as a way to track their savings. 

Two users of the vault, Alice and Bob, have fallen prey to a potential security vulnerability, jeopardizing their significant holdings of 500 WETH each. Protocol try to reach them with no luck...

You have been summoned by the custodians of the Balloon Vault, challenged to assess and exploit the lurking vulnerability, and drain the wallets of Alice and Bob before a bad actor do it. By successfully accomplishing this, you rescue 1000 WETH from Alice & Bob.

📌 Drain *Bob's wallet* and *Alice's wallet*

📌 End up with more than `1000 ETH` in your wallet

<details>
<summary>🗒️ <i>Concepts you should be familiar with (spoilers!)</i></summary>
    <ul>
    <li><i>
        Take a look to this <a href="https://www.youtube.com/watch?v=pd8sMeozdf0">video from Defi Security Summit 2022</a> and this incident <a href="https://medium.com/zengo/without-permit-multichains-exploit-explained-8417e8c1639b">multichain incident</a>.</i></li>
    <li><i><a href=https://ethereum.org/es/developers/docs/standards/tokens/erc-4626>The ERC4626 tokenized vault standard</a>.</i></li>
        <li><i>You may also need to know some attacks showed on this <a href="https://www.youtube.com/watch?v=_pO2jDgL0XE">Spearbit presentation</i></li>
    </ul>
</details>


-------------
**The contracts that you will hack are**:

- **[`Vault.sol`](./Vault.sol)**

**Which have interactions with the following contracts:**

- **[`WETH.sol`](./WETH.sol)**

**The test script where you will have to write your solution is**:

- **[`Challenge5.t.sol`](../../test/Challenge5.t.sol)**

-------------
