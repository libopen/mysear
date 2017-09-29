import sys
from time import sleep

#print iterations progress
def printProgress(iteration, total,prefix = '',suffix='' ,decimals=1,barLength=100):
    """
    all in a loop to create terminal progress bar
    params:
    iteration  - Required : current iteration (Int)
    total      - Required : total iterations  (Int)
    prefix     - Optional : prefix string (Str)
    suffix     - Optional : suffix string (Str)
    decimals   - Optional : positive number of decimals in percent complete (Int)
    barLengh   - Optional : charchter length of bar (Int)
    """

    
    percent = "{}".format(100*(iteration / float(total)))
    filledLength = int(round(barLength * iteration / float(total)))
    bar ='*' * filledLength + '-' * (barLength - filledLength)
    sys.stdout.write('\r%s |%s| %s%s %s' % (prefix,bar,percent,'%',suffix))
    if iteration == total:
       sys.stdout.write('\n')
    sys.stdout.flush()



def test():
   
   items = list(range(100))
   l = len(items)

   printProgress(0,l,prefix='Progress:',suffix='Complete',barLength=50)
   for item in items:
       sleep(0.1)
   
       printProgress(item,l,prefix='Progress:',suffix='Complete',barLength=50)


if __name__=='__main__':
     test()
   
