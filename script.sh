#!/bin/bash

update_system(){
  echo "UPDATING SYSTEM"
  # update package and upgrade Ubuntu
  sudo DEBIAN_FRONTEND=noninteractive apt -y update
  sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade
  sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
  sudo apt install git -y
  clear
}

install_ufw(){
  echo "INSTALLING UFW"
  sudo apt-get install ufw -y
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 8369/tcp
  sudo ufw allow 30303/tcp
  yes | sudo ufw enable
  clear
}

install_swap(){
    echo "CREATING SWAP FILE"
    sudo swapoff -a
    sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee --append /etc/fstab > /dev/null
    sudo mount -a
}

install_dependencies(){
  echo "ISNTALLING DEPENDENCIES"
  # git
  sudo apt install -y git
  # build tools
  sudo apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common
  # boost
  sudo apt install -y libboost-all-dev
  # bdb 4.8
  sudo add-apt-repository -y ppa:bitcoin/bitcoin
  sudo apt update -y
  sudo apt install -y libdb4.8-dev libdb4.8++-dev
  # zmq
  sudo apt install -y libzmq3-dev
  clear
}

git_clone_repository(){
  echo "CLONING REPO"
  cd
  if [ ! -d ~/syscoin ]; then
    git clone https://github.com/syscoin/syscoin.git
  fi
}

git_checkout_branch(){
  echo "CHECKING OUT BRANCH"
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
  echo "COMPLETING AUTOGEN"
  cd ~/syscoin
  ./autogen.sh
  clear
}

configure(){
  echo "COMPLETING CONFIGURE"
  cd ~/syscoin
  ./configure --without-gui
  clear
}

compile(){
  echo "COMPLETING MAKE"
  cd ~/syscoin
  make -j$(nproc) -pipe
  clear
}

create_syscoin_config(){
  echo "CREATING SYSCOIN CONF"
  mkdir ~/.syscoin
  echo "$SYSCOIN_CONF" > ~/.syscoin/syscoin.conf
}

start_syscoind(){
  echo "STARTING SYSCOIND"
  cd ~/syscoin/src
  ./syscoind -daemon
  echo "Waiting 30secs for syscoind to start up"
  sleep 30s
  clear
}

get_masternode_status(){
  echo "CHECKING GETH AND MNSYNC"
  cd ~/syscoin/src
  ./syscoin-cli getblockchaininfo && \
  ./syscoin-cli mnsync status
  echo ""
  read -e -p "Check again? Make sure geth is synced and mnsync is finished, then press n and enter [Y/n]: " CHECK_AGAIN
  if [ "$CHECK_AGAIN" = "" ] || [ "$CHECK_AGAIN" = "y" ] || [ "$CHECK_AGAIN" = "Y" ]; then
    get_masternode_status
  fi
}

stop_syscoind(){
  echo "STOPPING SYSCOIND AND ADJUSTING SYSCOIN.CONF & MASTERNODE.CONF"
  cd ~/syscoin/src
  ./syscoin-cli stop
  echo "$SYSCOIN_CONF_MN" > ~/.syscoin/syscoin.conf
  echo "$MASTERNODE_CONF" > ~/.syscoin/masternode.conf
}

install_sentinel(){
  echo "INSTALLING SENTINEL"
  ~/syscoin/src/syscoind
  echo "Waiting 30secs for syscoind to start up"
  sleep 30s
  cd ~/syscoin/src
  sudo apt-get update
  sudo apt-get install -y git python-virtualenv
  git clone https://github.com/syscoin/sentinel.git
  cd sentinel
  git checkout sys4
  echo "$SENTINEL_CONF" > sentinel.conf
  echo "installed sentinel conf"
  sudo apt-get install -y virtualenv
  virtualenv venv
  venv/bin/pip install -r requirements.txt
  venv/bin/python bin/sentinel.py
  clear
}

# syscoin.conf value defaults
SYSCOIN_CONF=$(cat <<EOF
rpcuser=username
rpcpassword=password
rpcport=8370
addnode=54.203.169.179
addnode=54.190.239.153
gethtestnet=1
EOF
)

# syscoin.conf value new defaults
SYSCOIN_CONF_MN=$(cat <<EOF
rpcuser=username
rpcpassword=password
rpcport=8370
addnode=54.203.169.179
addnode=54.190.239.153
gethtestnet=1
listen=1
server=1
daemon=1
maxconnections=24
#
masternode=1
masternodeprivkey=5KTY4BjXSkWyikEPKJSBUfrqqT9KXeyobj9yBFndwN1g6usQciH
externalip=157.230.220.228
port=8369
EOF
)

MASTERNODE_CONF=$(cat <<EOF
#please delete below as this is just fillers just to get syscoind running properly during startup
mn1 157.230.220.228:8369 5KTY4BjXSkWyikEPKJSBUfrqqT9KXeyobj9yBFndwN1g6usQciH fff7c491f1a14cf440625dda9d2a450151aa9ab40b623e23763f320a2f007871 1
EOF
)

# SENTINEL.conf value defaults
SENTINEL_CONF=$(cat <<EOF
# syscoin conf location
syscoin_conf=/home/root/.syscoin/syscoin.conf

# db connection details
db_name=database/sentinel.db
db_driver=sqlite
EOF
)

SYSCOIN_BRANCH="dev-4.x"

pause
clear

# prepare to build
update_system
install_ufw
install_swap
install_dependencies
git_clone_repository
git_checkout_branch
clear

# run the build steps
autogen
configure
compile
create_syscoin_config
start_syscoind
clear

#check sync and move on
get_masternode_status
stop_syscoind
install_sentinel

echo "Just a couple more things to do!."
echo ""
echo "1. Create your Masternode Genkey and address - get your tSys"
echo "2. Edit syscoin.conf for your genkey and your IP address"
echo "3. Edit masternode.conf"
echo "4. Restart syscoind"
echo "5. Recheck mnsync"
echo "6. Once synced - masternode start-all"
