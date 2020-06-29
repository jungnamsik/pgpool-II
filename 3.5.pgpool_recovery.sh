
NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}

#@=====[create extension :pgpool_recovery, pgpool_adm ]
# on pg01 as user postgres : pg02, pg03은 read only로 오류
if [ "${NODE_NAME}" = "pg01" ]; then
  # on the primary db only
  psql -c "create extension pgpool_recovery;" -d template1
  psql -c "create extension pgpool_adm;"
fi


#@=====[/opt/pgpool/scripts/pgpool_recovery.sh 작성 ]
cat <<EOF > /opt/pgpool/scripts/pgpool_recovery.sh
#!/bin/bash
PGVER=12
# This script erase an existing replica and re-base it based on
# the current primary node. Parameters are position-based and include:
#
# 1 - Path to primary database directory.
# 2 - Host name of new node.
# 3 - Path to replica database directory
#
# Be sure to set up public SSH keys and authorized_keys files.
# this script must be in PGDATA

PGVER=\${PGVER:-11}
ARCHIVE_DIR=/u02/archive

LOGFILE=/var/log/pgpool/pgpool_recovery.log
if [ ! -f \$LOGFILE ] ; then
 touch \$LOGFILE
fi

log_info(){
 echo \$( date +"%Y-%m-%d %H:%M:%S.%6N" ) - INFO - \$1 | tee -a \$LOGFILE
}

log_error(){
 echo \$( date +"%Y-%m-%d %H:%M:%S.%6N" ) - ERROR - \$1 | tee -a \$LOGFILE
}

log_info "executing pgpool_recovery at `date` on `hostname`"


PATH=\$PATH:/usr/pgsql-\${PGVER}/bin

if [ \$# -lt 3 ]; then
    echo "Create a replica PostgreSQL from the primary within pgpool."
    echo
    echo "Usage: \$0 PRIMARY_PATH HOST_NAME COPY_PATH"
    echo
    exit 1
fi
# to do is hostname -i always OK ? Find other way to extract the host. maybe from repmgr.conf ?
primary_host=\$(hostname -i) # not working on SCM
replica_host=\$2
replica_path=\$3
log_info "primary_host: \${primary_host}"
log_info "replica_host: \${replica_host}"
log_info "replica_path: \${replica_path}"
ssh_copy="ssh -p 22 postgres@\$replica_host -T -n -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
log_info "Stopping postgres on \${replica_host}"
\$ssh_copy "sudo systemctl stop postgresql"
log_info sleeping 10
sleep 10
log_info "delete database directory on \${replica_host}"
\$ssh_copy "rm -Rf \$replica_path/* \$ARCHIVE_DIR/*"
log_info "let us use repmgr on the replica host to force it to sync again"
\$ssh_copy "/usr/pgsql-\${PGVER}/bin/repmgr -h \${primary_host} --username=repmgr -d repmgr -D \${replica_path} -f /etc/repmgr/\${PGVER}/repmgr.conf standby clone -v"
log_info "Start database on \${replica_host} "
\$ssh_copy "sudo systemctl start postgresql"
log_info sleeping 20
sleep 20
log_info "Register standby database"
\$ssh_copy "/usr/pgsql-\${PGVER}/bin/repmgr -f /etc/repmgr/\${PGVER}/repmgr.conf standby register -F -v"
EOF

chmod 774 /opt/pgpool/scripts/pgpool_recovery.sh
#@=====[/opt/pgpool/scripts/pgpool_recovery.sh 복사. pg02, pg03 ]
cp /opt/pgpool/scripts/pgpool_recovery.sh $PGDATA/pgpool_recovery.sh
scp /opt/pgpool/scripts/pgpool_recovery.sh pg02.localnet:$PGDATA/
scp /opt/pgpool/scripts/pgpool_recovery.sh pg03.localnet:$PGDATA/




