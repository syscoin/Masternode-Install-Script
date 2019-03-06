#!/bin/bash

update_system(){
  echo "UPDATING SYSTEM"
  sudo DEBIAN_FRONTEND=noninteractive apt -y update
  sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade
  sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
  sudo apt install git -y
  clear
}
