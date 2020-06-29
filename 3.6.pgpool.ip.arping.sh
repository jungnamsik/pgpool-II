
#@=====[/opt/pgpool/scripts/ip_w.sh 작성 ]
#Create the file /opt/pgpool/scripts/ip_w.sh
cat <<EOF > /opt/pgpool/scripts/ip_w.sh
#!/bin/bash
echo "Exec ip with params \$@ at `date`"
sudo /usr/sbin/ip \$@
exit \$?
EOF

#Now set execute mode on all scripts and copy them over to pg02 and pg03
#@=====[/opt/pgpool/scripts/ip_w.sh 복사 : pg02,pg03 ]
chmod 774 /opt/pgpool/scripts/ip_w.sh
scp /opt/pgpool/scripts/ip_w.sh pg02.localnet:/opt/pgpool/scripts/
scp /opt/pgpool/scripts/ip_w.sh pg03.localnet:/opt/pgpool/scripts/


#@=====[/opt/pgpool/scripts/arping_w.sh 작성]
#Create the file /opt/pgpool/scripts/arping_w.sh
cat <<EOF > /opt/pgpool/scripts/arping_w.sh
#!/bin/bash
echo "Exec arping with params \$@ at `date`"
sudo /usr/sbin/arping \$@
exit \$?
EOF

#@=====[/opt/pgpool/scripts/arping_w.sh 복사 : pg02, pg03]
#Now set execute mode on all scripts and copy them over to pg02 and pg03
chmod 774 /opt/pgpool/scripts/arping_w.sh
scp /opt/pgpool/scripts/arping_w.sh pg02.localnet:/opt/pgpool/scripts/
scp /opt/pgpool/scripts/arping_w.sh pg03.localnet:/opt/pgpool/scripts/

#chmod 774 /opt/pgpool/scripts/*
#scp /opt/pgpool/scripts/* pg02.localnet:/opt/pgpool/scripts/
#scp /opt/pgpool/scripts/* pg03.localnet:/opt/pgpool/scripts/



