import xlrd
import csv

def csv_from_excel():
       #deal with numeric 
       cellNum =[0,11,12,13,14,15,16,17,19,22,23,24]
       with open('examsite.csv','w',newline='',encoding='utf-8') as csvfile:
            wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
            wb = xlrd.open_workbook('examsite.xls')
            sh = wb.sheet_by_index(0)
            # deal with mutilplines 
            for rownum in range(sh.nrows):
                
                rowlist =[str(item).replace('\n',' ') for item in sh.row_values(rownum)]
                for i in range(len(cellNum)):
                   rowlist[cellNum[i]]=rowlist[cellNum[i]].rstrip('0').rstrip('.')
                
                wr.writerow(rowlist)
            csvfile.close()


def main():
    csv_from_excel()


if __name__=='__main__':
     main()
     

