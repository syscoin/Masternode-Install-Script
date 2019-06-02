# SYSCOIN 4 MASTERNODE SCRIPT

---

## VPS Providers

There are many VPS service providers that offer and exceed the hardware requirements, as such it is recommended that you shop around and do your own homework on various potential providers. Note the following is a list of just some examples and should not be interpreted as recommendations or endorsement.

- UK2.net
- IONOS.co.uk
- InterServer.net
- OVH.co.uk
- KimSufi.com
- mVPS.net
- VPS-Mart.com
- Hostinger.com
- BudgetVM.com
- Virtono.com
- LeaseWeb.com
- HomeAtCloud.com
- IdeaStack.com
- SSDNodes.com
- SimplyHosting.com
- RAMNode.com
- Time4VPS.com


###### To start:
1. Create your VPS with following configs:
    * 64-bit CPU — 2 Cores (4 preferred)
    * 4gb RAM (real) minimum (8gb RAM preferred)
    * 4gb swap (if less than 8gb real RAM) Will need to use SSD if using Swap
    * VM or OpenVZ (KVM preferred)
    * Linux OS — Ubuntu 18.04.1 LTS (Bionic Beaver)
    * (Sys4 will not compile on earlier versions as C++17 compiler is required)
    * 80gb Disk Space (100gb+ SSD preferred)

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
