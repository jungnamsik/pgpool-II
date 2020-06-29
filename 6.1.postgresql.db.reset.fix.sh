
# pg01


#pg02,03
sudo systemctl stop postgresql
rm -rf /u01/pg12/data/*
rm -rf /u02/archive/*

repmgr -h pg01 -U repmgr -d repmgr -D /u01/pg12/data -f /etc/repmgr/12/repmgr.conf standby clone
repmgr -h pg02 -U repmgr -d repmgr -D /u01/pg12/data -f /etc/repmgr/12/repmgr.conf standby clone
repmgr -h pg03 -U repmgr -d repmgr -D /u01/pg12/data -f /etc/repmgr/12/repmgr.conf standby clone
sudo systemctl start postgresql

repmgr -f /etc/repmgr/12/repmgr.conf standby register --force



#--------------------------------------------------------
rm -rf $PGDATA/standby.signal

sudo systemctl restart postgresql
repmgr -f /etc/repmgr/12/repmgr.conf -v master register --force




psql -U repmgr -c "truncate table repmgr.events             "
psql -U repmgr -c "truncate table repmgr.monitoring_history "
psql -U repmgr -c "truncate table repmgr.nodes              "
psql -U repmgr -c "truncate table repmgr.voting_term        "


psql -c "drop extension pgpool_recovery;" -d template1
psql -c "drop extension pgpool_adm;"

psql -c "create extension pgpool_recovery;" -d template1
psql -c "create extension pgpool_adm;"

truncate table repmgr.events             ;
truncate table repmgr.monitoring_history ;
truncate table repmgr.nodes              ;
truncate table repmgr.voting_term        ;




ip_w.sh addr add 192.168.79.99/24 dev enp0s9 label enp0s9:0



# psql -c "create user repmgr with superuser login password 'rep123' ;"
# psql -c "alter user repmgr set search_path to repmgr,"$user",public;"


# on pg01 as user postgres
#@=====[repmgr db 생성]
psql --command "drop database repmgr ;"
psql --command "create database repmgr with owner=repmgr ENCODING='UTF8' LC_COLLATE='en_US.UTF8';"


sudo systemctl restart postgresql

bash 2.2.repmgr.config.sh


psql -c "drop extension pgpool_recovery;" -d template1
psql -c "drop extension pgpool_adm;"

psql -c "create extension pgpool_recovery;" -d template1
psql -c "create extension pgpool_adm;"



