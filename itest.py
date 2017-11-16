import pandas as pd
import STTB,imp,sys
def ddb(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    gp=s.getexdb()[s.DBF]
    print(gp[-20:].to_csv(sep='\t'))
    return gp[-20:]

def wdb(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STWTB(sn)
    gp=s.getexdb()[s.DBF]
    print(gp[-20:].to_csv(sep='\t'))
    return gp[-20:]


def dseed(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    exdb=s.seed()
    print(exdb.to_csv(sep='\t'))
    return exdb
def wseed(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STWTB(sn)
    gp=s.seed()
    print(gp.to_csv(sep='\t'))
    return gp
      
def testkmt(sn='ss123456'):
    imp.reload(STTB)
    _std=STTB.STDTB(sn)
    _stw=STTB.STWTB(sn)
    if _stw.seed() is not None:
        _gp=_stw.seed()[['sn','seedmod','areamod','keymod']]
        _dgp=_std.seed()[['seedmod','areamod','keymod']]
        _dgp.columns=['dseedmod','dareamod','dkeymod']
        gp=pd.concat([_gp,_dgp],axis=1)[['sn','seedmod','areamod','keymod','dseedmod','dareamod','dkeymod']]
        gp['keymod_key']=gp['keymod'].str.split(':').str[0].astype(str)
        gp['dkeymod_key']=gp['dkeymod'].str.split(':').str[0].astype(str)
        cols=['sn','areamod','dareamod','seedmod','dseedmod','keymod_key','dkeymod_key','keymod','dkeymod']
        print(gp.to_csv(sep='\t'))
        return gp[cols]
    
def main():
    testkmt(sys.argv[1])
    
if __name__=="__main__":
    main()