# sysmn
Script for SYS4 Testnet

As we are running a hot wallet for testing purposes without QT, this is 90% auto and 10% manual. Not common practice, but to just get these test nodes up quick and easy, I am just running from root. Will adjust script come mainnet time.

To start:
1. Create your VPS with following configs:\
    64-bit CPU — 2 Cores (4 preferred)\
    4gb RAM (real) minimum (8gb RAM preferred)\
    4gb swap (if less than 8gb real RAM) Will need to use SSD if using Swap\
    VM or OpenVZ (KVM preferred)\
    Linux OS — Ubuntu 18.04.1 LTS (Bionic Beaver). Sys4 will not compile on earlier versions as C++17 compiler is required.\
    80gb Disk Space (100gb+ SSD preferred).\
    Port open for Syscoin (default: 8369) and Geth (default: 30303)\

2. Login as root.
3. wget https://raw.githubusercontent.com/bigpoppa-sys/sysmn/master/script.sh  && chmod +x script.sh && ./script.sh
6. Follow prompts.
7. Once built you will need to adjust syscoin.conf and masternode.conf with your details.

**Manual Steps**\

**Make an address**\
./syscoin-cli getnewaddress label legacy\
and head to discord's testnet channel to ask for 100,000 tSYS!

You now need to set up Masternode.conf and Syscoin.conf with the correct MN details.

**First get a MN key and save it somewhere**\
./syscoin-cli masternode genkey

**Find your TX and save it somewhere**\
./syscoin-cli listtransactions

**Now get the index and add it to the end of the TX you just saved**\
./syscoin-cli masternode outputs

**Stop Syscoind**\
./syscoin-cli stop

**Edit syscoin.conf - change your IP and genkey**\
nano ~/.syscoin/syscoin.conf

**Edit masternode.conf and add your IP,MN Key,Collateral TX and Index**\
nano ~/.syscoin/masternode.conf
Save.

**Start syscoind**\
~/syscoin/src/syscoind

**Check the status**\
./syscoin-cli getblockchaininfo

**Check Masternode has Synced**\
./syscoin-cli mnsync status

**Start Masternode**\
./syscoin-cli masternode start-all

**Check it has started**\
~/syscoin/src/syscoin-cli masternodelist json yourvpsip


Special thanks to @doublesharp as I have adjusted from his script.\
P.S First github try! So shhh, cut me some slack
