# as user root
MAJORVER=12
#REPMGRVER=4.2

#@=====[repmgr 설치]
curl https://dl.2ndquadrant.com/default/release/get/${MAJORVER}/rpm | bash
#yum install -y --enablerepo=2ndquadrant-dl-default-release-pg${MAJORVER} --disablerepo=pgdg${MAJORVER} repmgr${MAJORVER}-${REPMGRVER}
yum install -y --enablerepo=2ndquadrant-dl-default-release-pg${MAJORVER} --disablerepo=pgdg${MAJORVER} repmgr${MAJORVER}
mkdir /var/log/repmgr && chown postgres:postgres /var/log/repmgr

#@=====[repmgr 권한변경]
chown -R postgres:postgres /etc/repmgr


