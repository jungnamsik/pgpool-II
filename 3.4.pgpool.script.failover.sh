#@=====[/opt/pgpool/scripts/failover.sh 작성]

cat <<EOF > /opt/pgpool/scripts/failover.sh
#!/bin/bash
PGVER=12
LOGFILE=/var/log/pgpool/failover.log
if [ ! -f \$LOGFILE ] ; then
 > \$LOGFILE
fi
# we need this, otherwise it is not set
PGVER=\${PGVER:-11}

#
#failover_command = '/scripts/failover.sh  %d %h %P %m %H %R'
               # Executes this command at failover
               # Special values:
                    #   %d = node id
                    #   %h = host name
                    #   %p = port number
                    #   %D = database cluster path
                    #   %m = new master node id
                    #   %H = hostname of the new master node
                    #   %M = old master node id
                    #   %P = old primary node id
#

FALLING_NODE=\$1            # %d
FALLING_HOST=\$2            # %h
OLD_PRIMARY_ID=\$3          # %P
NEW_PRIMARY_ID=\$4          # %m
NEW_PRIMARY_HOST=\$5        # %H
NEW_MASTER_PGDATA=\$6       # %R
(
date
echo "FALLING_NODE: \$FALLING_NODE"
echo "FALLING_HOST: \$FALLING_HOST"
echo "OLD_PRIMARY_ID: \$OLD_PRIMARY_ID"
echo "NEW_PRIMARY_ID: \$NEW_PRIMARY_ID"
echo "NEW_PRIMARY_HOST: \$NEW_PRIMARY_HOST"
echo "NEW_MASTER_PGDATA: \$NEW_MASTER_PGDATA"

ssh_options="ssh -p 22 -n -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
set -x

if [ \$FALLING_NODE = \$OLD_PRIMARY_ID ] ; then
  \$ssh_options postgres@\${NEW_PRIMARY_HOST} "/usr/pgsql-\${PGVER}/bin/repmgr --log-to-file -f /etc/repmgr/\${PGVER}/repmgr.conf standby promote -v "
fi
exit 0
) 2>&1 | tee -a \$LOGFILE
EOF

sudo chmod +x /opt/pgpool/scripts/failover.sh

#@=====[/opt/pgpool/scripts/failover.sh 복사:pg02, pg03]
scp /opt/pgpool/scripts/failover.sh pg02.localnet:/opt/pgpool/scripts/failover.sh
scp /opt/pgpool/scripts/failover.sh pg03.localnet:/opt/pgpool/scripts/failover.sh


