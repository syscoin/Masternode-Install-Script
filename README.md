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
If you require more help, jump into the [Syscoin Discord](https://discord.gg/RkK2AXD) and our community will be more than happy to help you out!\

You can also checkout [Sysnode.info](https://sysnode.info). This website has an array of tools such as Masternode Stats, Monitoring and keeping up to date with current news with Syscoin.

---

###### To start:
1.
    

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
