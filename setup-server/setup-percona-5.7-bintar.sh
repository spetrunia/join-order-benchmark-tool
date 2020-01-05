#!/bin/bash

wget https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-5.7.20-19/binary/tarball/Percona-Server-5.7.20-19-Linux.x86_64.ssl100.tar.gz

tar zxvf Percona-Server-5.7.20-19-Linux.x86_64.ssl100.tar.gz
cd Percona-Server-5.7.20-19-Linux.x86_64.ssl100
cd mysql-test
perl ./mysql-test-run alias
cp -r var/install.db ~/ps-data1
cd ..
cd ..

ln -s `pwd`/ps-data1 /tmp/percona-server-datadir

cat > my-percona-server.cnf <<EOF

[mysqld]
datadir=/tmp/percona-server-datadir

log-bin=pslp2
tmpdir=/tmp
port=3306
socket=/tmp/mysql10.sock
binlog-format=row
gdb
lc_messages_dir=./share
server-id=12
bind-address=0.0.0.0
log-error

plugin-dir=./lib/mysql/plugin
plugin-load=ha_rocksdb.so

EOF

#cd Percona-Server-5.7.20-19-Linux.x86_64.ssl100/
#./bin/mysqld --defaults-file=../my-percona-server.cnf

