import xlrd,csv,os,sys
import ouchnCommon


 
def expElc(xlsfile,csvname,sheetindex=0):
       #filename is format that is name such as elc90* or signup90* or score90* 
       #deal with numeric
    
    with open(csvname,'w',newline='',encoding='gb2312') as csvfile:
        wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
        wb = xlrd.open_workbook(xlsfile)
        sh = wb.sheet_by_index(sheetindex)
        
        # deal with mutilplines
        # from the second line 
        iTotal=0
        iValid=0
        #format export csv 
        csvlist=[1 for x in range(11)]
        for rownum in range(1,sh.nrows):
                 # csv format
            rowlist =[str(item).replace('\n',' ').replace(',',' ').strip() for item in sh.row_values(rownum)]
            csvlist[1]="{}{}".format(rowlist[0][0:4],ouchnCommon.BATDIC[rowlist[0][-1:]]) #batchcode
            csvlist[2]=rowlist[1] #learningcentercode
            csvlist[3]=rowlist[2] #classcode
            csvlist[4]="{}{}".format(rowlist[3],rowlist[2]) #classname
            csvlist[5]="{}{}".format(ouchnCommon.STUCATEDIC[rowlist[4]],ouchnCommon.PRODIC[rowlist[6]])
            csvlist[6]=ouchnCommon.removelast(rowlist[5])
            csvlist[7]=ouchnCommon.PRODIC[rowlist[6]]
            csvlist[8]=''
            csvlist[9]=''
            csvlist[10]='2018-04-08'
            iTotal+=1
            iValid+=1
            wr.writerow(csvlist)
            print("{}:Totla{},valid{}".format(sh.name,iTotal,iValid))
        csvfile.close()
 
 
def main():
    xlsfile = sys.argv[1]
    base= os.path.basename(xlsfile)
    basename=os.path.splitext(base)[0]
    expElc(xlsfile, "{}.csv".format(basename))
 
 
if __name__=='__main__':
    main()
