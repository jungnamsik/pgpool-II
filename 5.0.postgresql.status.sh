#@=====[ pgpool 상태 확인 ]

# state of pgpool
psql -h 192.168.79.98 -p 9999 -U repmgr -c "show pool_nodes;"

psql -h 192.168.79.98 -p 9999 -U repmgr -c "create table r()"
psql -h 192.168.79.98 -p 9999 -U repmgr -c "drop table r()"

# pg01 is the primary
psql -h pg01.localnet -p 5432 -U repmgr -c "select * from pg_stat_replication;"

psql -h pg02.localnet -p 5432 -U repmgr -c "select * from pg_stat_wal_receiver;"
psql -h pg03.localnet -p 5432 -U repmgr -c "select * from pg_stat_wal_receiver;"


