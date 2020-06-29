# on pg01 as user postgres
PGDBVER=12

NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}

# on ${NODE_NAME} as user postgres
#@=====[repmgr ${NODE_NAME} - repmgr.conf 설정]
# [ -f /etc/repmgr/${PGDBVER}/repmgr.conf.sample ] && /usr/bin/true ||  cp /etc/repmgr/${PGDBVER}/repmgr.conf /etc/repmgr/${PGDBVER}/repmgr.conf.sample
if [ -f /etc/repmgr/${PGDBVER}/repmgr.conf.sample ]; then 
    /usr/bin/true
else
    cp /etc/repmgr/${PGDBVER}/repmgr.conf /etc/repmgr/${PGDBVER}/repmgr.conf.sample
fi

cat <<EOF > /etc/repmgr/${PGDBVER}/repmgr.conf

node_id=${NODE_ID}
node_name='${NODE_NAME}.localnet'
conninfo='host=${NODE_NAME}.localnet dbname=repmgr user=repmgr password=rep123 connect_timeout=2'
data_directory='/u01/pg${PGDBVER}/data'
use_replication_slots=yes
# event_notification_command='/opt/postgres/scripts/repmgrd_event.sh %n "%e" %s "%t" "%d" %p %c %a'
reconnect_attempts=10
reconnect_interval=1

restore_command = 'cp /u02/archive/%f %p'

log_facility=STDERR
failover=manual
monitor_interval_secs=5

pg_bindir='/usr/pgsql-${PGDBVER}/bin'

service_start_command = 'sudo systemctl start postgresql'
service_stop_command = 'sudo systemctl stop postgresql'
service_restart_command = 'sudo systemctl restart postgresql'
service_reload_command = 'pg_ctl reload'

promote_command='repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf standby promote'
follow_command='repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf standby follow -W --upstream-node-id=%n'
EOF


# on ${NODE_NAME} as user postgres

echo "host:${NODE_NAME} => master, standby resister!!"
# on ${NODE_NAME}
if [ "${NODE_NAME}" = "pg01" ]; then
    #@=====[repmgr 기본 데이터베이스로 등록]
    echo "repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf -v master register"
    repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf -v master register
elif [ "${NODE_NAME}" = "pg02" ] || [ "${NODE_NAME}" = "pg03" ]; then
    #@=====[repmgr slave 서버 설정]
    # make sure postgres is not running !
    sudo systemctl stop postgresql
    # on pg02 as user postgres
    rm -rf /u01/pg${PGDBVER}/data/*
    rm -rf /u02/archive/*

    repmgr -h pg01.localnet -U repmgr -d repmgr -D /u01/pg${PGDBVER}/data -f /etc/repmgr/${PGDBVER}/repmgr.conf standby clone
    sudo systemctl start postgresql
    repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf standby register --force
fi

echo "host:${NODE_NAME} => master, standby resister Success!!"
sudo systemctl enable postgresql


if [ "${NODE_NAME}" = "pg01" ]; then
    #@=====[repmgr db - pg02, pg03 환경작업]
    ssh pg02.localnet "mkdir ~/work"
    ssh pg03.localnet "mkdir ~/work"

    scp ~/work/2.2.repmgr.config.sh pg02.localnet:~/work/.
    scp ~/work/2.2.repmgr.config.sh pg03.localnet:~/work/.

    ssh pg02.localnet "bash ~/work/2.2.repmgr.config.sh"
    ssh pg03.localnet "bash ~/work/2.2.repmgr.config.sh"
fi


