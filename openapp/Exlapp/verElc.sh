flname=$1
echo 'col batchcode'
awk -F, '{print $2}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col courseid'
awk -F, '{if (length($4)!=5) print $4}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col spycode'
awk -F, '{print $15}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'spy code length is not current'
awk -F, '{if (length($15)!=8) print NR,$0}' $1
read -rsp $'Press enter to continue...\n'
echo 'col learningcentercode'
awk -F, '{print $5}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'duplicate record'
awk -F, '{print $2,$3,$4}' $1|sort|uniq -d
read -rsp $'Press enter to continue...\n'
echo ' include . '
grep '\.0' $1

