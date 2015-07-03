import make_d
import make_w
import make_m
p=make_d.dbSource('/home/user/programe/','mygd.csv')
p.makedb()
p.exp_gngroup()
p.exp_exright()
del p
pw=make_w.dbSource('/home/user/programe/','mygd.csv')
pw.makedb()
pw.exp_w()
pw.exp_wgngroup()
del pw
pm=make_m.dbSource('/home/user/programe/','mygd.csv')
pm.makedb()
pm.exp_m()
del pm


