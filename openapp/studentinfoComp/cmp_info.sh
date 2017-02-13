exit|sqlplus ouchnsys/Jw2015 @/home/libin/exp_student.sql
cat student_db.csv|sed 's/\s\+$//g' >student_db1.csv
awk -F, '{if ($2!="") printf("%s,%s,%s,%s,%s,%s,%s,%s\n",$2,$1,$3,$4,$5,$6,$7,$8)}'  student_dbf.csv |sort -k1>cmpdbf.csv
awk -F, '{if ($2!="") printf("%s,%s,%s,%s,%s,%s,%s,%s\n",$2,$1,$3,$4,$5,$6,$7,$8)}'  student_db1.csv |sort -k1>cmpdb.csv
echo "convert same charset"
iconv -fUTF-8 -tGB18030 cmpdbf.csv>cmpdbf1.csv
#diff cmpdbf1.csv cmpdb.csv -y -B -w >cmpres.txt
#echo "show the different on the same studentcode"
#grep "|" cmpres.txt
#echo "show the result in cmpdb.csv"
#grep ">" cmpres.txt
#echo "show the result in the cmpdbf1.csv"
#grep "<" cmpres.txt
echo "join remove ^m "
dos2unix *csv
join -1 1 -2 1 -t "," cmpdbf1.csv cmpdb.csv >cmpsame.csp
echo "ksh is not same"
awk -F, '{if ($2!=$9) print $0}' cmpsame.csv >diffksh.csv
awk -F, '{if ($3!=$10) print $0}' cmpsame.csv >diffxm.csv


