# sysmn
Script for SYS4 Testnet

As we are running a hot wallet for testing purposes without QT, this is 90% auto and 10% manual. Not common practice, but to just get these test nodes up quick and easy, I am just running from root. Will adjust script come mainnet time.

To start:
1. Create your VPS with following configs
    a. 64-bit CPU — 2 Cores (4 preferred)
    b. 4gb RAM (real) minimum (8gb RAM preferred)
    c. 4gb swap (if less than 8gb real RAM) Will need to use SSD if using Swap
    d. VM or OpenVZ (KVM preferred)
    e. Linux OS — Ubuntu 18.04.1 LTS (Bionic Beaver). Sys4 will not compile on earlier versions as C++17 compiler is required.
    f. 80gb Disk Space (100gb+ SSD preferred).
    g. Port open for Syscoin (default: 8369) and Geth (default: 30303)

2. Login as root.
3. wget https://raw.githubusercontent.com/bigpoppa-sys/sysmn/master/script.sh  && chmod +x script.sh && ./script.sh
6. Follow prompts.
7. Once built you will need to adjust syscoin.conf and masternode.conf with your details.
