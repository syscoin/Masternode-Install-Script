#!/bin/bash

source https://github.com/bigpoppa-sys/sysmn/edit/master/mn-script.sh

update_system(){
  echo "UPDATING SYSTEM"
  sudo DEBIAN_FRONTEND=noninteractive apt -y update
  sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade
  sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
  sudo apt install git -y
  clear
}

install_ufw(){
  echo "ISNTALLING SWAP FILES"
  sudo apt-get install ufw -y
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 8369/tcp
  sudo ufw allow 30303/tcp
  yes | sudo ufw enable
  clear
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

syscoin_branch(){
  read -e -p "Syscoin Core Github Branch [ testnet ]: " SYSCOIN_BRANCH
  if [ "$SYSCOIN_BRANCH" = "" ]; then
    SYSCOIN_BRANCH="dev-4.x"
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
  cd ~/syscoin
  ./autogen.sh
  clear
}

configure(){
  cd ~/syscoin
  ./configure --without-gui
  clear
}

compile(){
  echo "Running compile with $(nproc) core(s)..."
  cd ~/syscoin
  make -j$(nproc) -pipe
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
listen=1
server=1
daemon=1
maxconnections=24
#
masternode=1
masternodeprivkey=enterYourMasternodePrivKey
externalip=enterYourIpAddress
port=8369
EOF
)


create_syscoin_config(){
  echo "CREATING SYSCOIN CONF"
  mkdir ~/.syscoin
  echo "$SYSCOIN_CONF" > ~/.syscoin/syscoin.conf
}


SYSCOIN_BRANCH="dev-4.x"

pause
clear

# prepare to build
update_system
install_ufw
install_dependencies
git_clone_repository
git_checkout_branch
clear

# run the build steps
autogen
configure
compile
create_syscoin_config
clear

echo "Just a couple more things to do!."
