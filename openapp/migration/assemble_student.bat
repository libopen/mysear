echo "auditrule"
cd /d G:/migration/Pyexp 
c:/python34/python.exe expCpsSingle.py SchRoll_student zssj1 impnewstudent2017\csv
rem pause
c:/python34/python.exe expCpsSingle.py SchRoll_studentBaseInfo zssj1 impnewstudent2017\csv
c:/python34/python.exe expCpsSingle.py cps_student zssj1 impnewstudent2017\csv
c:/python34/python.exe expCpsSingle.py Org_class zssj1 impnewstudent2017\csv
