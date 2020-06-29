#@=====[pgpool 설정]
PGDBVER=12

NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}

# (not sure why and if it is still needed !!)
echo "pgpool.pg_ctl='/usr/pgsql-${PGDBVER}/bin/pg_ctl'" >> $PGDATA/conf.d/custom.conf


#@=====[pgool_hba and pool_passwd files]
cat <<EOF > /etc/pgpool-II/pool_hba.conf
local   all         all                               trust
# IPv4 local connections:
host     all         all         0.0.0.0/0             md5
EOF

scp /etc/pgpool-II/pool_hba.conf postgres@pg02.localnet:/etc/pgpool-II/
scp /etc/pgpool-II/pool_hba.conf postgres@pg03.localnet:/etc/pgpool-II/

#@=====[pgool_hba and pool_passwd files]
# first dump the info into a temp file
psql -c "select rolname,rolpassword from pg_authid;" > /tmp/users.tmp
touch /etc/pgpool-II/pool_passwd
# then go through the file to remove/add the entry in pool_passwd file
cat /tmp/users.tmp | awk 'BEGIN {FS="|"}{print $1" "$2}' | grep md5 | while read f1 f2
do
 echo "setting passwd of $f1 in /etc/pgpool-II/pool_passwd"
 # delete the line if exits
 sed -i -e "/^${f1}:/d" /etc/pgpool-II/pool_passwd
 echo $f1:$f2 >> /etc/pgpool-II/pool_passwd
done
scp /etc/pgpool-II/pool_passwd pg02:/etc/pgpool-II/pool_passwd
scp /etc/pgpool-II/pool_passwd pg03:/etc/pgpool-II/pool_passwd


