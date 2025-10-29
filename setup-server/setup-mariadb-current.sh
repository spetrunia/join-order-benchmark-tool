#!/bin/bash

set -e


if [ "x${1}y" == "xy" ] ; then 
  echo "Usage: $0 BRANCH_NAME"
  exit 1
fi


BRANCH="${1}"
HOMEDIR=`pwd`
DATADIR="$HOMEDIR/mariadb-$BRANCH-data"

if [ -d $DATADIR ] ; then
  echo "Data directory $DATADIR exists, will not overwrite it "
  du -hs $DATADIR
  exit 1;
fi

git clone --branch $BRANCH --depth 1 https://github.com/MariaDB/server.git mariadb-$BRANCH

(
cd mariadb-$BRANCH
git submodule init
git submodule update
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DWITHOUT_MROONGA:bool=1 -DWITHOUT_TOKUDB:bool=1 \
  -DWITH_EMBEDDED_SERVER:bool=0 -DWITH_UNIT_TESTS:bool=0
make -j8
cd .. 
)

(
  cd mariadb-$BRANCH/mysql-test
  ./mtr alias
  chmod -R +rw var/install.db 
  cp -r var/install.db $DATADIR
)

# Guess a reasonable socket name
source_dir=`pwd`
socket_name="`basename $source_dir`.sock"
SOCKETNAME="/tmp/$socket_name"


# plugin-load=ha_rocksdb.so
# default-storage-engine=rocksdb
# skip-innodb
# default-tmp-storage-engine=MyISAM
# skip-slave-start
# plugin-dir=$HOMEDIR/mariadb-$BRANCH/storage/rocksdb
# log-bin=pslp
# binlog-format=row

cat > $HOMEDIR/my-mariadb-$BRANCH.cnf << EOF
[mysqld]

bind-address=0.0.0.0
datadir=$DATADIR
plugin-dir=$HOMEDIR/mariadb-$BRANCH/mysql-test/var/plugins

log-error
lc_messages_dir=$HOMEDIR/mariadb-$BRANCH/sql/share

tmpdir=/tmp
port=3341
socket=$SOCKETNAME
gdb
server-id=12

innodb_buffer_pool_size=8G

EOF

cat > mysql-vars.sh <<EOF
MYSQL="./mariadb-$BRANCH/client/mysql"
MYSQL_SOCKET="--socket=$SOCKETNAME"
MYSQL_USER="-uroot"
MYSQL_ARGS="\$MYSQL_USER \$MYSQL_SOCKET"
EOF

source mysql-vars.sh
cp mysql-vars.sh mariadb-$BRANCH-vars.sh

(
cd $HOMEDIR/mariadb-$BRANCH/sql
../sql/mysqld --defaults-file=$HOMEDIR/my-mariadb-$BRANCH.cnf &
)

bash ./setup-server/wait_for_start.sh

echo "Done setting up MariaDB"

