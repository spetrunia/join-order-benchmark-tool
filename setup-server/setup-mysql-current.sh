#!/bin/bash

if [ "x${1}y" == "xy" ] ; then 
  echo "Usage: $0 BRANCH_NAME"
  exit 1
fi

BRANCH="${1}"
HOMEDIR=`pwd`
DATADIR="$HOMEDIR/mysql-$BRANCH-data"

if [ -d $DATADIR ] ; then
  echo "Data directory $DATADIR exists, will not overwrite it "
  du -hs $DATADIR
fi

if [ ! -d $HOMEDIR/mysql-$BRANCH ]; then

  if command -v offline-git-clone-mysql.sh >/dev/null 2>&1; then
    offline-git-clone-mysql.sh --branch=$BRANCH mysql-$BRANCH
    if [[ $? -ne 0 ]]; then
      echo "Failed to setup MySQL repo"
      exit 1
    fi
  else
    git clone --branch $BRANCH --depth 1 https://github.com/mysql/mysql-server.git mysql-$BRANCH
    if [[ $? -ne 0 ]]; then
      echo "Failed to setup MySQL repo"
      exit 1
    fi
  fi
  
  (
    cd mysql-$BRANCH

    rm -rf build
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDOWNLOAD_BOOST=1 \
      -DWITH_BOOST=`pwd`/../mysql8-boost-rel \
      -DENABLE_DOWNLOADS=1 -DWITH_UNIT_TESTS=0 && \
    make -j8

    cd mysql-test
    perl ./mysql-test-run alias
    cp -r var/data $DATADIR
  )

fi

cat > $HOMEDIR/my-mysql-$BRANCH.cnf <<EOF

[mysqld]
datadir=$DATADIR

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

cat > mysql-$BRANCH-vars.sh <<EOF
MYSQL_CMD="./mysql-$BRANCH/build/runtime_output_directory/mysql"
MYSQL_SOCKET="--socket=/tmp/mysql20.sock"
MYSQL_USER="-uroot"
MYSQL_ARGS="\$MYSQL_USER \$MYSQL_SOCKET"

MYSQL="./mysql-$BRANCH/build/runtime_output_directory/mysql --socket=/tmp/mysql20.sock -uroot"
MYSQLD="$HOMEDIR/mysql-$BRANCH/build/runtime_output_directory/mysqld --defaults-file=$HOMEDIR/my-mysql-$BRANCH.cnf"
EOF

cp mysql-$BRANCH-vars.sh mysql-vars.sh 

(
  cd $HOMEDIR/mysql-$BRANCH/sql
  ../build/runtime_output_directory/mysqld --defaults-file=$HOMEDIR/my-mysql-$BRANCH.cnf &
)

source mysql-$BRANCH-vars.sh
client_attempts=0
while true ; do
  echo $MYSQL_CMD $MYSQL_ARGS -e "select version()";
  $MYSQL_CMD $MYSQL_ARGS -e "select version()";

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

echo "Done setting up MySQL $BRANCH"
