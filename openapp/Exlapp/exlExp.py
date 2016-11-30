import xlrd
import csv
import redis 
import os
 
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass

    try:
        import unicodedata
        unicodedata.numeric(s)
        return True
    except (TypeError,ValueError):
        pass
    return False
 
def expElc(xlsfile,csvname):
       #filename is format that is name such as elc90* or signup90* or score90* 
       #deal with numeric
    
    batlist={"
    rnNum =[0,11,12,13,14,15,16,17,19,22,23,24] # deal \n
    intnum=[11,12,13,14,15,16,17,23,24]
    blknum=[18,19,20,21,22]
    
    
    with open(csvname,'w',newline='',encoding='gb2312') as csvfile:
         wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
         wb = xlrd.open_workbook(xlsfile)
         tmpCol2=""
         tmpCol3=""
         tmpCol4=""
         tmpCol5=""
         
         
         for sh in wb.sheets():
             # deal with mutilplines
             # from the second line 
             lins = [x for x in range(1,sh.nrows)]
             iTotal=0
             iValid=0
             for rownum in lins:
                 rowlist =[str(item).replace('\n',' ').replace(',',' ').strip() for item in sh.row_values(rownum)]
                 #print("{},{}".format(rowlist[0],is_number(rowlist[0])))
                 if is_number(rowlist[0])==False:
                      continue
                  if float(rowlist[0])==1.0 : # get first merge_cells
                      tmpCol2 = rowlist[1]
                      tmpCol3 = rowlist[2]
                      #tmpCol4 = rowlist[3]
                      tmpCol5 = rowlist[4]
                   else :
                      #do  merge_cell 
                      if rowlist[1]=="" :#merge_cell
                         rowlist[1]=tmpCol2
                      else:
                         tmpCol2 = rowlist[1]
                      if rowlist[2]=="" :#merge_cell
                         rowlist[2]=tmpCol3
                      else:
                         tmpCol3 = rowlist[2]
                      """
                      if rowlist[3]=="" : 
                         rowlist[3]=tmpCol4
                      else :
                         tmpCol4 = rowlist[3]
                      """
                      if rowlist[4]=="" :
                         rowlist[4] = tmpCol5
                      else:
                         tmpCol5=rowlist[4]

                      #change column 8,9
                   if sheetname in chncol:
                        tmpval = rowlist[8]
                        rowlist[8]=rowlist[9]
                        rowlist[9]=tmpval

                   iTotal+=1
                   #ignore the temp 
                   if len(rowlist)>25:
                      if (rowlist[25].strip() in noimp)  or rowlist[9].strip()=="成人":
                          continue
                   for i in range(25):
                      
                      if  i in rnNum:
                         rowlist[i]=rowlist[i].rstrip('0').rstrip('.')
                      if i in intnum:
                        if rowlist[i]=="" or rowlist[i]=="无": 
                           rowlist[i]="0"
                      if i in blknum:
                           if rowlist[i]=="":
                              rowlist[i]="无"
                      #remove .0
                      if i in [2,3]:
                          rowlist[i]=rowlist[i].replace('.0','')
                   iValid+=1
                   rowlist.insert(0,orglist[sheetname])
                   wr.writerow(rowlist[:26])
               print("{}:Totla{},valid{}".format(sheetname,iTotal,iValid))
         csvfile.close()
 
 
def main():
    xlsfile = sys.argv[1]
    base= os.path.basename(xlsfile)
    basename=os.path.splitext(base)[0]
    csv_from_excel()
 
 
if __name__=='__main__':
     main()
