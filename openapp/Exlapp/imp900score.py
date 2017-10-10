import xlrd
import csv
import os
import sys 
from progressbar import printProgress
import pandas as pd
import numpy as np
def newPaperCode(oldCode):
        if oldCode!='':
                top2=oldCode[:2]
                if (top2=='27') or (top2=='49') :
                    return "4{}".format(oldCode)
                elif int(top2)<20:
                    return "1{}".format(oldCode)
                elif int(top2)>49:
                    return "5{}".format(oldCode)
                else:
                    return "2{}".format(oldCode)
def getRedis(val,code='utf'):
    if val=='':
        return ('','')
    else :
      key=val
      if type(val)==float:
         key='%d'%val
      elif type(val)==int:
         key='%d'%val
      else:
         if is_number(val):
            key=val.split('.')[0]
            if key=='100':
               key='++'
      #print(key)
      if re.get(key)is None:
         reval=''
      else :
         if code=='utf':
            reval= re.get(key).decode('utf-8')
         else :
            reval= re.get(key).decode('gb2312')
      return (key,reval)

def getstuinfoDic(csvfile='stuinfo.txt'):
    # read student.csv convert to dict
    dict={}
    reader=csv.DictReader(open(csvfile,'r'))
    for line in reader:
        dict[line['STUDENTCODE']]=line
    return dict
def getscoreDic(csvfile='scorecode.txt'):
    # read student.csv convert to dict
    dict={}
    reader=csv.DictReader(open(csvfile,'r'))
    for line in reader:
        dict[line['DICCODE']]=line['DICSCORE']
    return dict

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

def removelast(str):
        return str[:-2] if str[-2:]=='.0' else str
 
def expElc(csvname,xlsfile):
       #filename is format that is name such as elc90* or signup90* or score90* 
       #deal with numeric
        studict=getstuinfoDic()
        col_elc=['学号','教学点代码','课程ID','选课年度','选课学期','考试单位类型','选课次数']
        batlist={"秋季":"09","春季":"03"}
        examunitlist={"中央":"1","省":"2"}
        rnNum =[0,1,2,3,4,5] # deal \n
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
                        if sh.nrows==0:
                                print("{} is empty".format(sh.name))
                                continue
                        # deal with mutilplines
                        # from the second line 
                        # is columns order is current?
                        bColOrder=True
                        rowcollist=sh.row_values(0)
                        for i in range(len(col_elc)):
                                if col_elc[i] not in rowcollist[i]:
                                        bColOrder=False
                                        print ("sheet:{} {}'s {} is not current order".format(xlsfile,sh.name,col_elc[i]))
                                        break
                        if bColOrder==False:# if Column's order is not current then break and get next sheet
                                continue
              
                        lins = [x for x in range(1,sh.nrows)]
                        iTotal=0
                        iValid=0
                        for rownum in lins:
                 
                                bvalid=True                
                                csvlist=["1" for x in range(18)]
                                #all conver to string and remove return char and             
                                rowlist =[str(item).replace('\n',' ').replace(',',' ').strip() for item in sh.row_values(rownum)  ]
                                #print("{},{}".format(rowlist[0],is_number(rowlist[0])))
                                csvlist[1]="{}{}".format(rowlist[3][:4],batlist[rowlist[4]])
                                csvlist[2]=removelast(rowlist[0]) #studentcode
                                csvlist[3]=str(removelast(rowlist[2])).zfill(5)  #courseid
                                #get info by redis
                                #stuinfo = getRedis(rowlist[0])
                                # find studentcode in studict 
                                if removelast(rowlist[0]) not in studict.keys():
                                        bvalid=False
                                        print("{}:{},{},{}, no find".format(sh.name,rownum,rowlist[0],rowlist[1]))
                                else:
                                        #dic = eval(stuinfo[1])
                                        dic=studict[removelast(rowlist[0])]
                                        csvlist[4]=dic['LEARNINGCENTERCODE']#learningcentercode
                                        csvlist[5]=dic['CLASSCODE'] #classcode
                                        csvlist[7]='elximp' #operator
                                        csvlist[9]='' #operatetime
                                        csvlist[10]='elximp' #operator
                                        csvlist[12]='' #comfirmtime
                                        csvlist[13]=removelast(rowlist[6])
                                        csvlist[14]=dic['SPYCODE']
                                        csvlist[17]=dic['STUDENTID']
                                       
                                iTotal+=1
                                if bvalid==True:
                                        iValid+=1
                                wr.writerow(csvlist)
                        print("{}:Totla{},valid{}".format(sh.name,iTotal,iValid))
        csvfile.close()

def score2round(score):
    try:
        if score!='':
            if score[0] in '1234567890':
                return str(int(float(score)+0.5))
            else:
                return removelast(score)
        else:
            return ''
    except:
        print(score)
      
 
def expScore(csvname,xlsfile,papercodetype='4'):
       # get date from score***xls to create composescore
       #filename is format that is name such as elc90* or signup90* or score90* 
       #deal with numeric
        studict=getstuinfoDic()   
        scoredic=getscoreDic()
        col_score=['学号','课程ID','考试代码','考试类别代码','试卷号','试卷成绩代码','形考成绩代码','形考比例','综合成绩代码','教学点代码','考试单位类型','考试次数']
        
        batlist={"秋季":"09","春季":"03"}
        examunitlist={"中央":"1","省":"2","国开":"1","省开":"2"}
        rnNum =[0,1,2,3,4,5] # deal \n
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
                        if sh.nrows==0:
                                print("{} is empty".format(sh.name))
                                continue # return top to get next sheet
                        # deal with mutilpline
                        # from the second line
                        #begin to process 
                        bColOrder=True
                        rowcollist=sh.row_values(0) #get the column's name from the first row
                        for i in range(len(col_score)):
                                rowcollist[i]=rowcollist[i].replace('\n','')
                                if col_score[i] not in rowcollist[i]:
                                        bColOrder=False
                                        print ("sheet:{} {}'s {} is not current order".format(xlsfile,sh.name,col_score[i]))
                                        break
                        if bColOrder==False:  # if the order of column is not current ,return to get next sheet
                                continue

                        lins = [x for x in range(1,sh.nrows)]
                        iTotal=0
                        iValid=0
                        totalLines=len(lins) # total rows
                        printProgress(0,totalLines,prefix='Process',suffix='Complete',barLength=50)
                        for rownum in lins:
                                #print("rownum:{}".format(rownum))
                                bvalid=True
                                csvlist=["" for x in range(23)]
                                            
                                rowlist =[str(item).replace('\n',' ').replace(',',' ').strip() for item in sh.row_values(rownum)]
                                #print("{},{}".format(rownum,rowlist))
                                csvlist[0]="1" # SN
                                csvlist[1]=rowlist[9][:3] #segmentcode
                                csvlist[2]=rowlist[9][:5] #collegecode
                                #get info by dic

                                if removelast(rowlist[0]) not in studict.keys():
                                        bvalid=False
                                        print("{}:{},{}:{} no find".format(sh.name,rownum+1,rowlist[0],rowlist[9]))
                                else:
                                        #dic = eval(infodic[1])
                                        dic=studict[removelast(rowlist[0])]
                                        csvlist[3]=dic['CLASSCODE'] #classcode
                                        csvlist[4]=rowlist[2].rstrip('0').rstrip('.') #examPlanCode
                                        csvlist[5]=rowlist[3] #ExamCategory
                                        csvlist[6]=examunitlist[rowlist[10]]
                                        csvlist[7]=str(removelast(rowlist[1])).zfill(5) #courseid
                                        if papercodetype=='4':
                                                csvlist[8]=newPaperCode('%d'%float(removelast(rowlist[4]))) if len(removelast(rowlist[4]))==4 else removelast(rowlist[4])
                                        else:    
                                                csvlist[8]=str(removelast(rowlist[4])).zfill(5)
                                        csvlist[9]=dic['LEARNINGCENTERCODE'] #learningcentercode
                                        csvlist[10]=removelast(rowlist[0]) #studentcode
                                        scorelist=()
                                        #print("{key}{val}".format(key=rowlist[5],val=getRedis(rowlist[5])))
                                     
                                        #get score by scoredic
                                        #print (rowlist[5])
                                        if rowlist[5]!='':
                                                csvlist[12]=score2round(rowlist[5])# PaperScoreCode
                                                csvlist[11]=scoredic[csvlist[12]] #PaperScore
                                        if rowlist[6]!='':
                                                csvlist[14]=score2round(rowlist[6]) #xkscorecode
                                                csvlist[13]=scoredic[csvlist[14]] #XKscore
                                        #xk scale
                                        valscale='0'
                                        #print (rowlist[7]) 
                                        if is_number(rowlist[7]):
                                                if float(rowlist[7])<=1.0:
                                                        valscale='%d'%(float(rowlist[7])*100)
                                                else:
                                                        valscale='%d'%float(rowlist[7])
                                        else :
                                                valscale=rowlist[7].rstrip('%')
                                        csvlist[15]=valscale  #xkscale
                                        # composescore
                                        if rowlist[8]!='':
                                                csvlist[17]=score2round(rowlist[8])           #composescorecode
                                                csvlist[16]=scoredic[csvlist[17]] #composescore
                    
                    #csvlist[18] #composeDate
                    #csvlist[19] #publistdate
                                        csvlist[20]="1"
                                        csvlist[21]="1"
                                        csvlist[22]="end"
                                iTotal+=1
                                printProgress(iTotal,totalLines,prefix='Process',suffix='Complete',barLength=50)
                                #print(iTotal)
                                if bvalid==True:
                                        iValid+=1
                                        wr.writerow(csvlist)
                        print("{}:Totla{},valid{}".format(sh.name,iTotal,iValid))
 
def expSignup(csvname,xlsfile,papercodetype='4'):
       # get date from score***xls to create composescore
       #filename is format that is name such as elc90* or signup90* or score90* 
       #deal with numeric
        studict=getstuinfoDic()
        col_sign=['学号','考试代码','课程ID','学校代码','考试单位类型','考试类别','试卷代码']
        
        batlist={"秋季":"09","春季":"03"}
        examunitlist={"中央":"1","省":"2","国开":"1","省开":"2"}
        
    
        with open(csvname,'w',newline='',encoding='gb2312') as csvfile:
                wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
                wb = xlrd.open_workbook(xlsfile)
             
             
                for sh in wb.sheets():
                        if sh.nrows==0:
                                print("{} is empty".format(sh.name))
                                continue
                        # deal with mutilplines
                        # from the second line 
                        bColOrder=True
                        rowcollist=sh.row_values(0)
                        for i in range(len(col_sign)):
                                if i==len(col_sign)-1:
                                        if col_sign[i][0:2]!=rowcollist[i][0:2]:
                                                bColOrder=False
                                                print ("sheet:{} {}'s {} is not current order".format(xlsfile,sh.name,col_sign[i]))
                                else:                
                                        if col_sign[i] not in rowcollist[i]:
                                                bColOrder=False
                                                print ("sheet:{} {}'s {} is not current order".format(xlsfile,sh.name,col_sign[i]))
                                                break
                        if bColOrder==False:
                                continue
                        lins = [x for x in range(1,sh.nrows)]
                        iTotal=0
                        iValid=0
                        for rownum in lins:
                                bvalid=True
                                csvlist=["" for x in range(27)]
                                            
                                rowlist =[str(item).replace('\n',' ').replace(',',' ').strip() for item in sh.row_values(rownum)]
                                #print("{},{}".format(rownum,rowlist))
                                csvlist[0]="1" # SN
                                csvlist[1]=rowlist[1][:6] #exambatchcode
                                csvlist[2]=rowlist[1][:6] #exambatchcode
                                csvlist[3]=rowlist[5]     #ExamCategory
                                # csvlist[4] accessmode
                                # csvlist[5] examsitecode
                                # csvlist[6] examsessionunit
                                if  rowlist[6]!='':
                                        if papercodetype=='4':                 
                                                csvlist[7]=newPaperCode(removelast(str(rowlist[6]))) #exampapercode
                                        else: 
                                                csvlist[7]=str(removelast(rowlist[6])).zfill(5)
                           
                                #csvlist[8] # exampapermemo
                                csvlist[9]=str(removelast(rowlist[2])).zfill(5) #courseid
                                #csvlist[10] tcpcode
                                csvlist[11]=rowlist[3][:3] #segmentcode
                                csvlist[12]=rowlist[3][:5] #collegecode
                                csvlist[13]=removelast(rowlist[3])     #learningcentercode
                                #get info by redis
                                if removelast(rowlist[0]) not in studict.keys():
                                        bvalid=False
                                        print("{}:{},{},{} no find".format(sh.name,rownum,rowlist[0],rowlist[3]))
                                else:
                                        dic=studict[removelast(rowlist[0])]
                                        csvlist[14]=dic['CLASSCODE'] #classcode
                                        csvlist[15]=removelast(rowlist[0]) #studentcode
                                        csvlist[16]=examunitlist[rowlist[4]] #examunit
                                        csvlist[17]='elximp'
                                        #csvlist[18] applicatedate
                                        #csvlist[19] signuptype
                                        csvlist[20]='1' # isconfirm
                                        #csvlist[21] confirmreason
                                        #csvlist[22] confirmer
                                        #csvlist[23] confirmdate
                                        #csvlist[24] feecertificate
                                        #csvlist[25] elc_refid
                                        #csvlist[26]=getRedis(rowlist[2],'gb')[1]
                                         
                                        
                                        #print("{key}{val}".format(key=rowlist[5],val=getRedis(rowlist[5])))
                                 
                            
                                iTotal+=1
                                if bvalid==True:
                                        iValid+=1
                                        wr.writerow(csvlist)
                        print("{}:Totla{},valid{}".format(sh.name,iTotal,iValid))
    
def getScore(rekey):
        scorelist=['' for x in range(3)]
        reScore = redis.Redis(host='10.96.142.109',port=6380,db=8)
        score = reScore.hget('maxscore',rekey)
        if score is not None:
                scorelist=score.decode('utf-8').split(',')
                return scorelist
    

def expStatus(csvname,impcsvfile):
     
        reScore = redis.Redis(host='10.96.142.109',port=6380,db=8)
        reSign = redis.Redis(host='10.96.142.109',port=6380,db=7)
        with open(csvname,'w',newline='',encoding='gb2312') as csvfile:
                wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
                #progress 
                
                impcsv=open(impcsvfile,'r')
                csvline = len(impcsv.readlines())
                impcsv=open(impcsvfile,'r')
                
                reader = csv.reader(impcsv,delimiter=',')
                i=0
                printProgress(i,csvline,prefix='Process',suffix='Complete',barLength=50)
         
                for row in reader:
                        exprow=[1 for x in range(9)]
                        exprow[1]=row[0] #studentcode
                        exprow[2]=row[1] #courseid
                        #get score
                        score = reScore.hget('maxscore',''.join(row))
                        #print("{}:{}".format(''.join(row),score))
                        if score is not None:
                                scorelist=score.decode('utf-8').split(',')
                                if float(scorelist[0])>59:
                                        exprow[3]='4' #studystatus
                                exprow[5]=scorelist[0]#score
                                exprow[6]=scorelist[1]  #scorecode
                                exprow[7]=scorelist[2]  #scoretype
                        #get signnum
                        sign = reSign.get(''.join(row))
                        if sign is not None:
                                exprow[4]=sign.decode('utf-8')
                        wr.writerow(exprow)
                        i +=1
                        printProgress(i,csvline,prefix='Process',suffix='Complete',barLength=50) 
   
                impcsv.close()   
             
             
def expStatus2(csvname,statuscsv,scorecsv):
        #dfstatus = pd.read_csv(statuscsv,header=None,dtype=object,name=['studentcode','courseid'])
        dfstatus =pd.read_csv(statuscsv,header=None,dtype={'studentcode':str,'courseid':str},names=['studentcode','courseid'])
        df2=pd.read_csv(scorecsv,header=None,dtype={'studentcode':str,'courseid':str,'score':np.float64,'scorecode':str,'scoretype':str},names=['studentcode','courseid','score','scorecode','scoretype'])
        idx = df2.groupby(['studentcode','courseid'])['score'].transform(max)==df2.score
        df3=df2[idx]
        #df3['iid']=df3.index
        df3.reset_index(level=0,inplace=True) #first column 'name is index to index's clone
        idx2=df3.groupby(['studentcode','courseid'])['index'].transform(max)==df3['index']
        dflast=df3[idx2]
        expdf=pd.merge(dfstatus,dflast,on=['studentcode','courseid'],how='left')
        expdf['scorestatus']=expdf.score.apply(lambda value:4 if value>59 else 1)
        expdf[['studentcode','courseid','scorestatus','score','scorecode','scoretype']].to_csv(csvname,index=False)   
        #df.columns=['studentcode','courseid']
        #df[2]=df[1].apply(lambda value:'0'*(5-len(str(value)))+str(value))
        #df.courseid=df.courseid.astype(str)
        #df.courseid=df.courseid.apply(lamdba value:'0'*(5-len(value))+value)
   
 
def main():
        global re
        xlsfile = sys.argv[1]
        base= os.path.basename(xlsfile)
        basename=os.path.splitext(base)[0]
        if basename[:3]=='elc':
                expElc("./export/data_{}.csv".format(basename),xlsfile)
        elif basename[:6]=='score4':
                expScore("./export/data_{}.csv".format(basename),xlsfile,'4')
        elif basename[:6]=='score5':
                expScore("./export/data_{}.csv".format(basename),xlsfile,'5')    
        elif basename[:7]=='signup4':
                expSignup("./export/data_{}.csv".format(basename),xlsfile,'4')
        elif basename[:7]=='signup5':
                expSignup("./export/data_{}.csv".format(basename),xlsfile,'5')
        elif basename[:6]=='status':
                #expStatus("data_{}.csv".format(basename),xlsfile)
                expStatus2("./export/data_{}2.csv".format(basename),"status.csv","score_109.csv")
        
 
if __name__=='__main__':
        main()

