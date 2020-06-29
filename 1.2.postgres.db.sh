# as user postgres
#su - postgres

#@=====[1.db 초기화 ]
# check that PGDATA and the PATH are correct
echo $PGDATA
echo $PATH
pg_ctl -D ${PGDATA} initdb -o "--auth=trust --encoding=UTF8 --locale='en_US.UTF8'"

#@=====[2.db postgresql.conf 환경 / 사용자 환경파일 추가 ]
# as user postgres
mkdir $PGDATA/conf.d

echo "include_dir = 'conf.d'" >> $PGDATA/postgresql.conf
# now let's add some config in this conf.d directory
cat <<EOF > $PGDATA/conf.d/custom.conf
log_destination = 'syslog,csvlog'
logging_collector = on
# better to put the logs outside PGDATA so they are not included in the base_backup
log_directory = '/var/log/postgres'
log_filename = 'postgresql-%Y-%m-%d.log'
log_truncate_on_rotation = on
log_rotation_age = 1d
log_rotation_size = 0
# These are relevant when logging to syslog (if wanted, change log_destination to 'csvlog,syslog')
log_min_duration_statement=-1
log_duration = on
log_line_prefix='%m %c %u - ' 
log_statement = 'all'
log_connections = on
log_disconnections = on
log_checkpoints = on
# log_timezone = 'Asia/Seoul'
# up to 30% of RAM. Too high is not good.
shared_buffers = 512MB
#checkpoint at least every 15min
checkpoint_timeout = 15min 
#if possible, be more restrictive
listen_addresses='*'
#for standby
max_replication_slots = 5
archive_mode = on
archive_command = '/opt/postgres/scripts/archive.sh  %p %f'
# archive_command = '/bin/true'
wal_level = replica
max_wal_senders = 5
hot_standby = on
hot_standby_feedback = on
# for pg_rewind
wal_log_hints=true
EOF

#@=====[3.archive 경로 생성 ]
sudo mkdir /var/log/postgres
sudo chown postgres:postgres /var/log/postgres

#@=====[4.acchive 실행 환경 생성: 경로]
sudo mkdir -p /opt/postgres/scripts
sudo chown -R postgres:postgres /opt/postgres

#@=====[5.acchive 실행 스크립트]
cat <<EOF > /opt/postgres/scripts/archive.sh
#!/bin/bash

LOGFILE=/var/log/postgres/archive.log
if [ ! -f \$LOGFILE ] ; then
 touch \$LOGFILE
fi
echo "archiving \$1 to /u02/archive/\$2"
cp \$1 /u02/archive/\$2
exit \$?
EOF

#@=====[5.acchive 실행 스크립트 실행 권한 +]
chmod +x /opt/postgres/scripts/archive.sh



