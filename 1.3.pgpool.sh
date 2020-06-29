# as user root
#@=====[pgpool 설치]
PGPOOLMAJOR=4.1
PGPOOLVER=4.1.2
PGDBVER=12
echo "PGPOOLMAJOR=> ${PGPOOLMAJOR}"

# yum install http://www.pgpool.net/yum/rpms/4.1/redhat/rhel-7-x86_64/pgpool-II-release-4.1-1.noarch.rpm
# yum install pgpool-II-pg${PGDBVER}-*

yum install -y http://www.pgpool.net/yum/rpms/${PGPOOLMAJOR}/redhat/rhel-7-x86_64/pgpool-II-release-${PGPOOLMAJOR}-1.noarch.rpm
yum install --disablerepo=pgdg${PGDBVER} --enablerepo=pgpool${PGPOOLMAJOR//./} -y pgpool-II-pg${PGDBVER}-${PGPOOLVER} pgpool-II-pg${PGDBVER}-extensions-${PGPOOLVER} pgpool-II-pg${PGDBVER}-debuginfo-${PGPOOLVER}

#@=====[pgpool 서비스 등록]
# as user root
mkdir /etc/systemd/system/pgpool.service.d
cat <<EOF > /etc/systemd/system/pgpool.service.d/override.conf
[Service]
User=postgres
Group=postgres
EOF

#@=====[pgpool ssh 연결 설정]
/etc/ssh/ssh_config > /etc/ssh/ssh_config.bak
cat <<EOF > /etc/ssh/ssh_config
StrictHostKeyChecking no 
UserKnownHostsFile /dev/null 
EOF

#@=====[pgpool-II 소유권 변경]
sudo chown postgres:postgres -R /etc/pgpool-II


#@=====[pgpool pid, socket ]
sudo mkdir /var/run/pgpool
sudo chown postgres:postgres /var/run/pgpool


#@=====[pgpool pid, socket ]
sed -i -e "/^OPTS=/d" /etc/sysconfig/pgpool
echo 'OPTS=" -D -n"' >> /etc/sysconfig/pgpool