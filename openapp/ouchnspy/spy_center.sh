LANG=zh_CN.utf-8
sed -i 's/（//g' spycenter888888.txt
iconv -f utf-8 -t gb2312 spydir.txt -o spydir_gb.txt
iconv -f utf-8 -t gb2312 spycenter888888.txt -o spycenter888888_gb.txt
iconv -f utf-8 -t gb2312 spy.txt -o spy_gb.txt

awk -F, '{printf("%s-%s\n",$1,$2)}' spydir.txt|sort>spycenterdir.sor
awk -F'|'  '{printf("%s-%s,%s\n", $3,$4,$1)}' spycenter888888.txt| sort>spycenterdir.tar

join -i -j 1 -t "," spycenterdir.tar spycenterdir.sor>spycenterdir.cmp
echo "show no match"
join  -j 1 -t "," spycenterdir.tar spycenterdir.cmp
#awk -F, '{ if ($2=="") print $0}' spycenterdir.cmp
#awk -F, '{if ($2!="") printf(" update eas_spy_openspycenter set educationcommissioncode='\''888888'\'' where sn=%s;\n",$2)}' spycenterdir.cmp >exec_spycenterdir.sql

awk -F'|'  '{printf("%s,%s\n", $3,$1)}' spycenter888888.txt|sort>onlyspycenter.tar
sort spy.txt >onlyspycenter.sor
join -i -j 1 -t "," onlyspycenter.tar onlyspycenter.sor>onlyspycenter.cmp
#echo "show no match"


#awk -F, '{ if ($2=="") print $0}' onlyspycenter.cmp
#awk -F, '{if ($2!="") printf(" update eas_spy_openspycenter set educationcommissioncode='\''888888'\'' where sn=%s;\n",$2)}' onlyspycenter.cmp >exec_onlyspycenter.sql
#join -a1 -a2 onlyspycenter.tar spycenterdir.tar |awk -F, '{print $2}'|sort -n |uniq > spycenter.tar
#sort -n spycenter888888.txt > spycenter.sor
#join -a2 -j 1 -t "|" spycenter.tar spycenter.sor



