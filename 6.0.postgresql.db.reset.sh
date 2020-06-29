# on pg01 as user postgres
PGDBVER=12

NODE_NAME=`hostname`
NODE_ID=${NODE_NAME:3:1}


#@=====[ postgresql - master, slave reset!!]
echo "host:${NODE_NAME} => master, standby resister!!"
# on ${NODE_NAME}
if [ "${NODE_NAME}" = "pg01" ]; then
    sudo systemctl restart postgresql
    #@=====[repmgr 기본 데이터베이스로 등록]
    echo "repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf -v master register"
    repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf -v master register

    #@=====[pgpool.conf 생성 shell 복사 후 실행]
    THIS_NAME="`pwd`/$0"
    scp ${THIS_NAME} pg02.localnet:${THIS_NAME}
    scp ${THIS_NAME} pg03.localnet:${THIS_NAME}

    ssh postgres@pg02.localnet "bash ${THIS_NAME}"
    ssh postgres@pg03.localnet "bash ${THIS_NAME}"

elif [ "${NODE_NAME}" = "pg02" ] || [ "${NODE_NAME}" = "pg03" ]; then
    #@=====[repmgr slave 서버 설정]
    # make sure postgres is not running !
    sudo systemctl stop postgresql
    # on pg02 as user postgres
    rm -rf /u01/pg${PGDBVER}/data/*
    rm -rf /u02/archive/*

    repmgr -h pg01.localnet -U repmgr -d repmgr -D /u01/pg${PGDBVER}/data -f /etc/repmgr/${PGDBVER}/repmgr.conf standby clone
    sudo systemctl start postgresql
    repmgr -f /etc/repmgr/${PGDBVER}/repmgr.conf standby register --force
    #repmgr -h pg01.localnet -U repmgr -d repmgr -D /u01/pg12/data -f /etc/repmgr/12/repmgr.conf standby clone
    #sudo systemctl start postgresql
    #repmgr -f /etc/repmgr/12/repmgr.conf standby register --force
fi




