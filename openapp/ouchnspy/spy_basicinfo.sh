awk -F, '{printf("%s-%s\n",$1,$2)}' spydir.txt|sort>spydir.sor
awk -F'|'  '{printf("%s-%s,%s\n", $4,$3,$2)}' EAS_SPY_BASICINFO.txt|sort>spydir.tar

join -a1 -i -j 1 -t "," spydir.tar spydir.sor>spydir.cmp
echo "show no match"
awk -F, '{ if ($2=="") print $0}' spydir.cmp
awk -F, '{if ($2!="") printf(" update eas_spy_basicinfo set educationcommissioncode=000000 where spycode=%s\n",$2)}' spydir.cmp >exec_spydir.sql

sed -i 's/000000/'\''000000'\''/g' exec_spydir.sql
sed -i 's/$/;/g' exec_spydir.sql
sed -i 's/spycode=/spycode='\''/g' exec_spydir.sql

awk -F'|' -v OFS=',' '{print $4,$2}' EAS_SPY_BASICINFO.txt|sort>onlyspy.tar
sed -i 's/（//g' onlyspy.tar
sort spy.csv >onlyspy.sor
join -a1 -i -j 1 -t "," onlyspy.tar onlyspy.tar>onlyspy.cmp
echo "show no match"
awk -F, '{ if ($2=="") print $0}' onlyspy.cmp
awk -F, '{if ($2!="") printf(" update eas_spy_basicinfo set educationcommissioncode=000000 where spycode=%s\n",$2)}' onlyspy.cmp >exec_onlyspy.sql

