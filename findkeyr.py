import pandas as pd
import sys,os
import numpy as np
import talib 


ROOTPATH='/home/lib/mypython/export/'
#GPTITLE=['sn','startdate','startc','maxc','rat','updown','aft1','pre1','pre2','pre3','absmacd1','absmacd2','absmacd3','minl1','minl2','minl3']

GPTITLE=['sn','startdate','rat','updown','pre1','pre2','pre3','pos_dif1','pos_dif3','turnid']
# db method
def red(x):
    if x.c>x.o :
        return 1
    else:
        return -1
def poschange(x):
    if (x.mt>0 and x.macd<0 ) or (x.mt<0 and x.macd>0):
        return x.id
    else:
        return 0

def regroup(db):
    curid=0
    for index,row in db.iterrows():
        if row['trn']!=0:
            curid=row['trn']
        db.loc[index,'gpid']=curid
    return db


def createdb1(file):
    #file=sys.argv[1]
    db=None
    try:
        base=os.path.splitext(file)[0]
        sn=base[-6:]
        #print(sn)
        db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
        db['id']=db.index
        db['dif'],db['dea'],db['macd']=talib.MACD(np.array(db.c),12,26,9)
        db['absmacd']=db.macd.abs()
        db['mt']=db.macd.shift(1)
        db['trn']=db.apply(poschange,axis=1)
        db['gpid']=0
        db['red']=db.apply(red,axis=1)
        db['updown']=db.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
        db['pos_dif']=db.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
        regroup(db)

    finally:
        return sn,db

def makegp(sn,db):
    # group by gpid get sum of md and gpred
    gp1=db.groupby('gpid').sum()[['updown','pos_dif']]
    gp2=db.groupby('gpid').max()[['h','c','absmacd']]
    gp2.columns=['maxh','maxc','absmacd']
    gp22=db.groupby('gpid').min()[['l']]
    gp22.columns=['minl']
    idx=db.groupby('gpid')['id'].transform(min)==db['id']
    gp3=db[idx][['gpid','date','h','l','o','c','v']]
    gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
    gp3=gp3.set_index('gpid')
    idx1=db.groupby('gpid')['dif'].transform(min)==db['dif']
    gp33=db[idx1][['gpid','id']]
    gp33.columns=['gpid','difid']
    gp33=gp33.set_index('gpid')

    gp=pd.concat([gp1,gp2,gp22,gp3,gp33],axis=1,join="inner")
    #gp=pd.concat([gp,gp33],axis=1,join="inner")
    #return gp33,gp
    gp['turnid']=gp.updown.abs()-(gp.difid-gp.index)
    gp['pre1']=gp.updown.shift(1)
    gp['pre2']=gp.updown.shift(2)
    gp['pre3']=gp.updown.shift(3)
    gp['pos_dif1']=gp.pos_dif.shift(1)
    gp['pos_dif2']=gp.pos_dif.shift(2)
    gp['pos_dif3']=gp.pos_dif.shift(3)
    gp['sn']=sn
    gp['rat']=(gp.maxc/gp.startc-1)*100
    
    return gp[-2:].fillna(0)
    


def getallfile(rootpath):
    resultlist=[]
    for lists in os.listdir(rootpath):
        path=os.path.join(rootpath,lists)
        if os.path.isdir(path):
            pass
        else:
            if os.path.basename(path)[0]=='S' and os.stat(path).st_size!=0:
            #if os.path.basename(path)[0:5]=='SH600' and os.stat(path).st_size!=0: 
                resultlist.append(path)
    return resultlist



# find 
def Allfind(rootpath=ROOTPATH,findtype='0'):
    result=pd.DataFrame(columns=GPTITLE)
    snlist=getallfile(rootpath)

    for path in snlist:

        dbcurrent=result
        sn,db=createdb1(path)
            #print(path)
        if db is not None:
            try:
                gp=makegp(sn, db)
                if findtype=='0':
                    result=dbcurrent.append(keyfind(gp))
                elif findtype=='2':
                    result=dbcurrent.append(keyfind2(gp))               
            except:
                print(sn)
                continue
    #result.to_csv('myfind.csv')   
    return result



def singlefind(sn,findtype='0'):
    sn,db=createdb1(ROOTPATH+sn+'.txt')
            #print(path)
    result=None
    if db is not None:
        gp=makegp(sn, db)   
        if findtype=='0':
            result=keyfind(gp)
        elif findtype=='2':
            result=keyfind2(gp)
    return result

def keyfind(gp):
    # keyfind4 标准版本
    # 
     return gp[                                                                                                                                         
               (gp.pre1<-20) & 
               (gp.pos_dif1<0)&
               (gp.pos_dif3>0)&
               (gp.pre1>gp.pre3)&
                (gp.updown<8)&
                (gp.rat<2)
    
               ][GPTITLE]



def keyfind2(gp):
    # pos1:     the last number and number<0
    # pos2:      rat>3 时，pre1.abs()>pre3.abs() 占90%
    # pos3:entrance
    # rat >3 77% (gp.pre1<0)&(gp.pre1.abs()>20)&(gp.pos_dif1<0)&(gp.pos_dif3>0)
    if gp.empty==False:
       gp=gp[-1:]
       return gp[                                                                                                                                         
               (gp.updown<-20) & 
               (gp.pos_dif<0)&
               (gp.pos_dif2>0)&
               (gp.updown>gp.pre2)&
                (gp.turnid>0)
               ][GPTITLE]


def readgp(csvfile):
    return pd.read_csv(csvfile,header=None,skiprows=1,names=GPTITLE)


def main():
    #path=sys.argv[1]
    #db=keyfindall(path)
    #result=db.sort('date')
    #result.to_csv('myfind.csv')
    #analysis(db)
    findtypeid=sys.argv[1]
    gp= Allfind( findtype=findtypeid)
    gp.to_csv("find{}.csv".format(findtypeid))
    




if __name__=="__main__":
    #findall(sys.argv[1])
    #find('/home/lib/mypython/export/export/SZ300376.txt')
    main()

