import xlrd
import csv

def csv_from_excel(xlsfile):
       #deal with numeric 
       cellNum =[0,11,12,13,14,15,16,17,19,22,23,24]
       with open('xls.csv','w',newline='',encoding='utf-8') as csvfile:
              wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
              wb = xlrd.open_workbook(xlsfile)
              for sheetname in wb.sheet_names():
                     sh = wb.sheet_by_name(sheetname)
            # deal with mutilplines 
                     for rownum in range(sh.nrows):
                
                            rowlist =[str(item).replace('\n',' ') for item in sh.row_values(rownum)]
                            for i in range(len(cellNum)):
                                   rowlist[cellNum[i]]=rowlist[cellNum[i]].rstrip('0').rstrip('.')
                
                                   wr.writerow(rowlist)
       csvfile.close()


def main():
       xlsfile = sys.argv[1]
       csv_from_excel(xlsfile)


if __name__=='__main__':
       main()
     

