MAJORVER=12

CHK_PGDATA="export PGDATA=/u01/pg${MAJORVER}/data"

#echo $(grep -Fxc "xxxx1234" bb.txt) >> bb.txt
[ $(grep -Fxc "xxxx1234" bb.txt) -eq 0 ] && echo "xxxx1234" >>  bb.txt 

echo "-----------------------------"
cat bb.txt
echo "-----------------------------"


