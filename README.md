# SYSCOIN 4 MASTERNODE SCRIPT

![Sycoin Logo Scifi](https://github.com/bigpoppa-sys/sysmn/blob/master/img/syscoin-logo.jpg)

---

## MASTERNODE REQUIREMENTS
1. 100,000.00 SYSCOIN
2. VPS with following;
   * 64-bit CPU — 2 Cores (4 preferred)
   * 4gb RAM (real) minimum (8gb RAM preferred)
   * 4gb swap (if less than 8gb real RAM) Will need to use SSD if using Swap
   * VM or OpenVZ (KVM preferred)
   * Linux OS — Ubuntu 18.04.1 LTS (Bionic Beaver)
   * 80gb Disk Space (100gb+ SSD preferred)

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

## INSTALLATION

##### 1. DUMP WALLET

If you are upgrading your wallet from Syscoin 3.x to Syscoin 4.x you MUST run dumpwallet ```"/full/path/to/dump.txt"``` and then importwallet ```"/full/path/to/dump.txt"```. You will likely want to delete ```“/full/path/to/dump.txt”``` after this process as it contains unprotected private keys.

```diff 
- WARNING: Your wallet dump file contains unprotected private keys. 
- Please delete it after completing this step!
```

##### 2. PREPARE QT & SEND 100,000 SYS COLLATERAL

- To stake your masternode you will need to provide exactly 100,000 SYS in your masternode address. Use [Syscoin Core Qt](https://github.com/syscoin/syscoin/releases) for your system to process this transaction.

- To get started open Syscoin Core Qt on your computer and from the menu select “Settings > Options” on Windows or “Syscoin Core > Preferences..” on a Mac. Select the “Wallet” tab and click the checkbox to “Enable coin control features” and “Show Masternodes Tab”. Click the “Ok” button to save your settings, close Syscoin Core Qt then re-open it to view the new options, then wait for the blockchain to fully sync with the network.

- Once your local Syscoin Core Qt has fully synced select “Tools > Debug” and enter ```masternode genkey``` to generate your masternode private key. Copy this value as you will need it later, it will look similar to the following:
```
masternode genkey
7ra1rhngvNkhkiFE8STrmvH3LvYTCzLyRFHFsZvrJUBV6ZmWnc
```

- Next type ```getnewaddress <LABEL> legacy``` (replacing <LABEL> with a name eg. mn1), to generate an address to use for your 100k collateral. Masternodes require legacy addresses, and will not work with the new Bech32 addresses that start with sys. Copy down this address as well as you will need to send your collateral to it in the next step.

- If you are configuring multiple masternodes you will need to create a unique masternode private key and unique collateral address for each masternode using the steps above. Once the address is created for each masternode send a collateral transaction of exactly 100,000SYS to the address for each masternode using the next steps.

```diff
- WARNING: If you use the same address for multiple masternodes your reward payouts cannot be completed.
```

- Use Coin Control to ensure that you send your collateral from the correct address. Go to “Send” and then “Inputs” to select the input that you would like to send from. In the example below using tSYS, the “Main” input will be selected. Click “Ok” to return to the “Send” screen.

- Next enter your masternode collateral address from the previous step into the “Pay To” field. Enter “100,000” exactly into the “Amount” field and do NOT subtract fees from the amount as it will reduce your collateral total.

- Press “Send” to send your Syscoin to your masternode collateral address. You will need to wait 1 block – approximately 1 minute – for the transaction to confirm.

- Next you will need to get the transaction id for the collateral by selecting the “Transactions” tab to see the 100,000SYS sent to yourself. Right click this transaction to view the id, and copy it down as well for later use.

- In Syscoin Core Qt again open the “Tools > Debug” menu and enter masternode outputs. You will get a long string that is a hash of the transaction id from the previous step followed by a “0” or “1” to indicate the output index. The result should resemble the following:

```
masternode outputs
}
“06e38868bb8f9958e34d5155437d009b72dff33fc87fd42e51c0f74fdb” : “0”,
}
```

- From the Syscoin-Qt menu select “Tools > Open Masternode Configuration File”. You will need to enter your masternode information using a text editor in the following format and use the public IP address of your server not your local computer. Make sure that the line does not start with a # as this will comment out the line! 

```
masternode.conf
# Masternode config file
# Format: alias IP:port masternodeprivkey collateral_output_txid collateral_output_index
mn1 123.123.123.123:8369 7ra1rhngvNkhkiFE8STrmvH3LvYTCzLyRFHFsZvrJUBV6ZmWnc 06e38868bb8f9958e34d5155437d009b72dff33fc87fd42e51c0f74fdb 0
```

- Save this file then close and restart Syscoin-Qt. If you don’t see your masternode listed in the “Masternode” tab please double check the above configuration.

##### 3. CONFIGURE MASTERNODE ON VPS

- Finally we are ready to work on your server. Connect to your VPS via SSH (Putty) and enter the following command to start the automated install:

```
bash <(curl -sL https://raw.githubusercontent.com/bigpoppa-sys/sysmn/master/script.sh)
```

- Default values are found in brackets and pressing enter will selected the [default] value. For entries with a [Y/n] the capital letter is the default. Enter [Y] to choose “yes” or [N] to choose “no”. Likely the only value you will need to enter is your masternode private key.

```
Syscoin Core Github Branch [master]: 
Masternode Private Key []: 7ra1rhngvNkhkiFE8STrmvH3LvYTCzLyRFHFsZvrJUBV6ZmWnc
External IP Address [123.123.123.123]: 
Masternode Port [8369]: 
 
Press any key to continue or Ctrl+C to exit...
```

- Once the build process and configuration have completed, to access the syscoind and syscoin-cli executables via the new syscoin user type the below into cmd; 

```
source ~/.bashrc 
```

##### 4. ENABLE MASTERNODE

- Back on your local computer restart Syscoin Core Qt and wait for it to sync up to the network. 
   - Choose the “Masternodes” tab, select your masternode,
   - Click “Initialize”.

Only click this button once and if your “Status” ever changes it’s recommended to confer with the #masternodes Discord Channel before restarting your node. If you restart you will need to re-qualify for rewards and won’t receive any rewards during this time.

---

**Eligibility for Rewards**

Keep in mind that your masternode will not immediately be eligible for rewards. The eligibility period is determined by the formula [number of masternodes] * 2.6 * 60 seconds.

Note, if you restart your masternode by pressing “Initialize” in Qt this counter will reset and you will not receive rewards until your masternode is eligible again.

---

**Summary**

This script installs the necessary dependencies to build the Syscoin Core from source. It creates a user named “syscoin” and uses a systemd service to start the syscoind process as the “syscoin” user, and it set to start on boot after the necessary networking services have started.

Updates and reconfigurations can be performed by entering the command **sysmasternode** or the initial auto install command ```bash <(curl -sL https://raw.githubusercontent.com/bigpoppa-sys/sysmn/master/script.sh)```

---

**SYSHUB**

[SysHub](https://syshub.org)

Now it is time to head over to SysHub and register your masternode. You can also create Proposals through the generator for Governance and Vote on upcoming Proposals.

---

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
syscoin-cli masternode status
```

###### it is aliased to this shorter function 
```
syscli getblockchaininfo
syscli mnsync status
syscli masternode status
```

###### if you really want to log in as the syscoin user
```
sudo su - syscoin
```

---

Special thanks to demesm and doublesharp for the initial script. Shoutouts to bitje, johnp and the Syscoin team for upgrading and working out minor issues to get it running on SYS4.

"Spread Love It's The Brooklyn Way"
- BigPoppa
