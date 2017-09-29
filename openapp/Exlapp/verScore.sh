flname=$1
echo 'field: batchcode'
awk -F, '{if (length($5)!=6) print $5}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: category'
awk -F, '{if (length($6)!=2)  print $6}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: courseid'
awk -F, '{if (length($8)!=5) print $8}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: exampapercode'
awk -F, '{if (length($9)!=5) print $9}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: paperscore'
awk -F, '$12!~/[0-9]+/ {print $12}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: paperscorecode'
awk -F, '$13!~/[0-9]+/ {print $13}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: xkscorecode'
awk -F, '$14!~/[0-9]+/ {print $14}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: xkscorecode'
awk -F, '$15!~/[0-9]+/ {print $15}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: xkscorescpoe'
awk -F, '$16!~/[0-9]+/ {print $16}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: composescore'
awk -F, '$17!~/[0-9]+/ {print $17}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'field: composescorecode'
awk -F, '$18!~/[0-9]+/ {print $18}' $1 |sort|uniq -c
echo 'duplicate result'
awk -F, '{print $5,$6,$8,$11}' $1|sort|uniq -d 
echo '.0'
grep '\.0' $1

