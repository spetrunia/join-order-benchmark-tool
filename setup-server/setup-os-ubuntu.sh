#!/bin/bash

if [ -e /etc/debian_version ] ; then
  sudo apt-get update
  sudo apt-get -y install g++ cmake libbz2-dev libaio-dev bison zlib1g-dev libsnappy-dev libboost-all-dev
  sudo apt-get -y install libgflags-dev libreadline6-dev libncurses5-dev liblz4-dev gdb git libzstd-dev

  sudo apt-get -y install libzstd0
  sudo apt-get -y install libssl-dev
  
  sudo apt-get -y install libgnutls28-dev

# percona server:
  sudo apt-get -y install libcurl4-gnutls-dev

  sudo apt-get -y install sysstat

  sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/libz.so
  sudo sh -c "echo 0 > /proc/sys/kernel/yama/ptrace_scope"

# Need unzip to unpack TPC-DS generator
  sudo apt-get -y install unzip
fi

