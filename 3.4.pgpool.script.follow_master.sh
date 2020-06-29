#@=====[/opt/pgpool/scripts/follow_master.sh 작성]

cat <<EOF >  /opt/pgpool/scripts/follow_master.sh
#!/bin/bash
PGVER=12
LOGFILE=/var/log/pgpool/follow_master.log
if [ ! -f \$LOGFILE ] ; then
 > \$LOGFILE
fi
PGVER=\${PGVER:-11}

echo "executing follow_master.sh at `date`"  | tee -a \$LOGFILE

NODEID=\$1
HOSTNAME=\$2
NEW_MASTER_ID=\$3
PORT_NUMBER=\$4
NEW_MASTER_HOST=\$5
OLD_MASTER_ID=\$6
OLD_PRIMARY_ID=\$7
PGDATA=\${PGDATA:-/u01/pg\${PGVER}/data}
(
echo NODEID=\${NODEID}
echo HOSTNAME=\${HOSTNAME}
echo NEW_MASTER_ID=\${NEW_MASTER_ID}
echo PORT_NUMBER=\${PORT_NUMBER}
echo NEW_MASTER_HOST=\${NEW_MASTER_HOST}
echo OLD_MASTER_ID=\${OLD_MASTER_ID}
echo OLD_PRIMARY_ID=\${OLD_PRIMARY_ID}
echo PGDATA=\${PGDATA}
if [ \$NODEID -eq \$OLD_PRIMARY_ID ] ; then
  echo "Do nothing as this is the failed master. We could prevent failed master to restart here, so that we can investigate the issue" | tee -a \$LOGFILE
else
  ssh_options="ssh -p 22 -n -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  set -x
  # if this node is not currently standby then it might be an old master that went back up after a failover occured
  # if this is the case we cannot do the follow master command on this node, we should leave it alone
  in_reco=\$( \$ssh_options postgres@\${HOSTNAME} 'psql -t -c "select pg_is_in_recovery();"' | head -1 | awk '{print \$1}' )
  echo "pg_is_in_recovery on \$HOSTNAME is \$in_reco " | tee -a \$LOGFILE
  if [ "a\${in_reco}" != "at" ] ; then
    echo "node \$HOSTNAME is not in recovery, probably a degenerated master, skip it" | tee -a \$LOGFILE
    exit 0
  fi
  \$ssh_options postgres@\${HOSTNAME} "/usr/pgsql-\${PGVER}/bin/repmgr --log-to-file -f /etc/repmgr/\${PGVER}/repmgr.conf -h \${NEW_MASTER_HOST} -D \${PGDATA} -U repmgr -d repmgr standby follow -v "
  # TODO: we should check if the standby follow worked or not, if not we should then do a standby clone command
  echo "Sleep 10"
  sleep 10
  echo "Attach node \${NODEID}"
  pcp_attach_node -h localhost -p 9898 -w \${NODEID}
fi
) 2>&1 | tee -a \$LOGFILE
EOF

sudo chmod +x /opt/pgpool/scripts/follow_master.sh

#@=====[/opt/pgpool/scripts/follow_master.sh 복사:pg02, pg03]

scp /opt/pgpool/scripts/follow_master.sh pg02.localnet:/opt/pgpool/scripts/follow_master.sh
scp /opt/pgpool/scripts/follow_master.sh pg03.localnet:/opt/pgpool/scripts/follow_master.sh


