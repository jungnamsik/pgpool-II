# on pg01 as user postgres
PGDBVER=12

NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}

if [ "${NODE_NAME}" != "pg01" ]; then
    echo "master db에서 실행되는 스크립트입니다."
    exit 1
fi

psql <<-EOF
  create user repmgr with superuser login password 'rep123' ;
  alter user repmgr set search_path to repmgr,"\$user",public;
  \q
EOF


# on pg01 as user postgres
#@=====[repmgr db 생성]
psql --command "create database repmgr with owner=repmgr ENCODING='UTF8' LC_COLLATE='en_US.UTF8';"


# on pg01 as user postgres
#@=====[repmgr .pgpass 생성 및 복사]
echo "*:*:repmgr:repmgr:rep123" > /home/postgres/.pgpass
echo "*:*:replication:repmgr:rep123" >> /home/postgres/.pgpass
chmod 600 /home/postgres/.pgpass
scp /home/postgres/.pgpass pg02.localnet:/home/postgres/.pgpass 
scp /home/postgres/.pgpass pg03.localnet:/home/postgres/.pgpass 


# on pg01 as user postgres : pg_hba.conf
#@=====[repmgr pg_hba.conf 설정]
cat <<EOF >> $PGDATA/pg_hba.conf
# replication manager
local  replication   repmgr                      trust
host   replication   repmgr      127.0.0.1/32    trust
host   replication   repmgr      0.0.0.0/0       md5
local   repmgr        repmgr                     trust
host    repmgr        repmgr      127.0.0.1/32   trust
host    repmgr        repmgr      127.0.0.1/32   trust
host    repmgr        repmgr      0.0.0.0/0      md5
host    all           all         0.0.0.0/0      md5
EOF

#@=====[postgresql restart]
sudo systemctl restart postgresql



