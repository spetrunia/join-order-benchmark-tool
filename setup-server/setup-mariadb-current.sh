#!/bin/bash

#set -e

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
fi

if [ ! -d $HOMEDIR/mariadb-$BRANCH ]; then

  if command -v offline-git-clone-mariadb.sh >/dev/null 2>&1; then
    offline-git-clone-mariadb.sh --branch=$BRANCH mariadb-$BRANCH
    if [[ $? -ne 0 ]]; then
      echo "Failed to setup MariaDB"
      exit 1
    fi
  else
    git clone --branch $BRANCH --depth 1 https://github.com/MariaDB/server.git mariadb-$BRANCH &&
    (
      cd mariadb-$BRANCH &&
      git submodule init  &&
      git submodule update
    )
  fi

  (
    cd mariadb-$BRANCH
    cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DWITHOUT_MROONGA:bool=1 -DWITHOUT_TOKUDB:bool=1 \
      -DWITH_EMBEDDED_SERVER:bool=0 -DWITH_UNIT_TESTS:bool=0
    make -j8
  )

  (
    cd mariadb-$BRANCH/mysql-test
    ./mtr alias
    chmod -R +rw var/install.db 
    cp -r var/install.db $DATADIR
  )
fi

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
[mariadbd]

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

cat > mariadb-$BRANCH-vars.sh <<EOF
MYSQL_CMD="./mariadb-$BRANCH/client/mariadb"
MYSQL_SOCKET="--socket=$SOCKETNAME"
MYSQL_USER="-uroot"
MYSQL_ARGS="\$MYSQL_USER \$MYSQL_SOCKET"

MYSQL="./mariadb-$BRANCH/client/mariadb --socket=$SOCKETNAME -uroot"
MYSQLD="$HOMEDIR/mariadb-$BRANCH/sql/mariadbd --defaults-file=$HOMEDIR/my-mariadb-$BRANCH.cnf"
EOF

source mariadb-$BRANCH-vars.sh
cp mariadb-$BRANCH-vars.sh mysql-vars.sh 


check_server(){
    if pgrep -f "mariadbd.*$BRANCH" > /dev/null 2>&1 ; then
       return 0
    else
       return 1
    fi
}

start_server(){
echo "Starting server"
(
cd $HOMEDIR/mariadb-$BRANCH/sql
./mariadbd --defaults-file=$HOMEDIR/my-mariadb-$BRANCH.cnf &
)
}


if check_server; then
   echo "Server already running"
   exit 1;
else
   start_server
fi

bash ./setup-server/wait_for_start.sh

echo "Done setting up MariaDB"

