
# cluster status
repmgr -f /etc/repmgr/12/repmgr.conf cluster show

repmgr -f /etc/repmgr/12/repmgr.conf cluster show --compact

# watchdog
pcp_watchdog_info -h 192.168.79.99 -p 9898 -w -v

# node
psql -h 192.168.79.99 -p 9999 -U repmgr -c "show pool_nodes;"
psql -h 192.168.79.99 -p 9999 -U postgres -c "show pool_nodes;"


# firewall
sudo firewall-cmd --list-all
