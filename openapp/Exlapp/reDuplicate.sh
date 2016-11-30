file=$1
cat "$file" |sort|uniq -d>"$file"1
cat "$file" |sort|uniq -u>>"$file"1
