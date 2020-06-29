DBNAME=$1
if [ "$#" -lt 1 ]; then
        echo "db name : app"
        DBNAME=app
fi

sudo systemctl start postgresql

#@=====[application db 생성]
cat <<EOF > ~/AppDB.1.make.sql
--# create 
create database ${DBNAME}db encoding 'UTF8'  LC_COLLATE='en_US.UTF8';
EOF

#@=====[application db : 생성-파일실행]
psql -U postgres -d postgres -f ~/AppDB.1.make.sql



#@=====[application db : 권한 부여]
cat <<EOF > ~/AppDB.2.auth.sql
--# auth 
create user ${DBNAME}_owner nosuperuser nocreatedb login password '${DBNAME}_owner';
create schema ${DBNAME}_owner authorization ${DBNAME}_owner;
create user ${DBNAME}_user nosuperuser nocreatedb login password '${DBNAME}_user';
grant usage on schema ${DBNAME}_owner to ${DBNAME}_user;
alter default privileges in schema ${DBNAME}_owner grant select,insert,update,delete on tables to ${DBNAME}_user;
alter role ${DBNAME}_user set search_path to "\$user",${DBNAME}_owner,public;
EOF

#@=====[application db : 권한 부여-파일실행]
psql -U postgres -d ${DBNAME}db -f ~/AppDB.2.auth.sql


