
if grep -Fxq "$1" b.txt; then
echo "0000000"
else
echo "1111111111"
fi

