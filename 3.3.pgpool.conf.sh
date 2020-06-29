
#@=====[pgpool.conf 설정]
PGDBVER=12

NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}

#@=====[ip, arping 권한 변경 +s]
# postgres로 ip, arping을 실행하므로 setuid 비트 활성화
# ip, arping을 postgres가 root 자격으로 실행 시킬수 있음
sudo chmod 4755 /usr/sbin/ip /usr/sbin/arping

#@=====[pgpool.conf 작업 / VIP 지정]
# as user postgres 
if [ "${NODE_NAME}" = "pg01" ]; then
    OTHER_HOST1="pg02"
    OTHER_HOST2="pg03"
elif [ "${NODE_NAME}" = "pg02" ]; then
    OTHER_HOST1="pg01"
    OTHER_HOST2="pg03"
elif [ "${NODE_NAME}" = "pg03" ]; then
    OTHER_HOST1="pg01"
    OTHER_HOST2="pg02"
fi

VIP="192.168.79.99"
CONFIG_FILE=/etc/pgpool-II/pgpool.conf
cat <<EOF > $CONFIG_FILE
listen_addresses = '*'
port = 9999
socket_dir = '/var/run/pgpool'
pcp_listen_addresses = '*'
pcp_port = 9898
pcp_socket_dir = '/var/run/pgpool'
listen_backlog_multiplier = 2
serialize_accept = off
enable_pool_hba = on
pool_passwd = 'pool_passwd'
authentication_timeout = 60
ssl = off
num_init_children = 100
max_pool = 5
# - Life time -
child_life_time = 300
child_max_connections = 0
connection_life_time = 600
client_idle_limit = 0

log_destination='stderr'
debug_level = 0

pid_file_name = '/var/run/pgpool/pgpool.pid'
logdir = '/tmp'

connection_cache = on
reset_query_list = 'ABORT; DISCARD ALL'
#reset_query_list = 'ABORT; RESET ALL; SET SESSION AUTHORIZATION DEFAULT'
replication_mode = off
load_balance_mode = off
master_slave_mode = on
master_slave_sub_mode = 'stream'

backend_hostname0 = 'pg01.localnet'
backend_port0 = 5432
backend_weight0 = 1
backend_data_directory0 = '/u01/pg${PGDBVER}/data'
backend_flag0 = 'ALLOW_TO_FAILOVER'

backend_hostname1 = 'pg02.localnet'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/u01/pg${PGDBVER}/data'
backend_flag1 = 'ALLOW_TO_FAILOVER'

backend_hostname2 = 'pg03.localnet'
backend_port2 = 5432
backend_weight2 = 1
backend_data_directory2 = '/u01/pg${PGDBVER}/data'
backend_flag2 = 'ALLOW_TO_FAILOVER'

# this is about checking the postgres streaming replication
sr_check_period = 10
sr_check_user = 'repmgr'
sr_check_password = 'rep123'
sr_check_database = 'repmgr'
delay_threshold = 10000000

# this is about automatic failover
failover_command = '/opt/pgpool/scripts/failover.sh  %d %h %P %m %H %R'
# not used, just echo something
failback_command = 'echo failback %d %h %p %D %m %H %M %P'
failover_on_backend_error = 'off'
search_primary_node_timeout = 300
# Mandatory in a 3 nodes set-up
follow_master_command = '/opt/pgpool/scripts/follow_master.sh %d %h %m %p %H %M %P'

# grace period before triggering a failover
health_check_period = 40
health_check_timeout = 10
health_check_user = 'hcuser'
health_check_password = 'hcuser'
health_check_database = 'postgres'
health_check_max_retries = 3
health_check_retry_delay = 1
connect_timeout = 10000

#------------------------------------------------------------------------------
# ONLINE RECOVERY
#------------------------------------------------------------------------------
recovery_user = 'repmgr'
recovery_password = 'rep123'
recovery_1st_stage_command = 'pgpool_recovery.sh'
recovery_2nd_stage_command = 'echo recovery_2nd_stage_command'
recovery_timeout = 90
client_idle_limit_in_recovery = 0

#------------------------------------------------------------------------------
# WATCHDOG
#------------------------------------------------------------------------------
use_watchdog = on
# trusted_servers = 'www.google.com,pg02.localnet,pg03.localnet' (not needed with a 3 nodes cluster ?)
ping_path = '/bin'

wd_hostname = '${NODE_NAME}.localnet'
wd_port = 9000
wd_priority = 1
wd_authkey = ''
wd_ipc_socket_dir = '/var/run/pgpool'

delegate_IP = '${VIP}'
if_cmd_path = '/opt/pgpool/scripts'
if_up_cmd = 'ip_w.sh addr add \$_IP_\$/24 dev enp0s9 label enp0s9:0 '
if_down_cmd = 'ip_w.sh addr del \$_IP_\$/24 dev enp0s9'
arping_path = '/opt/pgpool/scripts'
arping_cmd = 'arping_w.sh -U \$_IP_\$ -I enp0s9 -w 1'
# - Behaivor on escalation Setting -

heartbeat_destination0 = 'pg01.localnet'
heartbeat_destination_port0 = 9694
heartbeat_destination1 = 'pg02.localnet'
heartbeat_destination_port1 = 9694
heartbeat_destination2 = 'pg03.localnet'
heartbeat_destination_port2 = 9694

other_pgpool_hostname0 = '${OTHER_HOST1}.localnet'
other_pgpool_port0 = 9999
other_wd_port0 = 9000

other_pgpool_hostname1 = '${OTHER_HOST2}.localnet'
other_pgpool_port1 = 9999
other_wd_port1 = 9000
EOF

#@=====[pgpool.conf 생성 shell 복사 후 실행]
THIS_NAME="`pwd`/$0"
scp ${THIS_NAME} pg02.localnet:${THIS_NAME}
scp ${THIS_NAME} pg03.localnet:${THIS_NAME}

ssh postgres@pg02.localnet "bash ${THIS_NAME}"
ssh postgres@pg03.localnet "bash ${THIS_NAME}"

#@=====[postgres user for the health check : hcuser]
# on pg01 as user postgres : pg02, pg03은 read only로 오류
if [ "${NODE_NAME}" = "pg01" ]; then
  #create the postgres user for the health check
  psql -c "create user hcuser with login password 'hcuser';"
fi

#@=====[firewall ports ]
# port for postgres (was already done)
sudo firewall-cmd --add-port 9898/tcp --permanent
# ports for pgpool and for pcp
sudo firewall-cmd --add-port 9898/tcp --permanent
sudo firewall-cmd --add-port 9999/tcp --permanent
sudo firewall-cmd --add-port 9000/tcp --permanent
sudo firewall-cmd --add-port 9694/udp --permanent
sudo systemctl restart firewalld

#@=====[pid directory ]
# on all servers
sudo chown postgres:postgres /var/run/pgpool
sudo mkdir /var/log/pgpool
sudo chown postgres:postgres /var/log/pgpool

#@=====[script directory : /opt/pgpool/scripts ]
sudo mkdir -p /opt/pgpool/scripts
sudo chown postgres:postgres /opt/pgpool/scripts



