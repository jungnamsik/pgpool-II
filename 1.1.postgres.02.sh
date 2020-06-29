MAJORVER=12

#@=====[ 2.postgres directory 생성 : data, archive, backup ]
mkdir -p /u01/pg${MAJORVER}/data /u02/archive /u02/backup
chown postgres:postgres /u01/pg${MAJORVER}/data /u02/archive /u02/backup
chmod 700 /u01/pg${MAJORVER}/data /u02/archive


#@=====[ 3.postgres 환경변수.path 설정 ]
export PGDATA=/u01/pg${MAJORVER}/data
# add the binaries in the path of all users
echo "export PATH=\$PATH:/usr/pgsql-${MAJORVER}/bin" >  /etc/profile.d/postgres.sh
# source /etc/profile in bashrc of user postgres, make sure that PGDATA is defined and also PGVER so that we 
# can use PGVER in later scripts
echo "[ -f /etc/profile ] && source /etc/profile" >> /home/postgres/.bashrc 
echo "export PGDATA=/u01/pg${MAJORVER}/data" >> /home/postgres/.bashrc
echo "export PGVER=${MAJORVER}" >> /home/postgres/.bashrc


#CHK_SOURCE="[ -f /etc/profile ] && source /etc/profile"
#CHK_PGDATA="export PGDATA=/u01/pg${MAJORVER}/data"
#CHK_PGVER="export PGVER=${MAJORVER}"
#
#if grep -Fxq "${CHK_SOURCE}" /home/postgres/.bashrc; then
#echo "exists profile check"
#else
#echo "${CHK_SOURCE}" >> /home/postgres/.bashrc
#fi
#
#if grep -Fxq "${CHK_PGDATA}" /home/postgres/.bashrc; then
#echo "exists PGDATA"
#else
#echo "${CHK_PGDATA}" >> /home/postgres/.bashrc
#fi
#
#if grep -Fxq "${CHK_PGVER}" /home/postgres/.bashrc; then
#/usr/bin/true
#else
#echo "${CHK_PGVER}" >>  /home/postgres/.bashrc


