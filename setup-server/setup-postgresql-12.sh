PG_VERSION="12.1"

wget https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2
tar jxvf postgresql-$PG_VERSION.tar.bz2
HOMEDIR=`pwd`
(
  cd postgresql-$PG_VERSION
  ./configure --prefix=$HOMEDIR/postgresql-$PG_VERSION-inst
  make -j10
  make install
)
export PGDATA=$HOMEDIR/pgdata

# TODO: something better:
killall postgres
sleep 10

./postgresql-$PG_VERSION-inst/bin/initdb

./postgresql-$PG_VERSION-inst/bin/pg_ctl -D $PGDATA -l pglogfile start

# ALTER SYSTEM SET shared_buffers TO '4096MB';
./postgresql-$PG_VERSION-inst/bin/createdb test

echo "ALTER SYSTEM SET shared_buffers TO '4096MB';" |
 ./postgresql-$PG_VERSION-inst/bin/psql test

./postgresql-$PG_VERSION-inst/bin/pg_ctl -D $PGDATA  stop
./postgresql-$PG_VERSION-inst/bin/pg_ctl -D $PGDATA -l pglogfile start

echo "PSQL=\"./postgresql-$PG_VERSION-inst/bin/psql\"" > psql-vars.sh
