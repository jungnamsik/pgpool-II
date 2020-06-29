MAJORVER=12

CHK_SOURCE="[ -f /etc/profile ] && source /etc/profile"
CHK_PGDATA="export PGDATA=/u01/pg${MAJORVER}/data"
CHK_PGVER="export PGVER=${MAJORVER}"




#sed -i -e "/^${CHK_SOURCE/\//\/g}/d" b.txt
#sed -i -e "/^${VAR2}/d" b.txt
#sed -i -e "/^${CHK_PGVER/\//\/g}/d"  b.txt

if grep -Fxq "${CHK_SOURCE}" b.txt; then
echo "exists profile check"
else
echo "${CHK_SOURCE}" >> b.txt
fi


if grep -Fxq "${CHK_PGDATA}" b.txt; then
echo "exists PGDATA"
else
echo "${CHK_PGDATA}" >> b.txt
fi

if grep -Fxq "${CHK_PGVER}" b.txt; then
/usr/bin/true
else
echo "${CHK_PGVER}" >>  b.txt
fi

[[ grep -Fxq "xxxx1234" b.txt ]] && /usr/bin/true || echo "xxxx1234" >>  b.txt

echo "-----------------------------"
cat b.txt
echo "-----------------------------"


