# SYSCOIN LUX MASTERNODE SCRIPT

![Sycoin Logo Scifi](https://github.com/syscoin/Masternode-Install-Script/blob/master/img/syscoin-logo.jpg)

---

## Below are the minimum requirements for your VPS. Please do not try to compile without the minimum. You must install on a fresh new VPS.
- 64-bit CPU — 2 Cores (4 preferred)
- 4gb RAM (real) minimum (8gb RAM preferred)
- 4gb swap (if less than 8gb real RAM) Will need to use SSD if using Swap
- KVM or OpenVZ (KVM preferred)
- Linux OS — Minimum Ubuntu 18.04, LTS Ubuntu 20.04 LTS (Focal Fossa) preferred.
- 80gb Disk Space (100gb+ SSD preferred).

> **If using an existing address with seniority you will have to manually ‘lock’ the collateral. Do this via Coin Control - right click your 100k tx and click "Lock Unspent". You do not need to make a new transaction. Doing so will lose your Seniority. If setting up a Masternode with a seniority address you can skip to generating your BLS KEYS.**
> 

## Video Walkthrough
[Masternode Install Guide](https://www.youtube.com/watch?v=pOwcFMP92hY)

## VPS Providers

There are many VPS service providers that offer and exceed the hardware requirements, as such it is recommended that you shop around and do your own homework on various potential providers. Note the following is a list of just some examples and should not be interpreted as recommendations or endorsement.

- [UK2.net](https://UK2.net)
- [IONOS.co.uk](https://IONOS.co.uk)
- [InterServer.net](https://InterServer.net)
- [OVH.co.uk](https://OVH.co.uk)
- [KimSufi.com](https://KimSufi.com)
- [mVPS.net](https://mVPS.net)
- [VPS-Mart.com](https://VPS-Mart.com)
- [Hostinger.com](https://Hostinger.com)
- [BudgetVM.com](https://BudgetVM.com)
- [Virtono.com](https://Virtono.com)
- [LeaseWeb.com](https://LeaseWeb.com)
- [HomeAtCloud.com](https://HomeAtCloud.com)
- [IdeaStack.com](https://IdeaStack.com)
- [SSDNodes.com](https://SSDNodes.com)
- [SimplyHosting.com](https://SimplyHosting.com)
- [RAMNode.com](https://RAMNode.com)
- [Time4VPS.com](https://Time4VPS.com)

## MASTERNODE HELP
[SysHub](https://syshub.org): Register your masternodes with Syshub. You can also create Proposals through the generator for Governance and Vote on upcoming Proposals.

[Syscoin Discord](https://discord.gg/RkK2AXD): If you require more help, jump into the Syscoin Discord and our community will be more than happy to help you out!

[Sysnode.info](https://sysnode.info): This website has an array of tools such as Masternode Stats, Monitoring and keeping up to date with current news with Syscoin.

---

## Prepare QT and Send 100k Syscoin

To stake your Masternode you will need to provide exactly **100,000 SYS** in your Masternode address. Use Syscoin Core Qt for your system to process this transaction.  

Create a new address for collateral this does not need to be a legacy address anymore, or you can use an existing seniority address. 
If you are using an existing Seniority Address you do not have to make a new transaction or create a new address. 

```getnewaddress mn1```

Send exactly **100,000 Syscoin** to this address.

## Identify 100k Syscoin Transaction

- Click Window>Console and enter the following command: 
Note some commands now require an underscore

```masternode_outputs```

This should return a string of characters similar to the following:

```
{
  "3304a4920f20e1e5cd1f34e5396556ded1e603296f7c5dd66c7ec4fe63cb008d": "0"
}
```

The first long string is your collateralHash, while the last number is the collateralIndex.

## Generate BLS Key Pair

> **NOTE: YOU MUST CREATE A BLS KEY PAIR FOR EVERY NODE**
> 

A public/secret BLS key pair is required to operate a masternode. The secret key is specified on the masternode itself, and allows it to be included in the deterministic masternode list once a provider registration transaction with the corresponding public key has been created.

If you are using a hosting service, they may provide you with their public key, and you can skip this step. If you are hosting your own masternode or have agreed to provide your host with the BLS secret key, generate a BLS public/secret keypair in the Console and entering the following command:

> These keys are NOT stored by the wallet and must be kept secure, similar to the value provided in the past by the masternode genkey command.
> 

```bls_generate```

```
{
  "secret": "1a8f477d2b02650b7d159efe315940f05252334eb292376309386cc99b0c4ec7",
  "public": "05afc5f75d0a215951677703e41a108a67f2efb31110e392d988dbd4f9e8446a3336d59de1ff886ec0d3c65c822af2de"
}
```

## Configure Masternode on VPS

Finally we are ready to work on your server. Connect to your VPS as root via SSH (Putty) and enter the following command to start the automated install:

```bash <(curl -sL https://raw.githubusercontent.com/Syscoin/Masternode-install-script/master/script.sh)```

Default values are found in brackets and pressing enter will selected the [default] value. For entries with a [Y/n] the capital letter is the default. Enter [Y] to choose “yes” or [N] to choose “no”. Likely the only value you will need to enter is your Masternode BLS Secret key.

``` 
Syscoin Core Github Branch [master]:
External IP Address [123.123.123.123]: 
Masternode Port [8369]: 
Masternode BLS Secret Key []: 1a8f477d2b02650b7d159efe315940f05252334eb292376309386cc99b0c4ec7
Configure for mainnet? [Y/n]: 
 
Press any key to continue or Ctrl+C to exit...
```

Once the build process and configuration have completed, to access the syscoind and syscoin-cli executables via the new syscoin user type the below into cmd;
```source ~/.bashrc ```

To check on sync status type;
```syscli mnsync status```

**Now head to your Syscoin QT to Register your masternode**

## Prepare a ProRegTx transaction

A pair of BLS keys for the operator were already generated above, and the secret key was entered on the masternode. The public key is used in this transaction as the operatorPubKey

First, we need to get a new, unused address from the wallet to serve as the owner key address ownerKeyAddr. This is not the same as the collateral address holding 100,000 Syscoin. This address must be different for each MN. 

Generate a new address as follows:

```getnewaddress mn1-owner```

This address can also be used as the voting key address **votingKeyAddr**. Alternatively, you can specify an address provided to you by your chosen voting delegate, or simply generate a new voting key address as follows:

```getnewaddress mn1-voting```

Then either generate or choose an existing address to receive the owner’s masternode payouts **payoutAddress**. This address cannot be the same as your owner or voting address, it is also possible to use an address external to the wallet:

```getnewaddress payouts```

You can also optionally generate and fund another address as the transaction fee source **feeSourceAddress**. If you selected an external payout address, you must specify a fee source address.

> Either the payout address or fee source address must have enough balance to pay the transaction fee, or the register_prepare transaction will fail.
> 

The private keys to the owner and fee source addresses must exist in the wallet submitting the transaction to the network. If your wallet is protected by a password, it must now be unlocked to perform the following commands. Unlock your wallet for 5 minutes:

```walletpassphrase yourSecretPassword 300```

## Donate to the Syscoin Foundation

When Registering your Syscoin Masternode in the next step you have the option to donate a percentage of your rewards to someone else via the **operatorReward** argument. Please help support the team and choose an amount that you are happy to donate such as 5% to 10%. By doing this you help the efforts of the Foundation on creating a solid network and the continued development of Syscoin. If you do select an amount, there will be an extra step at the end of the tutorial that you will need to complete via Syscoin QT console. **The team thanks you in advance for your continued support.**

## Register ProTx

We will now prepare an unsigned ProRegTx special transaction using the protx_register_prepare command. 

This command has the following syntax:

```protx_register_prepare collateralHash collateralIndex ipAndPort ownerKeyAddr operatorPubKey votingKeyAddr operatorReward payoutAddress (feeSourceAddress)```

Open a text editor such as notepad ++ to prepare this command or head to [SysHub Masternode Registration](https://syshub-dev.web.app/masternodes/masternode-registration). 

Replace each argument to the command as follows:

- collateralHash: The txid of the 100000 Syscoin collateral funding transaction
- collateralIndex: The output index of the 100000 Syscoin funding transaction
- ipAndPort: Masternode IP address and port, in the format x.x.x.x:yyyy
- ownerKeyAddr: The Syscoin address generated above for the owner address
- operatorPubKey: The BLS public key generated above (or provided by your hosting service)
- votingKeyAddr: The Syscoin address generated above, or the address of a delegate, used for proposal voting
- operatorReward: The percentage of the block reward allocated to the operator as payment, 0 for no reward - this is if you want to pay someone else a % of your rewards. **This is the part where if you would like to donate to the Syscoin Foundation.**
- payoutAddress: A Syscoin address to receive the owner’s masternode rewards.
- feeSourceAddress: An (optional) address used to fund ProTx fee. payoutAddress will be used if not specified.

>Note that the operator is responsible for specifying their own reward address in a separate update_service transaction if you specify a non-zero operatorReward. The owner of the masternode collateral does not specify the operator’s payout address.
>

Either the **feeSourceAddress** or **payoutAddress** must hold a small balance since a standard transaction fee is involved.
Example (remove line breaks if copying):

Note in this example I will use the same address for owner and voting and i will have sent a small amount of Sys to the payoutAddress for fees as i am not using feeSourceAddress.

**(Remember to lock your collateral if using a seniority address)**

```protx_register_prepare 3304a4920f20e1e5cd1f4e5396556ded1e603296f7c5dd66c7ec4fe63cb008d 0 161.97.140.65:8369 sys1q9aejtrvkrlnqsfeqanr5zh2wh676mvmekj4hj0 05afc5f75d0a215951677703e41a108a67f2efb31110e392d988dbd4f9e8446a3336d59de1ff886ec0d3c65c822af2de tsys1q9aejtrvkrlnqsfeqanr5zh2wh676mvmekj4hj0 0 tsys1quuu4ach5npjp3vpmaezzctc9r33405p39khz67
Output:
{
  "tx": "5000000000010163dc2d9a36a7a620386a23002ab6b8a2aba0956e7e047b73a6cf27d9d51571e80100000000feffffff020000000000000000d16a4cce0100000000008d00cb63fec47e6cd65d7c6f2903e6d1de566539e5341fcde5e1200f92a404330000000000000000000000000000ffffa1618f4447c12f73258d961fe6082720ecc7415d4ebebdadb37905afc5f75d0a215951677703e41a108a67f2efb31110e392d988dbd4f9e8446a3336d59de1ff886ec0d3c65c822af2de2f73258d961fe6082720ecc7415d4ebebdadb3790000160014e7395ee2f4986418b03bee442c2f051c6357d0318e95079d496ed43baba5101dab0ab5ace776ac1b0b7fcba7711a2504c9ea36610074c89a3b00000000160014279a7a94c83130b3eee07f2c66b2faa94b6cfe990247304402201f1e01ab33d4f388386ca5df94818674cf4b1909806c3a92ffc11ded88d84dfb02206d289cca1fbd19bc5154c85ec4f1eb3748f77071d863ae4f6aa18f56807f76e801210298a88bd8293e4d0248eb89f276cb54c26b3686ea4e17df155a22bfed2426862800000000",
  "collateralAddress": "TB59KQk6WsMaJxkc8UB3hudjtGMqfeQWSG",
  "signMessage": "sys1quuu4ach5npjp3vpmaezzctc9r33405p39khz67|0|tsys1q9aejtrvkrlnqsfeqanr5zh2wh676mvmekj4hj0|tsys1q9aejtrvkrlnqsfeqanr5zh2wh676mvmekj4hj0|00def144051468bdb1a855f01bf9f022091c4c0ebc745d1ecc28ac418c9af2e0"
}
```

Next we will use the collateralAddress and signMessage fields to sign the transaction, and the output of the tx field to submit the transaction.

## Sign the ProRegTx transaction

We will now sign the content of the signMessage (returned above) field using the public key for the collateral address as specified in collateralAddress. The wallet used to sign must hold the private key to the collateral address and note that no internet connection is required for this step, meaning that the wallet can remain disconnected from the internet in cold storage to sign the message. 

The command takes the following syntax:
```
signmessagebech32 collateralAddress signMessage
```
Example: (excluding “ ”)
```
signmessagebech32 TB59KQk6WsMaJxkc8UB3hudjtGMqfeQWSG tsys1quuu4ach5npjp3vpmaezzctc9r33405p39khz67|0|tsys1q9aejtrvkrlnqsfeqanr5zh2wh676mvmekj4hj0|tsys1q9aejtrvkrlnqsfeqanr5zh2wh676mvmekj4hj0|00def144051468bdb1a855f01bf9f022091c4c0ebc745d1ecc28ac418c9af2e0
```
Output:
```IGj1ORdk3yv/uAMKG+DZrBA/GTHX4dW8zn/rmMfGzOzCIaxqmyUbNveYtnqh9wLVECENMjyuyeR2VmB3ccNlRLw=```

## Submit the signed message

We will now submit the ProRegTx special transaction to the blockchain to register the masternode. This command must be sent from the wallet holding a balance on either the feeSourceAddress or payoutAddress, since a standard transaction fee is involved. 

The command takes the following syntax:

```protx_register_submit tx sig```

Where:
tx: The serialized transaction previously returned in the tx output field from the protx_register_prepare command
sig: The message returned from the signmessagebech32 command.

Example: (excluding “ ”)
```
protx_register_submit 5000000000010163dc2d9a36a7a620386a23002ab6b8a2aba0956e7e047b73a6cf27d9d51571e80100000000feffffff020000000000000000d16a4cce0100000000008d00cb63fec47e6cd65d7c6f2903e6d1de566539e5341fcde5e1200f92a404330000000000000000000000000000ffffa1618f4447c12f73258d961fe6082720ecc7415d4ebebdadb37905afc5f75d0a215951677703e41a108a67f2efb31110e392d988dbd4f9e8446a3336d59de1ff886ec0d3c65c822af2de2f73258d961fe6082720ecc7415d4ebebdadb3790000160014e7395ee2f4986418b03bee442c2f051c6357d0318e95079d496ed43baba5101dab0ab5ace776ac1b0b7fcba7711a2504c9ea36610074c89a3b00000000160014279a7a94c83130b3eee07f2c66b2faa94b6cfe990247304402201f1e01ab33d4f388386ca5df94818674cf4b1909806c3a92ffc11ded88d84dfb02206d289cca1fbd19bc5154c85ec4f1eb3748f77071d863ae4f6aa18f56807f76e801210298a88bd8293e4d0248eb89f276cb54c26b3686ea4e17df155a22bfed2426862800000000 IGj1ORdk3yv/uAMKG+DZrBA/GTHX4dW8zn/rmMfGzOzCIaxqmyUbNveYtnqh9wLVECENMjyuyeR2VmB3ccNlRLw=
```
Output:

```285fba6277586401f8efaf55d4eef7acfa6d690a30c0db7f213a0bb2c6194bd1```

Your masternode is now registered and will appear on the Deterministic Masternode List after the transaction is mined to a block. 

You can view this list on the Masternodes tab in QT, or in the console using the command protx_list valid, where the txid of the final protx_register_submit transaction identifies your masternode.

## Specifying donation address for operatorReward (optional)
**Syscoin Foundation Address:** ```sys1q6u9ey7qjh3fmnz5gsghcmpnjlh2akem4xm38sw```

You only need to do this if you input a value greater than 0 when completing the ProRegTx for operatorReward. 

```protx_update_service proTxHash ipAndPort operatorKey (operatorPayoutAddress feeSourceAddress)```

Where:

- proTxHash: The hash of the initial ProRegTx
- ipAndPort: IP and port in the form “ip:port”
- operatorKey: The operator BLS private key associated with the registered operator public key
- operatorPayoutAddress: The address used for operator reward payments.
- feeSourceAddress (optional): An address used to fund ProTx fee. operatorPayoutAddress will be used if not specified.

Example:

```protx update_service 285fba6277586401f8efaf55d4eef7acfa6d690a30c0db7f213a0bb2c6194bd1 161.97.140.65:8369 1a8f477d2b02650b7d159efe315940f05252334eb292376309386cc99b0c4ec7 sys1q6u9ey7qjh3fmnz5gsghcmpnjlh2akem4xm38sw```

## UPGRADING YOUR VPS
1. Login to your VPS via root
2. Run the cmd `sysmasternode`
3. If this does not work, run the cmd `source ~/.bashrc` then rerun `sysmasternode`
4. Follow prompts to upgrade.

## MASTERNODE COMMANDS

###### view your syscoin.conf
```
sudo cat /home/syscoin/.syscoin/syscoin.conf
```
 
###### view your sentinel.conf
```
sudo cat /home/syscoin/sentinel/sentinel.conf
```

###### view the syscoin user crontab which should contain: 
```*/10 * * * * /usr/local/bin/sentinel-ping
sudo crontab -u syscoin -l
```
 
###### run a sentinel ping to speed up Qt syncing? why not!
```
sudo su -c "sentinel-ping" syscoin
```

###### view the sentinel-ping cron log, look for errors
```
sudo less /home/syscoin/sentinel/sentinel-cron.log
```

###### view the syscoind debug log, look for errors
```
sudo less /home/syscoin/.syscoin/debug.log
``` 

###### start and stop the syscoind systemd service
```
sudo service syscoind stop
sudo service syscoind start
sudo service syscoind restart
```

###### check that the syscoind process is running at the proper user
```
ps aux | grep [s]yscoind
```

###### log out and back in or run the following to alias syscoind and syscoin-cli
```
source ~/.bashrc
```

###### now the commands run as the syscoin user
```
syscoin-cli getblockchaininfo
syscoin-cli mnsync status
syscoin-cli masternode_status
```

###### it is aliased to this shorter function 
```
syscli getblockchaininfo
syscli mnsync status
syscli masternode_status
```

###### if you really want to log in as the syscoin user
```
sudo su - syscoin
```

---
