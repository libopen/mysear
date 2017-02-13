while IFS="," read -r one  two ; do
  one=`echo -n $one | md5sum | tr -d "  -"`
  echo "$one,$two"
done < onlyspycenter.tar
