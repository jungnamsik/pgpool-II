# as user root
#@=====[ 1.postgres 설치 ]
MAJORVER=12
#MINORVER=2
yum update -y
# install some useful packages
yum install -y epel-release libxslt sudo openssh-server openssh-clients jq passwd rsync iproute python-setuptools hostname inotify-tools yum-utils which sudo vi firewalld
# create user postgres before installing postgres rpm, because I want to fix the uid
useradd -u 50010 postgres
# set a password
passwd postgres
# So that postgres can become root without password, I add it in sudoers 
echo "postgres ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/postgres
# install postgres release rpm, this will add a file /etc/yum.repos.d/pgdg-${MAJORVER}-centos.repo
##--postgresql Download : centos7 : https://www.postgresql.org/download/linux/redhat/
#yum install -y https://download.postgresql.org/pub/repos/yum/${MAJORVER}/redhat/rhel-7-x86_64/pgdg-centos${MAJORVER}-${MAJORVER}-${MINORVER}.noarch.rpm
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# with the repo added (repo is called pgdg${MAJORVER}), ww can install postgres
# NB: postgres is also available from Centos base repos, but we want the latest version (${MAJORVER})
#yum install -y postgresql${MAJORVER}-${MAJORVER}.${MINORVER} postgresql${MAJORVER}-server-${MAJORVER}.${MINORVER}  postgresql${MAJORVER}-contrib-${MAJORVER}.${MINORVER}
yum install -y postgresql${MAJORVER}-server  postgresql-contrib

# verify 
yum list installed postgresql*
