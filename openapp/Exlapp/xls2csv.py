import xlrd
import csv
from os import sys

def csv_from_excel(excel_file):
    workbook = xlrd.open_workbook(excel_file)
    all_worksheets = workbook.sheet_names()
    for worksheet_name in all_worksheets:
        worksheet = workbook.sheet_by_name(worksheet_name)
        if worksheet.nrows==0:
           print("{} is empty".format(worksheet.name))
        else:
           your_csv_file = open(''.join([worksheet_name,'.csv']), 'w',newline='',encoding='utf-8')
           wr = csv.writer(your_csv_file, quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
           print(worksheet.nrows)
           for rownum in range(worksheet.nrows):
              rowlist=[str(item).replace('\n','')  for item in worksheet.row_values(rownum)]
              if len(rowlist)==5:
               #print(rowlist)
               wr.writerow(rowlist)
           your_csv_file.close()

if __name__ == "__main__":
    csv_from_excel(sys.argv[1])
