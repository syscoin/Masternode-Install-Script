#!/bin/bash

# Only run as a root user
if [ "$(sudo id -u)" != "0" ]; then
    echo "This script may only be run as root or with user with sudo privileges."
    exit 1
fi

HBAR="---------------------------------------------------------------------------------------"

# import messages
source <(curl -sL https://raw.githubusercontent.com/syscoin/Masternode-Install-Script/master/messages.sh) 

pause(){
  echo ""
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

do_exit(){
  echo ""
  echo "======================================================================================"
  echo "             Install script for Syscoin 4 Masternodes"
  echo "======================================================================================"
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

install_dependencies(){
  echo "$MESSAGE_DEPENDENCIES"
  # build tools
  sudo apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 software-properties-common
  # boost
  sudo apt install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libboost-iostreams-dev
  # bdb 4.8
  sudo add-apt-repository -y ppa:bitcoin/bitcoin
  sudo apt update -y
  sudo apt install -y libdb4.8-dev libdb4.8++-dev
  # zmq
  sudo apt install -y libzmq3-dev
  # git
  sudo apt install -y git
  # virtualenv python
  sudo apt install -y python-virtualenv
  clear
}

git_clone_repository(){
  echo "$MESSAGE_CLONING"
  cd
  if [ ! -d ~/syscoin ]; then
    git clone https://github.com/syscoin/syscoin.git
  fi
}

syscoin_branch(){
  read -e -p "Syscoin Core Github Branch [master]: " SYSCOIN_BRANCH
  if [ "$SYSCOIN_BRANCH" = "" ]; then
    SYSCOIN_BRANCH="master"
  fi
}

git_checkout_branch(){
  cd ~/syscoin
  git fetch
  git checkout $SYSCOIN_BRANCH --quiet
  if [ ! $? = 0 ]; then
    echo "$MESSAGE_ERROR"
    echo "Unable to checkout https://www.github.com/syscoin/syscoin/tree/${SYSCOIN_BRANCH}, please make sure it exists."
    echo ""
    exit 1
  fi
  git pull
}

autogen(){
  echo "$MESSAGE_AUTOGEN"
  cd ~/syscoin
  ./autogen.sh
  clear
}

configure(){
  echo "$MESSAGE_MAKE_CONFIGURE"
  cd ~/syscoin
  ./configure --disable-tests --disable-bench --with-gui=no
  clear
}

compile(){
  echo "$MESSAGE_MAKE"
  echo "Running compile with $(nproc) core(s)..."
  # compile using all available cores
  cd ~/syscoin
  make -j$(nproc)
  clear
}

make_install() {
  echo "$MESSAGE_MAKE_INSTALL"
  # install the binaries to /usr/local/bin
  cd ~/syscoin
  sudo make install
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
    git checkout sys4 --quiet
    git pull
  fi
  clear
}

install_virtualenv(){
  echo "$MESSAGE_VIRTUALENV"
  cd ~/sentinel
  # install virtualenv
  sudo apt-get install -y python-virtualenv virtualenv
  # setup virtualenv
  virtualenv venv
  venv/bin/pip install -r requirements.txt
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
  sudo crontab -l -u syscoin | grep sentinel-ping || echo "*/5 * * * * /usr/local/bin/sentinel-ping" | sudo crontab -u syscoin -
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
  syscoin_branch      # ask which branch to use
  clear
  install_dependencies # make sure we have the latest deps
  update_system       # update all the system libraries
  git_checkout_branch # check out our branch
  clear
  autogen             # run ./autogen.sh
  configure           # run ./configure
  compile             # make and make install
  stop_syscoind       # stop syscoind if it is running
  make_install        # install the binaries

  # maybe upgrade sentinel
  if [ "$IS_UPGRADE_SENTINEL" = "" ] || [ "$IS_UPGRADE_SENTINEL" = "y" ] || [ "$IS_UPGRADE_SENTINEL" = "Y" ]; then
    install_sentinel
    install_virtualenv
    configure_sentinel
  fi

  start_syscoind      # start syscoind back up
  
  echo "$MESSAGE_COMPLETE"
  echo "Syscoin Core update complete using https://www.github.com/syscoin/syscoin/tree/${SYSCOIN_BRANCH}!"
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
  read -e -p "Upgrade/recompile Syscoin Core? [Y/n]: " IS_UPGRADE
  if [ "$IS_UPGRADE" = "" ] || [ "$IS_UPGRADE" = "y" ] || [ "$IS_UPGRADE" = "Y" ]; then
    read -e -p "Upgrade Sentinel as well? [Y/n]: " IS_UPGRADE_SENTINEL
    upgrade
  fi
fi
clear

RESOLVED_ADDRESS=$(curl -s ipinfo.io/ip)

echo "$MESSAGE_CONFIGURE"
echo ""
echo "This script has been tested on Ubuntu 18.04 LTS x64."
echo ""
echo "Before starting script ensure you have: "
echo ""
echo "  - Sent 100,000SYS to your masternode address"
echo "  - Run 'masternode genkey' and 'masternode outputs' and recorded the outputs" 
echo "  - Added masternode config file"
echo "    - addressAlias vpsIp:8369 masternodePrivateKey transactionId outputIndex"
echo "    - EXAMPLE: mn1 ${RESOLVED_ADDRESS}:8369 ctk9ekf0m3049fm930jf034jgwjfk zkjfklgjlkj3rigj3io4jgklsjgklsjgklsdj 0"
echo "  - Restarted Syscoin-Qt"
echo ""
echo "Default values are in brackets [default] or capitalized [Y/n] - pressing enter will use this value."
echo ""
echo "$HBAR"
echo ""

SYSCOIN_BRANCH="master"
DEFAULT_PORT=8369

# syscoin.conf value defaults
rpcuser="sycoinrpc"
rpcpassword="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
masternodeprivkey=""
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

masternode_private_key(){
  read -e -p "Masternode Private Key [$masternodeprivkey]: " MASTERNODE_PRIVATE_KEY
  if [ "$MASTERNODE_PRIVATE_KEY" = "" ]; then
    if [ "$masternodeprivkey" != "" ]; then
      MASTERNODE_PRIVATE_KEY="$masternodeprivkey"
    else
      echo "You must enter a masternode private key!";
      masternode_private_key
    fi
  fi
}


masternode_private_key

read -e -p "Configure for mainnet? [Y/n]: " IS_MAINNET

#Generating Random Passwords
RPC_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

pause
clear

# syscoin conf file
SYSCOIN_CONF=$(cat <<EOF
# rpc config
rpcuser=user
rpcpassword=$RPC_PASSWORD
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
rpcport=8370
# syscoind config
listen=1
server=1
daemon=1
maxconnections=24
# masternode config
masternode=1
masternodeprivkey=$MASTERNODE_PRIVATE_KEY
externalip=$EXTERNAL_ADDRESS
port=$MASTERNODE_PORT
EOF
)

# testnet config
SYSCOIN_TESTNET_CONF=$(cat <<EOF
# testnet config
gethtestnet=1
addnode=54.203.169.179
addnode=54.190.239.153
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
ExecReload=/usr/local/bin/syscoin-cli stop && sleep 20 && /usr/local/bin/syscoind
 
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
  grep -q "sysmasternode\(\)" ~/.bashrc || echo "sysmasternode() { bash <(curl -sL https://raw.githubusercontent.com/Syscoin/Masternode-install-script/master/script.sh) ; }" >> ~/.bashrc

  echo "$SYSCOIN_CONF" > ~/syscoin.conf
  if [ ! "$IS_MAINNET" = "" ] && [ ! "$IS_MAINNET" = "y" ] && [ ! "$IS_MAINNET" = "Y" ]; then
    echo "$SYSCOIN_TESTNET_CONF" >> ~/syscoin.conf
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
  sudo apt-get install ufw -y
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 8369/tcp
  sudo ufw allow 30303/tcp
  yes | sudo ufw enable
  clear
}

get_masternode_status(){
  echo ""
  sudo su -c "syscoin-cli mnsync status" syscoin && \
  sudo su -c "syscoin-cli masternode status" syscoin
  echo ""
  read -e -p "Check again? [Y/n]: " CHECK_AGAIN
  if [ "$CHECK_AGAIN" = "" ] || [ "$CHECK_AGAIN" = "y" ] || [ "$CHECK_AGAIN" = "Y" ]; then
    get_masternode_status
  fi
}

# if there is <4gb and the user said yes to a swapfile...
maybe_create_swap_file

# prepare to build
update_system
install_dependencies
git_clone_repository
git_checkout_branch
clear

# run the build steps
autogen
configure
compile
make_install
clear

create_and_configure_syscoin_user
create_systemd_syscoind_service
start_syscoind
install_sentinel
install_virtualenv
configure_sentinel
install_fail2ban
install_ufw
clear

echo "$MESSAGE_COMPLETE"
echo ""
echo "Your masternode configuration should now be completed and running as the syscoin user."
echo "If you see MASTERNODE_SYNC_FINISHED return to Syscoin-Qt and start your node, otherwise check again."

get_masternode_status

# ping sentinel
sudo su -c "sentinel-ping" syscoin

echo ""
echo "Masternode setup complete!"
echo ""
echo "======================================================================================"
echo "Please run the following command to access syscoin-cli from this session or re-login."
echo "======================================================================================"
echo ""
echo "  source ~/.bashrc"
echo ""
echo "======================================================================================"
echo "You can run syscoin-cli commands as the syscoin user: "
echo "======================================================================================"
echo ""
echo "  syscli getblockchaininfo"
echo "  syscli masternode status"
echo ""
echo "======================================================================================"
echo "To update this masternode just type:"
echo "======================================================================================"
echo ""
echo "        sysmasternode"

do_exit
