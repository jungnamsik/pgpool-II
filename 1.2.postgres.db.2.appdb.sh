DBNAME=$1
if [ "$#" -lt 1 ]; then
        echo "db name : app"
        DBNAME=app
fi

sudo systemctl start postgresql

#@=====[application db 생성]
# newdb.sh 스크립트----------
APPOWNER=newappo
APPUSER=newsvc
DBNAME=newdb
PASSWORD=pass1234
 
# psql -d postgres -U postgres -c "drop database ${DBNAME}"
# psql -d postgres -U postgres -c "drop user ${APPOWNER}"
# psql -d postgres -U postgres -c "drop user ${APPUSER}"
 
echo -- 신규 유저 생성
psql -d postgres -U postgres -c "create user ${APPOWNER} with password '${PASSWORD}'"
psql -d postgres -U postgres -c "create user ${APPUSER} with password '${PASSWORD}'"
 
echo -- 신규 DB 생성 # encoding 'UTF8' LC_COLLATE='en_US.UTF8'
psql -d postgres -U postgres -c "create database ${DBNAME} with OWNER=${APPOWNER}"
 
echo -- db 접근 권한 및 public schema 접근 권한 revoke
psql -d ${DBNAME} -U postgres -c "revoke all on database ${DBNAME} from public"
psql -d ${DBNAME} -U postgres -c "revoke all on schema public from public"
 
echo -- 신규db에 schema 생성
psql -d ${DBNAME} -U postgres -c "create schema ${APPOWNER} authorization ${APPOWNER}"
 
echo -- 서비스용 유저에 최소한의 권한만 부여
psql -d ${DBNAME} -U postgres -c "grant connect,TEMPORARY on database ${DBNAME} to ${APPUSER}"
psql -d ${DBNAME} -U postgres -c "grant usage on schema ${APPOWNER} to ${APPUSER}"
psql -d ${DBNAME} -U postgres -c "grant select, insert, update, delete on all tables in schema ${APPOWNER} to ${APPUSER}"
psql -d ${DBNAME} -U postgres -c "alter default privileges in schema ${APPOWNER} grant select, insert, update, delete on tables to ${APPUSER}"
psql -d ${DBNAME} -U postgres -c "grant usage on all sequences in schema ${APPOWNER} to ${APPUSER}"
psql -d ${DBNAME} -U postgres -c "alter default privileges in schema ${APPOWNER} grant usage on sequences to ${APPUSER}"
 
echo -- 기본 스키마 변경 : public - schema
psql -d ${DBNAME} -U postgres  -c "alter role ${APPUSER} set search_path to ${APPOWNER}"



# @=====[application db 생성]
# cat <<EOF > ~/AppDB.1.make.sql
# --# create 
# create database ${DBNAME}db encoding 'UTF8'  LC_COLLATE='en_US.UTF8';
# EOF
# 
# #@=====[application db : 생성-파일실행]
# psql -U postgres -d postgres -f ~/AppDB.1.make.sql
# 
# 
# 
# #@=====[application db : 권한 부여]
# cat <<EOF > ~/AppDB.2.auth.sql
# --# auth 
# create user ${DBNAME}_owner nosuperuser nocreatedb login password '${DBNAME}_owner';
# create schema ${DBNAME}_owner authorization ${DBNAME}_owner;
# create user ${DBNAME}_user nosuperuser nocreatedb login password '${DBNAME}_user';
# grant usage on schema ${DBNAME}_owner to ${DBNAME}_user;
# alter default privileges in schema ${DBNAME}_owner grant select,insert,update,delete on tables to ${DBNAME}_user;
# alter role ${DBNAME}_user set search_path to "\$user",${DBNAME}_owner,public;
# EOF
# 
# #@=====[application db : 권한 부여-파일실행]
# psql -U postgres -d ${DBNAME}db -f ~/AppDB.2.auth.sql


