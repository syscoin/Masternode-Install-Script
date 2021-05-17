#!/bin/bash -i

# Only run as a root user
if [ "$(sudo id -u)" != "0" ]; then
    echo "This script may only be run as root or with user with sudo privileges."
    exit 1
fi

HBAR="---------------------------------------------------------------------------------------"

# import messages
source <(curl -sL https://raw.githubusercontent.com/Syscoin/Masternode-Install-Script/master/messages.sh) 

pause(){
  echo ""
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

do_exit(){
  echo "$MESSAGE_COMPLETE"
  echo ""
  echo "Your masternode configuration should now be completed and running as the syscoin user."
  echo ""
  echo "Please run the following command"
  echo "source ~/.bashrc"
  echo ""
  echo ""
  echo "Big thanks to demesm & doublesharp for the original script"
  echo ""
  echo "Special mention to bitje, johnp, and SYS Team!"
  echo ""
  echo "Spread Love It's The Brooklyn Way!"
  echo "-BigPoppa"
  echo ""
  echo ""
  exit 0
}

update_system(){
  echo "$MESSAGE_UPDATE"
  # update package and upgrade Ubuntu
  sudo DEBIAN_FRONTEND=noninteractive apt -y update
  sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade
  sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
  clear
}

maybe_prompt_for_swap_file(){
  # Create swapfile if less than 8GB memory
  MEMORY_RAM=$(free -m | awk '/^Mem:/{print $2}')
  MEMORY_SWAP=$(free -m | awk '/^Swap:/{print $2}')
  MEMORY_TOTAL=$(($MEMORY_RAM + $MEMORY_SWAP))
  if [ $MEMORY_RAM -lt 3800 ]; then
      echo "You need to upgrade your server to 4 GB RAM."
       exit 1
  fi
  if [ $MEMORY_TOTAL -lt 7700 ]; then
      CREATE_SWAP="Y";
  fi
}

maybe_create_swap_file(){
  if [ "$CREATE_SWAP" = "Y" ]; then
    echo "Creating a 4GB swapfile..."
    sudo swapoff -a
    sudo dd if=/dev/zero of=/swap.img bs=1M count=4096
    sudo chmod 600 /swap.img
    sudo mkswap /swap.img
    sudo swapon /swap.img
    echo '/swap.img none swap sw 0 0' | sudo tee --append /etc/fstab > /dev/null
    sudo mount -a
    echo "Swapfile created."
    clear
  fi
}

syscoin_branch(){
  tag_url="https://github.com/syscoin/syscoin/releases/latest/"
  tag_get="tag_name=v"
  tag_grep=$(curl -sL $tag_url | grep -o -m1 "$tag_get\?[0-9]*\.[0-9]*\.[0-9]*")
  ((tag_pos=${#tag_get}+1))
  tag_ver=$(echo "$tag_grep" | cut -c$tag_pos-)
  read -e -p "Syscoin Core Github Tag [$tag_ver]: " SYSCOIN_BRANCH
  if [ "$SYSCOIN_BRANCH" = "" ]; then
    SYSCOIN_BRANCH=$tag_ver
  fi
}

install_binaries(){
  echo "$MESSAGE_DEPENDENCIES"
  wget https://github.com/syscoin/syscoin/releases/download/v$SYSCOIN_BRANCH/syscoin-$SYSCOIN_BRANCH-x86_64-linux-gnu.tar.gz
  tar xf syscoin-$SYSCOIN_BRANCH-x86_64-linux-gnu.tar.gz
  sudo install -m 0755 -o root -g root -t /usr/local/bin syscoin-$SYSCOIN_BRANCH/bin/*
  rm -r syscoin-$SYSCOIN_BRANCH
  rm syscoin-$SYSCOIN_BRANCH-x86_64-linux-gnu.tar.gz
  clear
}

install_sentinel(){
  echo "$MESSAGE_SENTINEL"
  # go home
  cd
  if [ ! -d ~/sentinel ]; then
    git clone https://github.com/syscoin/sentinel.git
  else
    cd sentinel
    git fetch
    git checkout master --quiet
    git pull
  fi
  clear
}

install_virtualenv(){
  echo "$MESSAGE_VIRTUALENV"
  cd ~/sentinel
  # install virtualenv
  sudo apt-get -y install git python3 virtualenv
  # setup virtualenv
  virtualenv -p $(which python3) ./venv
  ./venv/bin/pip install -r requirements.txt
  clear
}

configure_sentinel(){
  echo "$MESSAGE_CRONTAB"
  # create sentinel conf file
  echo "$SENTINEL_CONF" > ~/sentinel/sentinel.conf
  if [ "$IS_MAINNET" = "" ] || [ "$IS_MAINNET" = "y" ] || [ "$IS_MAINNET" = "Y" ]; then
    echo "network=mainnet" >> ~/sentinel/sentinel.conf
  else
    echo "network=testnet" >> ~/sentinel/sentinel.conf
  fi

  cd
  if [ -d /home/syscoin/sentinel ]; then
    sudo rm -rf /home/syscoin/sentinel
  fi
  sudo mv -f ~/sentinel /home/syscoin
  sudo chown -R syscoin.syscoin /home/syscoin/sentinel

  # create sentinel-ping
  echo "$SENTINEL_PING" > ~/sentinel-ping

  # install sentinel-ping script
  sudo mv -f ~/sentinel-ping /usr/local/bin
  sudo chmod +x /usr/local/bin/sentinel-ping

  # setup cron for syscoin user
  sudo crontab -r -u syscoin
  sudo crontab -l -u syscoin | grep sentinel-ping || echo "* * * * * /usr/local/bin/sentinel-ping" | sudo crontab -u syscoin -
  clear
}

start_syscoind(){
  echo "$MESSAGE_SYSCOIND"
  sudo service syscoind start     # start the service
  sudo systemctl enable syscoind  # enable at boot
  clear
}

stop_syscoind(){
  echo "$MESSAGE_STOPPING"
  sudo service syscoind stop
  clear
}

upgrade() {
  syscoin_branch
  stop_syscoind       # stop syscoind if it is running
  install_binaries # make sure we have the latest deps
  update_system       # update all the system libraries
  clear

  # maybe upgrade sentinel
  if [ "$IS_UPGRADE_SENTINEL" = "y" ] || [ "$IS_UPGRADE_SENTINEL" = "Y" ]; then
    install_sentinel
    install_virtualenv
    configure_sentinel
  fi
  
  create_systemd_syscoind_service

  start_syscoind      # start syscoind back up
  
  echo "$MESSAGE_COMPLETE"
  do_exit             # exit the script
}

# errors are shown if LC_ALL is blank when you run locale
if [ "$LC_ALL" = "" ]; then export LC_ALL="$LANG"; fi

clear
echo "$MESSAGE_WELCOME"
pause
clear

echo "$MESSAGE_PLAYER_ONE"
sleep 1
clear

# check if there is enough physical memory present
maybe_prompt_for_swap_file

# syscoind.service config
SENTINEL_CONF=$(cat <<EOF
# syscoin conf location
syscoin_conf=/home/syscoin/.syscoin/syscoin.conf
# db connection details
db_name=/home/syscoin/sentinel/database/sentinel.db
db_driver=sqlite
# network
EOF
)

# syscoind.service config
SENTINEL_PING=$(cat <<EOF
#!/bin/bash
/home/syscoin/sentinel/venv/bin/python /home/syscoin/sentinel/bin/sentinel.py 2>&1 >> /home/syscoin/sentinel/sentinel-cron.log
EOF
)

# check to see if there is already a syscoin user on the system
if grep -q '^syscoin:' /etc/passwd; then
  clear
  echo "$MESSAGE_UPGRADE"
  echo ""
  echo "  Choose [Y]es (default) to upgrade Syscoin Core on a working masternode."
  echo "  Choose [N]o to re-run the configuration process for your masternode."
  echo ""
  echo "$HBAR"
  echo ""
  read -e -p "Upgrade/reinstall Syscoin Core? [Y/n]: " IS_UPGRADE
  if [ "$IS_UPGRADE" = "" ] || [ "$IS_UPGRADE" = "y" ] || [ "$IS_UPGRADE" = "Y" ]; then
    read -e -p "Upgrade Sentinel as well? [y/N]: " IS_UPGRADE_SENTINEL
    upgrade
  fi
fi
clear

SYSCOIN_BRANCH="master"
RESOLVED_ADDRESS=$(curl -s ipinfo.io/ip)
DEFAULT_PORT=8369

# syscoin.conf value defaults
rpcuser="sycoinrpc"
rpcpassword="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
masternodeblsprivkey=""
externalip="$RESOLVED_ADDRESS"
port="$DEFAULT_PORT"

# try to read them in from an existing install
if sudo test -f /home/syscoin/.syscoin/syscoin.conf; then
  sudo cp /home/syscoin/.syscoin/syscoin.conf ~/syscoin.conf
  sudo chown $(whoami).$(id -g -n $(whoami)) ~/syscoin.conf
  source ~/syscoin.conf
  rm -f ~/syscoin.conf
fi

RPC_USER="$rpcuser"
RPC_PASSWORD="$rpcpassword"
MASTERNODE_PORT="$port"

# ask which branch to use
syscoin_branch

if [ "$externalip" != "$RESOLVED_ADDRESS" ]; then
  echo ""
  echo "WARNING: The syscoin.conf value for externalip=${externalip} does not match your detected external ip of ${RESOLVED_ADDRESS}."
  echo ""
fi
read -e -p "External IP Address [$externalip]: " EXTERNAL_ADDRESS
if [ "$EXTERNAL_ADDRESS" = "" ]; then
  EXTERNAL_ADDRESS="$externalip"
fi
if [ "$port" != "" ] && [ "$port" != "$DEFAULT_PORT" ]; then
  echo ""
  echo "WARNING: The syscoin.conf value for port=${port} does not match the default of ${DEFAULT_PORT}."
  echo ""
fi
read -e -p "Masternode Port [$port]: " MASTERNODE_PORT
if [ "$MASTERNODE_PORT" = "" ]; then
  MASTERNODE_PORT="$port"
fi

masternode_bls_key(){
  read -e -p "Masternode BLS Secret Key [$masternodeblskey]: " MASTERNODE_BLS_KEY
  if [ "$MASTERNODE_BLS_KEY" = "" ]; then
    if [ "$masternodeblsprivkey" != "" ]; then
      MASTERNODE_BLS_KEY="$masternodeblsprivkey"
    else
      echo "You must enter a Masternode BLS Key!";
      masternode_bls_key
    fi
  fi
}

masternode_bls_key

read -e -p "Configure for mainnet? [Y/n]: " IS_MAINNET

#Generating Random Passwords
RPC_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

pause
clear

# syscoin conf file
SYSCOIN_CONF=$(cat <<EOF
rpcuser=user
rpcpassword=$RPC_PASSWORD
listen=1
daemon=1
server=1
assetindex=1
port=8369
rpcport=8370
rpcallowip=127.0.0.1
masternodeblsprivkey=$MASTERNODE_BLS_KEY
externalip=$EXTERNAL_ADDRESS
EOF
)

# testnet config
SYSCOIN_TESTNET_CONF=$(cat <<EOF
testnet=1
[test]
rpcuser=user
rpcpassword=$RPC_PASSWORD
listen=1
daemon=1
server=1
assetindex=1
port=18369
rpcport=18370
rpcallowip=127.0.0.1
externalip=$EXTERNAL_ADDRESS
gethtestnet=1
addnode=54.190.239.153
addnode=52.40.171.92
masternodeblsprivkey=$MASTERNODE_BLS_KEY
EOF
)

# syscoind.service config
SYSCOIND_SERVICE=$(cat <<EOF
[Unit]
Description=Syscoin Core Service
After=network.target iptables.service firewalld.service
 
[Service]
Type=forking
User=syscoin
ExecStart=/usr/local/bin/syscoind
ExecStop=/usr/local/bin/syscoin-cli stop && sleep 20 && /usr/bin/killall syscoind
ExecReload=/usr/local/bin/syscoin-cli stop && sleep 20 && /usr/local/bin/syscoind -reindex
 
[Install]
WantedBy=multi-user.target
EOF
)

# functions to install a masternode from scratch
create_and_configure_syscoin_user(){
  echo "$MESSAGE_CREATE_USER"

  # create a syscoin user if it doesn't exist
  grep -q '^syscoin:' /etc/passwd || sudo adduser --disabled-password --gecos "" syscoin
  
  # add alias to .bashrc to run syscoin-cli as sycoin user
  grep -q "syscli\(\)" ~/.bashrc || echo "syscli() { sudo su -c \"syscoin-cli \$*\" syscoin; }" >> ~/.bashrc
  grep -q "alias syscoin-cli" ~/.bashrc || echo "alias syscoin-cli='syscli'" >> ~/.bashrc
  grep -q "sysd\(\)" ~/.bashrc || echo "sysd() { sudo su -c \"syscoind \$*\" syscoin; }" >> ~/.bashrc
  grep -q "alias syscoind" ~/.bashrc || echo "alias syscoind='sysd'" >> ~/.bashrc
  grep -q "sysmasternode\(\)" ~/.bashrc || echo "sysmasternode() { bash <(curl -sL https://raw.githubusercontent.com/Syscoin/Masternode-Install-Script/master/script.sh) ; }" >> ~/.bashrc

  echo "$SYSCOIN_CONF" > ~/syscoin.conf
  if [ ! "$IS_MAINNET" = "" ] && [ ! "$IS_MAINNET" = "y" ] && [ ! "$IS_MAINNET" = "Y" ]; then
    echo "$SYSCOIN_TESTNET_CONF" > ~/syscoin.conf
  fi

  # in case it's already running because this is a re-install
  sudo service syscoind stop

  # create conf directory
  sudo mkdir -p /home/syscoin/.syscoin
  sudo rm -rf /home/syscoin/.syscoin/debug.log
  sudo mv -f ~/syscoin.conf /home/syscoin/.syscoin/syscoin.conf
  sudo chown -R syscoin.syscoin /home/syscoin/.syscoin
  sudo chmod 600 /home/syscoin/.syscoin/syscoin.conf
  clear
}

create_systemd_syscoind_service(){
  echo "$MESSAGE_SYSTEMD"
  # create systemd service
  echo "$SYSCOIND_SERVICE" > ~/syscoind.service
  # install the service
  sudo mkdir -p /usr/lib/systemd/system/
  sudo mv -f ~/syscoind.service /usr/lib/systemd/system/syscoind.service
  # reload systemd daemon
  sudo systemctl daemon-reload
  clear
}

install_fail2ban(){
  echo "$MESSAGE_FAIL2BAN"
  sudo apt-get install fail2ban -y
  sudo service fail2ban restart
  sudo systemctl fail2ban enable
  clear
}

install_ufw(){
  echo "$MESSAGE_UFW"
  sudo apt install ufw python-is-python3 virtualenv git unzip pv -y
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw allow 18369/tcp
  sudo ufw allow 8369/tcp
  sudo ufw allow 30303/tcp
  sudo ufw logging on
  yes | sudo ufw enable
  clear
}

# if there is <4gb and the user said yes to a swapfile...
maybe_create_swap_file
install_ufw

# prepare to build
update_system
install_binaries
clear

create_and_configure_syscoin_user
create_systemd_syscoind_service
start_syscoind
install_sentinel
install_virtualenv
configure_sentinel
install_fail2ban
clear
# ping sentinel
sudo su -c "sentinel-ping" syscoin

do_exit
