#!/bin/bash

if [ -e /etc/debian_version ] ; then
  sudo apt-get update
  sudo apt-get -y install g++ cmake libbz2-dev libaio-dev bison \
    zlib1g-dev libsnappy-dev libboost-all-dev
  sudo apt-get -y install libgflags-dev libreadline6-dev libncurses5-dev \
    libssl-dev liblz4-dev gdb git libzstd-dev libzstd0

  sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/libz.so
fi

git clone https://github.com/facebook/mysql-5.6.git
cd mysql-5.6
git submodule init
git submodule update
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SSL=system \
  -DWITH_ZLIB=bundled -DMYSQL_MAINTAINER_MODE=0 -DENABLED_LOCAL_INFILE=1 \
  -DENABLE_DTRACE=0 -DCMAKE_CXX_FLAGS="-march=native"
make -j8

cd mysql-5.6/mysql-test
./mtr alias
cp -r var/install.db ~/data-fbmysql
ln -s ~/data-fbmysql /tmp/fbmysql-datadir 
cd ../..

cat > my-fbmysql.cnf << EOF
[mysqld]

datadir=/tmp/fbmysql-datadir

default-storage-engine=rocksdb
skip-innodb
default-tmp-storage-engine=MyISAM
rocksdb

#debug
log-bin=pslp
binlog-format=row

tmpdir=/tmp
port=3306
socket=/tmp/mysql.sock
gdb

language=./share/english
server-id=12

EOF

#(cd ./mysql-5.6/sql; ./mysqld --defaults-file=../../my-fbmysql.cnf & )


