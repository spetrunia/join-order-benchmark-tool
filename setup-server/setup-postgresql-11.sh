wget https://ftp.postgresql.org/pub/source/v11.2/postgresql-11.2.tar.bz2
tar jxvf postgresql-11.2.tar.bz2
HOMEDIR=`pwd`
(
  cd postgresql-11.2
  ./configure --prefix=$HOMEDIR/postgresql-11.2-inst
  make -j10
  make install
)
export PGDATA=$HOMEDIR/pgdata

./postgresql-11.2-inst/bin/initdb

./postgresql-11.2-inst/bin/pg_ctl -D $PGDATA -l pglogfile start

# ALTER SYSTEM SET shared_buffers TO '4096MB';
./postgresql-11.2-inst/bin/createdb test

echo "ALTER SYSTEM SET shared_buffers TO '4096MB';" |
 ./postgresql-11.2-inst/bin/psql test

./postgresql-11.2-inst/bin/pg_ctl -D $PGDATA  stop
./postgresql-11.2-inst/bin/pg_ctl -D $PGDATA -l pglogfile start

