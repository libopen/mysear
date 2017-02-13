awk -F'|' -v OFS=',' '{print $4,$2}' EAS_SPY_BASICINFO.txt|sort>onlyspy1.csv
sed -i 's/（//g' onlyspy1.csv
sort spy.csv >onlyspy2.csv
join -a1 -i -j 1 -t "," onlyspy2.csv onlyspy1.csv>cmponlyspy.csv
echo "show no match"
awk -F, '{ if ($2=="") print $0}' cmponlyspy.csv
awk -F, '{if ($2!="") printf(" update eas_spy_basicinfo set educationcommissioncode=000000 where spycode=%s\n",$2)}' cmponlyspy.csv >exec_onlyspy.sql

sed -i 's/000000/'\''000000'\''/g' exec_onlyspy.sql
sed -i 's/$/'\'';/g' exec_onlyspy.sql
sed -i 's/spycode=/spycode='\''/g' exec_onlyspy.sql
