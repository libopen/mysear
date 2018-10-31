import urllib.request ,json ,csv,sys,urllib,os,re

import time
from mimetypes import guess_extension


       
def gettranslist(file):
    retlist=[]
    sameline=[] # 属于同一时间下 
    basename=os.path.basename(file).split('.')[0]
    csvfile="{}".format(basename)
    reader=open(file,'r',encoding='UTF-8')
    p=re.compile('\d{2}:\d{2}')
    beginsection='00:00'
    
    for curline in reader:
            
            if len(p.findall(curline))>0: # match 00:00:dd 'it's new subtitle
                    retlist.append("".join(sameline)) # add new lrc 
                    sameline.clear()
                    curline=curline.replace(',','.')
                    sameline.append("[{}]".format(str(curline)[3:11]))
                    if curline=='02:23.15':
                        prinf(sameline)
            else:
                curline=curline.replace('.','').replace('?','').replace('\n','').replace(',','')
                p1=re.compile('^\d+$')
                if len(p1.findall(curline))==0:
                    sameline.append(" {}".format(curline))
    return csvfile,retlist
        
def writetrans(csvfilename,wordlist):
    with open("{}.lrc".format(csvfilename),'w',newline='',encoding='utf-8') as csvfile:
        wr=csv.writer(csvfile,quoting=csv.QUOTE_NONE,delimiter='\t',quotechar='',escapechar='\\')
        rowlist=['' for item in range(1)]
        for line in wordlist:
            if len(line)!=0:
                rowlist[0]=line
                #ret=trans(rowlist[0])
                #rowlist[1]=ret[0]
                #rowlist[2]=ret[1]
                #rowlist[3]=ret[2]
                wr.writerow(rowlist)  
                print(rowlist[0])
        csvfile.close() 
   
        
                 
def dotran(file):
    

    csvfile,wordlist=gettranslist(file)
    if len(wordlist)!=0:
        writetrans(csvfile, wordlist)
        
    
def main():
    file=sys.argv[1]
    dotran(file)
   
if __name__=="__main__":
    main()
    #urllib.request.urlretrieve("http://res.iciba.com/resource/amp3/1/0/46/b3/46b3931b9959c927df4fc65fdee94b07.mp3","46b3931b9959c927df4fc65fdee94b07.mp3")
    

