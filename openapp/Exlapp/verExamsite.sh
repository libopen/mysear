flname=$1
echo 'col examareacode'
awk -F, '{print $2}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col courseid'
awk -F, '{print $4}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
echo 'col spycode'
awk -F, '{print $15}' $1 |sort|uniq -c
read -rsp $'Press enter to continue...\n'
