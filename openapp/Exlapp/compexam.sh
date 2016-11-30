python3 exam.py	>newresult.ext
diff newresult.txt Result.txt
cat examsite.csv |awk -F, '{print $5}'|sort|uniq -c>newsiteno.txt
diff newsiteno.txt siteno.txt
cat examsite.csv |awk -F, '{print $10}'|sort|uniq -c>newsitetype.txt
diff newsitetype.txt sitetype.txt
cat examsite.csv |awk -F, '{print $11}'|sort|uniq -c>newsitelevel.txt
diff newsitelevel.txt sitelevel.txt
cat examsite.csv |awk -F, '{print $12}'|sort|uniq -c>newsitesec.txt
diff newsitesec.txt sitesec.txt
read -p "Press return " var
echo 'col 1 segmentcode :'
echo 'col 2 line_no'
echo 'col 3 exam scope'
echo 'col 5 duplicate siteno'
cat examsite.csv |awk -F, '{print $5}'|sort|uniq -d 
read -p "press return " var

echo 'col 10 sitetype'
cat examsite.csv |awk -F, '{print $10}'|sort|uniq -c 
read -p "press return " var
echo 'col 11 duplicate sitelevel'
cat examsite.csv |awk -F, '{print $11}'|sort|uniq -c 
read -p "press return " var
echo 'col 12 duplicate sitesec'
cat examsite.csv |awk -F, '{print $12}'|sort|uniq -d 
read -p "press return " var
echo 'col 13,14,15,16,17,18,19 no digital'
cat examsite.csv |awk -F, '{if ($13~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($14~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($15~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($16~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($17~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($18~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($19~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($25~/[0-9]/) { } else {print $0}}'
cat examsite.csv |awk -F, '{if ($26~/[0-9]/) { } else {print $0}}'

