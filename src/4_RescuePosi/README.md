## **Challenge 4: Operation Rescue `POSI` Token!** 💼🔓

Hello whitehat! We are so thankful for your answer to our cry for help! Time is running out... There is a huge amount of tokens sitting on an address that we can't access. We need your help to rescue them!

For context, we have to transfer a big big amount of these tokens to a very important organization before a deadline. Unfortunately, we made a typo in the destination address (plus we didn't check the checksummed version of the address) and now the tokens are stuck in an address that doesn't belong to anyone.

However, we noticed that the address where our funds are stuck is coincidentally the same address as one of the vaults we develop but in another EVM chain... The address of the vault is `0x70E194050d9c9c949b3061CC7cF89dF9c6782b7F`, which was deployed by our vault-factory. The EOA who triggered that deploy, `0x6F77cf861457C29aCAFB6c7340Aee8fbcE84dD08` belongs to an old employee that left the company a long time ago, and we don't have access to the corresponding private key... There is little information left about this employee, we don't even know if he is still alive. The only thing that we know is that he used to work with us in the past, that his birthday was in November and that he was a big fan of the `CREATE2` opcode. What a silly guy... 

Anyways, please whitehat make use of your skills to rescue the tokens and transfer them to the address of our organization!

📌 Extract the 1000 `POSI` tokens from the Vault.

📌 Transfer the rescued tokens to the address of the organization.

**_Initial context_**

- You will be in control of the `whitehat` address.
- The `whitehat` address has an initial balance of `10 ether`.

<details>
<summary>🗒️ <i>Concepts you should be familiar with (spoilers!)</i></summary>
    <ul>
    <li><i><a href=https://docs.alchemy.com/docs/create2-an-alternative-to-deriving-contract-addresses>Deterministic addresses and `CREATE2`</a>.</i></li>
    <li><i><a href=https://medium.com/coinmonks/solidity-who-the-heck-is-msg-sender-de68d3e98454>`msg.sender` under different contexts</a>.</i></li>
    </ul>
</details>

-------------
**The contracts that you will hack are**:

- **[`myVaultFactory.sol`](./myVaultFactory.sol)**

**Which have interactions with the following contracts:**

- **[`myVaultWalletTemplate.sol`](./myVaultWalletTemplate.sol)**

**The test script where you will have to write your solution is**:

- **[`Challenge4.t.sol`](../../test/Challenge4.t.sol)**

-------------
