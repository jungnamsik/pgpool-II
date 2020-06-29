MAJORVER=12

#@=====[ 4.postgres 서비스 등록-부팅시 자동 시작 ]
cat <<EOF > /etc/systemd/system/postgresql.service
[Unit]
Description=PostgreSQL database server
Documentation=man:postgres(1)

[Service]
Type=notify
User=postgres
ExecStart=/usr/pgsql-${MAJORVER}/bin/postgres -D /u01/pg${MAJORVER}/data
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGINT
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF

#@=====[ 5.postgresql  서비스 활성화 (시작 전)]
sudo systemctl enable postgresql

#@=====[ 6.postgresql -firewall 서비스 port open ]
# as root
firewall-cmd --add-port 5432/tcp --permanent
systemctl restart firewalld


