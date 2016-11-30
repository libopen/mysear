flname=$1
echo 'col exambatchcode'
awk -F, '{print $2}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col examcategory'
awk -F, '{print $4}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col exampapercode'
awk -F, '{if (length($8)!=5) print $8}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col courseid'
awk -F, '{if (length($10)!=5) print $10}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col segment'
awk -F, '{print $12}' $1 |sort|uniq -c
echo 'duplicate record'
awk -F, '{print $2,$4,$8,$16}' $1|sort|uniq -d
read -rsp $'Press enter to continue...\n'
grep '\.0' $1
