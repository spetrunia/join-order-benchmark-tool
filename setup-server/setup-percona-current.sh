#!/bin/bash

# This also needs libcurl4-gnutls-dev

BRANCH="${1}"

if [ "x${BRANCH}y" == "xy" ] ; then 
  #echo "Usage: $0 BRANCH_NAME"
  #exit 1
  echo "Using 5.7 by default"
  BRANCH="5.7"
fi


git clone --branch $BRANCH https://github.com/percona/percona-server.git percona-server-$BRANCH

HOMEDIR=`pwd`
(
cd percona-server-$BRANCH
git submodule init
git submodule update
cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$HOMEDIR/percona-server-boost -DENABLE_DOWNLOADS=1 
make -j8
cd .. 
)

DATADIR="$HOMEDIR/percona-server-$BRANCH-data"
(
  cd percona-server-$BRANCH/mysql-test
  ./mtr alias
  cp -r var/install.db $DATADIR
)

cat > $HOMEDIR/my-percona-server-$BRANCH.cnf << EOF
[mysqld]

bind-address=0.0.0.0
datadir=$DATADIR

log-error
lc_messages_dir=$HOMEDIR/percona-server-$BRANCH/sql/share
plugin-dir=$HOMEDIR/percona-server-$BRANCH/storage/rocksdb

tmpdir=/tmp
port=3306
socket=/tmp/mysql20.sock
gdb
server-id=12

innodb_buffer_pool_size=4G

# plugin_load_add=tokudb=ha_tokudb.so;tokudb_trx=ha_tokudb.so;tokudb_locks=ha_tokudb.so;tokudb_lock_waits=ha_tokudb.so;tokudb_fractal_tree_info=ha_tokudb.so;tokudb_background_job_status=ha_tokudb.so;tokudb_file_map=ha_tokudb.so

# plugin_load_add=ha_rocksdb.so

EOF

cd $HOMEDIR/percona-server-$BRANCH/sql
../sql/mysqld --defaults-file=$HOMEDIR/my-percona-server-$BRANCH.cnf


