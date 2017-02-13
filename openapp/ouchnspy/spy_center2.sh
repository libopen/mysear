#awk -F'|'  '{printf("%s,%s\n", $3,$1)}' spycenter888888.txt|sort>onlyspycenter.tar
#sort spy888888.txt >onlyspycenter.sor

#join -a1 -o 1.1 1.2 2.1  -i -j 1 -t "," onlyspycenter.tar onlyspycenter.sor>onlyspycenter.cmp
#echo "show no match"
#awk -F, '{ if ($3=="") print $0}' onlyspycenter.cmp
#awk -F, '{if ($3!="") printf(" update eas_spy_openspycenter set educationcommissioncode='\''888888'\'' where sn=%s;\n",$2)}' onlyspycenter.cmp >exec_onlyspycenter2.sql

#while IFS="|" read -r f1 f2 f3 f4 f5 ; do
#  md5f3=`echo -n $f3 | md5sum | tr -d "  -"`
#  echo "$md5f3,$f1,$f3"
#done < spycenter888888.txt |sort >md5onlyspy.tar


#while  read -r f1  ; do
#  md5f1=`echo -n $f1 | md5sum | tr -d "  -"`
#  echo "$md5f1,$f1"
#done < spy888888.txt |sort



while IFS="|" read -r f1 f2 f3 f4 f5 ; do
  basef3=`echo  $f3 | base64|awk '{print substr($0,1,length($0)-4)}'`
  echo "$basef3,$f1,$f3"
done < spycenter888888.txt |sort -k3 -t "," >baseonlyspy.tar


while  read -r f1  ; do
  basef1=`echo  $f1 | base64|awk '{print substr($0,1,length($0)-4)}'`
  echo "$basef1,$f1"
done < spy888888.txt |sort -k2 -t "," >baseonlyspy.sor

join -a1 -o 1.1 1.2 1.3 2.1 2.2 -i -j 1 -t "," baseonlyspy.tar baseonlyspy.sor




