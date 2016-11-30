python3 exam.py	>newresult.ext
diff newresult.txt Result.txt
cat examsite.csv |awk -F, '{print $10}'|sort|uniq -c>newexamsite.txt
diff newexamsite.txt examsite.txt


