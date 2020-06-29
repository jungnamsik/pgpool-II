# -*- coding: utf-8 -*-
import psycopg2
import random
import datetime
from time import sleep

# centos7 - pip / psycopg2 설치 : 
# yum install python-pip
# pip install --upgrade pip
# yum install build-dep python-psycopg2
# pip install psycopg2
# Update connection string information
host = "34.64.165.148"
host = "34.64.95.45"
host = "34.120.172.22"
port = "5432"
host = "192.168.79.99"
port = "9999"
dbname = "newdb"
user = "newappo"
password = "pass1234"
sslmode = "require"
sslmode = "allow"

def db_conn() :
  # Construct connection string
  conn_string = "host={0} port={1} user={2} dbname={3} password={4} sslmode={5}".format(host, port, user, dbname, password, sslmode)
  # conn_string = "host={0} port={1} user={2} dbname={3} password={4}".format(host, port, user, dbname, password)
  print (conn_string)
  return  psycopg2.connect(conn_string) 


# 임시 테이블 데이터 생성
def make_table( conn ) : 
  try :
    with conn :
      cur = conn.cursor()
      cur.execute("DROP TABLE IF EXISTS TNO99")
      cur.execute("create table TNO99 (id serial PRIMARY KEY, no integer, dt timestamp not null default CURRENT_DATE)")
      # cur.execute("insert into Student(name, mobile) values('홍길동', '010-2323-4545')")
      # cur.execute("insert into Student(name) values('홍길순')")

  except Exception as e :
    print("error 1=>", e)
    pass

def insert( conn, idx) :
  sql_insert = "insert into tno99(no,dt) values (%s, current_timestamp)"  
  with conn :
    cursor = conn.cursor()
    cursor.execute(sql_insert, (idx,))
    conn.commit 

def select (conn) :
  sql_select = "select * from tno99 where id >= %s order by id desc"
  with conn :
    cursor = conn.cursor()
    rows = cursor.execute(sql_select, (1,))
    rows = cursor.fetchall()
    for row in rows :
      print(row)

# 아래 insert_sleep_test의 경우 서버이 일시에 execute되기 때문에 dt 시간이 모두 같음// 주의
# commit 후 sleep 해도 개발자 의도와 다르게 서버에 적용되지 않음 
def insert_sleep_test( conn, idx = 1 ) :
  sql_insert = "insert into tno99(no,dt) values (%s, current_timestamp)"  
  with conn :
    cursor = conn.cursor()
    for no in range(1, 6) :
      cursor.execute(sql_insert, (no,))
      conn.commit 
      now = datetime.datetime.now()
      print(now)
      sleep(3)


conn = db_conn()
make_table(conn)
for idx in range(1, 6) :
  try :
    now = datetime.datetime.now()
    print("[{0}]=>{1}".format(idx,now))
    insert (conn, idx)
    sleep(1)
  except Exception as e :
    print("error insert for=>", e)
    sleep(1)
    pass

# insert_sleep_test( conn )

select(conn)


# for idx in range(1, 3) :
#   sleep(1)
#   now = datetime.datetime.now()
#   print ("{0}->{1}".format(idx,now))
