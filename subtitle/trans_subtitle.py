import urllib.request ,json ,csv,sys,urllib,os,re

import time
from mimetypes import guess_extension

def getmp3(path,mp3name):
    try:
        time.sleep(1)
        urlbase="http://res.iciba.com/resource/amp3"
        urllib.request.urlretrieve('%s%s'%(urlbase,path), mp3name)
        
        return mp3name
    except:
        print('%s%s fail'%(path))
        return ''
        
def trans(word):
    try:
        url="http://fanyi.baidu.com/v2transapi?from=en&query="+word+"&to=zh"
        request=urllib.request.Request(url)
        result=urllib.request.urlopen(request)
        the_page=result.read()
        jsonarr=json.loads(the_page.decode('utf-8'))
    #if jsonarr["status"]!=u"0":
    #    print jsonarr["msg"]
    #    exit()
    #result=jsonarr['dict_result']['simple_means']['word_means']:
    #for value in jsonarr['dict_result']['simple_means']['word_means']:
    #    print key.encode('utf-8')
    #    print value.encode('utf-8')
        #for ph in jsonarr['dict_result']['simple_means']['symbols']:
        en=jsonarr['dict_result']['simple_means']['symbols'][0]['ph_en']
        am=jsonarr['dict_result']['simple_means']['symbols'][0]['ph_am']
        ph='英音/%s/ 美音/%s/'%(en,am)
        mp3path=jsonarr['dict_result']['simple_means']['symbols'][0]['ph_am_mp3']
        mp3name=''    
        if mp3path!='':
           mp3name=getmp3(mp3path,mp3path.split('/')[-1])
         
        
        meanlist=[]
           
        
        for val in jsonarr['dict_result']['simple_means']['symbols'][0]['parts']:
            mean=[item.replace('\t','') for item in val['means']]
            part=val['part']
            meanlist.append('[%s]%s'%(part,''.join(mean)))
            
            #print val['part'].encode('utf-8'),','.join(mean)
            #res.append(val['part'].encode('utf-8')+'  '+','.join(mean))
        #for mean in val['means']:
        #    print mean.encode('utf-8')
        #print ' '.join(res)
        return ph,'<br>'.join(meanlist),mp3name
    except:
        print("{} translate fault".format(word,))
        return "","",""
       
def gettranslist(file):
    retlist=[]
    csvlist=[] # 用于记录每个时间段内的所有出现
    basename=os.path.basename(file).split('.')[0]
    csvfile="{}".format(basename)
    reader=open(file,'r')
    p=re.compile('\d{2}:\d{2}')
    beginsection='00:00'
    csvlist.append(beginsection)
    for curline in reader:
        wordlst=curline.replace('.','').replace('?','').replace('\n','').replace(',','').split(' ')
        for word in wordlst:
            if word.isalpha() and word.lower() not in retlist:
                retlist.append(word.lower())
            if len(p.findall(word))==0: # not match 00:00:dd
                if word.isalpha() and word.lower() not in csvlist:
                    csvlist.append(word.lower())
            else:
                cursection=p.findall(word)[0]
                if cursection!=beginsection:
                    beginsection=cursection
                    csvlist.append(cursection)
    return csvfile,retlist,csvlist
        
def writetrans(csvfilename,wordlist,csvlist):
    with open("{}.csv".format(csvfilename),'w',newline='',encoding='utf-8') as csvfile:
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
    with open("{}_section.csv".format(csvfilename),'w',newline='',encoding='utf-8') as csvfile:
        wr=csv.writer(csvfile,quoting=csv.QUOTE_NONE,delimiter='\t',quotechar='',escapechar='\\')
        rowlist=['' for item in range(1)]
        for line in csvlist:
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
    

    csvfile,wordlist,csvlist=gettranslist(file)
    if len(wordlist)!=0:
        writetrans(csvfile, wordlist,csvlist)
        
    
def main():
    file=sys.argv[1]
    dotran(file)
   
if __name__=="__main__":
    main()
    #urllib.request.urlretrieve("http://res.iciba.com/resource/amp3/1/0/46/b3/46b3931b9959c927df4fc65fdee94b07.mp3","46b3931b9959c927df4fc65fdee94b07.mp3")
    

