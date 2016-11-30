cat examsite.csv |awk -F, '{ gsub(/^X/,"3",$10);\
                             gsub(/^D/,"2",$10); \
                             gsub(/^县/,"3",$10); \
                             gsub(/^地/,"县vi:级",$10); \
                  print $0}' OFS="," >examsite1.csv
