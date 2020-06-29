#@=====[pcp.confi 설정]
PGDBVER=12

NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}

# user postgres on pg01
echo "postgres:$(pg_md5 secret)" >> /etc/pgpool-II/pcp.conf
scp /etc/pgpool-II/pcp.conf pg02:/etc/pgpool-II/pcp.conf
scp /etc/pgpool-II/pcp.conf pg03:/etc/pgpool-II/pcp.conf

echo "*:*:postgres:secret" > /home/postgres/.pcppass 
chown postgres:postgres /home/postgres/.pcppass 
chmod 600 /home/postgres/.pcppass

scp /home/postgres/.pcppass pg02:/home/postgres/.pcppass
scp /home/postgres/.pcppass pg03:/home/postgres/.pcppass



