# on pg01 as user postgres
echo "# check the nodes table, it contains meta-data for repmgr "
psql -U repmgr repmgr -c "select * from nodes;"
echo "# create a test table"
psql -U repmgr repmgr -c "create table test(c1 int, message varchar(120)); insert into test values(1,'this is a test');"
echo "# check on pg02 if I can see the table and if it is read-only"
psql -h pg02.localnet -U repmgr repmgr <<EOF
select * from test;
drop table test;
EOF
# it will say: ERROR:  cannot execute DROP TABLE in a read-only transaction
echo "# check on pg03 if I can see the table and if it is read-only"
psql -h pg03.localnet -U repmgr repmgr <<EOF
select * from test;
drop table test;
EOF
echo "# drop the table on pg01"
psql -U repmgr repmgr -c "drop table test;"



