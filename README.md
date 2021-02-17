# TESTING PURPOSES ONLY! DO NOT USE THIS FOR MAINNET!

# SYSCOIN 4.2 TESTNET MASTERNODE SCRIPT

---

## MASTERNODE REQUIREMENTS
* 64-bit CPU — 2 Cores (4 preferred)
* 4gb RAM (real) minimum (8gb RAM preferred)
* 4gb swap (if less than 8gb real RAM) Will need to use SSD if using Swap
KVM or OpenVZ (KVM preferred)
* Linux OS — Minimum Ubuntu 18.04, LTS Ubuntu 20.04 LTS (Focal Fossa) preferred.
* 80gb Disk Space (100gb+ SSD preferred).
* Port open for Syscoin (default: 18369) and Geth (default: 30303)

##### CONFIGURE MASTERNODE ON VPS

1. Follow Johnp's guide to setup QT;

https://bittyjohn1954.medium.com/syscoin-4-2-testnet-setup-guide-assuming-a-clean-install-63e8b2772600


2. First head to QT and generate your BLS keys and copy them down

```
bls_generate
```

3. Connect to your VPS as **root** via SSH (Putty) and enter the following command to start the automated install:

```
bash <(curl -sL https://raw.githubusercontent.com/bigpoppa-sys/Masternode-Install-Script/master/script.sh)
```

4. Follow below;

```
Syscoin Core Github Tag [master]: enter the latest tag for testnet eg. 4.2.0rc7
External IP Address [123.123.123.123]: press Enter
Masternode Port [8369]: press Enter
Masternode BLS Priv Key []: paste in you BLS secret key
Configure for mainnet [Y/n]: type "n" and press enter
 
Press any key to continue or Ctrl+C to exit...
```

5. Once the build process and configuration have completed, to access the syscoind and syscoin-cli executables via the new syscoin user type the below into cmd; 

```
source ~/.bashrc 
```

6. Follow Johnp's guide for the rest to register your masternode in QT;

https://bittyjohn1954.medium.com/syscoin-4-2-testnet-setup-guide-assuming-a-clean-install-63e8b2772600


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
