#!/bin/bash
FILENAME="$1"
a=($(cat $FILENAME))
#echo "${a[@]}"


#awk -v slist="${a[*]}" 'BEGIN {tlen=split(slist,A," "); for(i in A) {print A[i];}}'

#awk -F, -v slist="${a[*]}" 'BEGIN {tlen=split(slist,A," ")} {for(i in A) if($3==i) print $0}' data/student/cps_student.dat
awk -F, -v slist="${a[*]}" 'BEGIN {tlen=split(slist,A," ")} {for(i in A) 
                                                             if (A[i]==$3)
                                                                 print $0  }' <data/student/cps_student.dat
#while read -r line
#do
#   name="$line"
#   awk -F, -v var="$line" '{if($3==var) print $0}' data/student/cps_student.dat
#done<"$FILENAME"

