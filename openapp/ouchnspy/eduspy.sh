awk -F, '{printf("%s,%s,%s,%s,%s\n",$2,$1,($3~/^$/?substr($1,1,2):$3),$4,($5~/^$/?substr($1,1,4):$5))}' eduspyben.txt|sort >eduspyben.sor
awk -F, '{printf("%s,%s,%s,%s,%s\n",$2,$1,($3~/^$/?substr($1,1,2):$3),$4,($5~/^$/?substr($1,1,4):$5))}' eduspyzhuan.txt|sort >eduspyzhuan.sor
#awk -F'|'  '$3~/^[0-4]+/ {printf("%s,%s\n", $2,$1)}' EAS_DIC_EDUCOMMSPEC.txt|sort >eduben2.csv
#awk -F'|'  '$3~/^[5-9]+/ {printf("%s,%s\n", $2,$1)}' EAS_DIC_EDUCOMMSPEC.txt|sort >eduzhuan2.csv
#join -a1 -j 1 -t "," eduben1.csv eduben2.csv > cmpeduben.csv
#awk -F, ' {if ($6!="") printf("update eas_dic_educommspec set diccode= '\''%s'\'',dicname='\''%s'\'',group='\''%s'\'',scope='\''%s'\'',subjectcode='\''%s'\'',oldcode='\''%s'\'' where diccode='\''%s'\'';\n",$2,$1,$3,$4,$5,$6,$6 ) }' cmpeduben.csv > exec_ben.sql    
#awk -F, ' {if ($6=="") printf("Insert into OUCHNSYS.EAS_DIC_EDUCOMMSPEC'\('DICCODE, DICNAME, GROUPID, SCOPE, SUBJECTCODE'\)' Values '\(''\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'''\)';\n",$2,$1,$3,$4,$5 ) }' cmpeduben.csv >> exec_ben.sql    
awk -F, ' { printf("Insert into OUCHNSYS.EAS_DIC_EDUCOMMSPEC'\('DICCODE, DICNAME, GROUPID, SCOPE, SUBJECTCODE'\)' Values '\(''\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'''\)';\n",$2,$1,$3,$4,$5 ) }' eduspyben.sor > exec_eduspy.sql    
awk -F, ' { printf("Insert into OUCHNSYS.EAS_DIC_EDUCOMMSPEC'\('DICCODE, DICNAME, GROUPID, SCOPE, SUBJECTCODE'\)' Values '\(''\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'''\)';\n",$2,$1,$3,$4,$5 ) }' eduspyzhuan.sor >> exec_eduspy.sql    
cat OUCHNSYS.EAS_DIC_EDUCOMMSPEC.ctl>educommspec.ctl
cat eduben1.csv>>educommspec.ctl
cat eduzhuan1.csv>>educommspec.ctl
echo "待调整专业,888888,00,,">>educommspec.ctl
