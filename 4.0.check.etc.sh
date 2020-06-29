
#@=====[check : cluster, enable(postgresql, pgpool), firewall ]

# on pg01
repmgr -f /etc/repmgr/${PGVER}/repmgr.conf cluster show

#enable postgressql and pgpool services on all servers
sudo systemctl enable postgresql
sudo systemctl enable pgpool

ssh postgres@pg02.localnet "sudo systemctl enable postgresql"
ssh postgres@pg02.localnet "sudo systemctl enable pgpool"

ssh postgres@pg03.localnet "sudo systemctl enable postgresql"
ssh postgres@pg03.localnet "sudo systemctl enable pgpool"

#check firewall on all servers
sudo firewall-cmd --list-all

ssh postgres@pg03.localnet "sudo firewall-cmd --list-all"
ssh postgres@pg03.localnet "sudo firewall-cmd --list-all"






