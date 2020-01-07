#!/bin/bash

HOMEDIR=`pwd`

BRANCH=8.0
SERVER_VERSION=8.0

git clone --branch $BRANCH --depth 1 https://github.com/mysql/mysql-server.git mysql-$SERVER_VERSION

cd mysql-$SERVER_VERSION
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$HOMEDIR/mysql-boost \
 -DENABLE_DOWNLOADS=1 -DFORCE_INSOURCE_BUILD=1 -DWITH_UNIT_TESTS=0

make -j8

cd mysql-test
perl ./mysql-test-run alias
cp -r var/data $HOMEDIR/mysql8-data
cd ..


cat > $HOMEDIR/my-mysql-8.0.cnf <<EOF

[mysqld]
datadir=$HOMEDIR/mysql8-data

tmpdir=/tmp
port=3320
socket=/tmp/mysql20.sock
#binlog-format=row
gdb
lc_messages_dir=../share
server-id=12
bind-address=0.0.0.0
log-error
secure_file_priv=
innodb_buffer_pool_size=4G
EOF

cat > ../mysql-vars.sh <<EOF
MYSQL="./mysql-$SERVER_VERSION/bin/mysql"
MYSQL_SOCKET="--socket=/tmp/mysql20.sock"
MYSQL_USER="-uroot"
MYSQL_ARGS="\$MYSQL_USER \$MYSQL_SOCKET"
EOF

cp mysql-vars.sh mysql-$BRANCH-vars.sh

cd $HOMEDIR/mysql-$SERVER_VERSION/sql
../runtime_output_directory/mysqld --defaults-file=$HOMEDIR/my-mysql-8.0.cnf &

cd $HOMEDIR

source mysql-vars.sh
client_attempts=0
while true ; do
  echo $MYSQL $MYSQL_ARGS -e "select version()";
  $MYSQL $MYSQL_ARGS -e "select version()";

  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1

  client_attempts=$((client_attempts + 1))
  if [ $client_attempts -ge 30 ]; then
    echo "Failed to start server."
    exit 1
  fi
done

echo "Done setting up MySQL 8"
