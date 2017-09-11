import xlrd
import csv
 
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
 
def csv_from_excel():
       #deal with numeric
    orglist={"北京":"110","天津":"120","河北":"130","山西":"140","内蒙":"150","辽宁":"210","沈阳":"211","大连":"212","吉林":"220","长春":"221","黑龙江":"230","哈尔滨":"231","上海":"310","江苏":"320","南京":"321","浙江":"330","宁波":"331","安徽":"340","福建":"350","厦门":"351","江西":"360","山东":"370","青岛":"371","河南":"410","湖北":"420","武汉":"421","湖南":"430","广东":"440","广州":"441","深圳":"442","广西":"450","海南":"460","四川":"510","成都":"511","重庆":"512","贵州":"520","云南":"530","陕西":"610","西安":"611","甘肃":"620","青海":"630","宁夏":"640","新疆":"650","兵团":"651","实验":"802","西藏":"804"}
 
    rnNum =[0,11,12,13,14,15,16,17,19,22,23,24] # deal \n
    intnum=[11,12,13,14,15,16,17,23,24]
    blknum=[18,19,20,21,22]
    chncol=['安徽','新疆']
    titlelist=('序号','区','教学点','考点编号','分校名称','教学点名称','考点名称','考点地址','考点类型','考点层次','保密室设置是否符合要求','单场容纳考生数','物理考场数','机考考场数','位','视频监控考场数','屏蔽','专职教职工数','主考','主考手机号','职务','联系人','联系人手机号','本科考生人数','专科考生人数')
               
    
    with open('examsite.csv','w',newline='',encoding='utf-8') as csvfile:
         wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
         wb = xlrd.open_workbook('examsite.xls')
         csvlist=[''  for x in range(41)]
         tmpCol2=""
         tmpCol3=""
         tmpCol4=""
         tmpCol5=""
         
         noimp=['暂停','临时本科考点申报','临时专科考点申报']
         for sheetname in wb.sheet_names():
            if sheetname in orglist.keys():
               sh = wb.sheet_by_name(sheetname)
               # deal with mutilplines
               # from the second line 
               lins = [x for x in range(sh.nrows)]
               iTotal=0
               iValid=0
               colOrder=True
               for rownum in lins:
                   csvlist=[''  for x in range(41)]
                   rowlist =[str(item).replace('\n',' ').replace(',',' ').strip() for item in sh.row_values(rownum)]
                   if len(rowlist)<25:
                      print("{} columns number is except ".format(sheetname))
                      break
                   # ignore the sheet head
                   #print("{},{}".format(rowlist[0],is_number(rowlist[0])))
                   #the coloums 's order is current
                   if rowlist[0]=='序号':
                      for i in range(25):
                         if titlelist[i] not  in rowlist[i]:
                            print ("num:{},{}".format(i,rowlist[i]))
                            colOrder=False
                            
                   if colOrder==False:
                      print("{}'s columns order is wrong".format(sheetname))
                      break
                            
                   if is_number(rowlist[0])==False:
                      continue
                   if float(rowlist[0])==1.0 : # get first merge_cells
                      tmpCol2 = rowlist[1]
                      tmpCol3 = rowlist[2]
                      tmpCol4 = rowlist[3]
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
                      
                      if rowlist[3]=="" : 
                         rowlist[3]=tmpCol4
                      else :
                         tmpCol4 = rowlist[3]
                      
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
                   #csvlist 
                   
                   
                   wr.writerow(rowlist[:26])
               print("{}:Totla{},valid{}".format(sheetname,iTotal,iValid))
         csvfile.close()
 
 
def main():
    csv_from_excel()
 
 
if __name__=='__main__':
     main()
