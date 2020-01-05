#!/bin/bash

sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.netcologne.de/mariadb/repo/10.2/ubuntu xenial main'

sudo apt -y update
sudo sh -c "DEBIAN_FRONTEND=noninteractive apt -y install mariadb-server mariadb-plugin-rocksdb"
sudo sh -c "DEBIAN_FRONTEND=noninteractive apt -y install mariadb-server-10.2-dbgsym  mariadb-server-core-10.2-dbgsym mariadb-plugin-rocksdb-dbgsym"


