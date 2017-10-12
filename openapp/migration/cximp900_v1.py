# -*- coding: utf-8 -*-
import os
import sys
import datetime
import csv
import time
import cx_Oracle

def geteas_schroll_studentbaseinfo(segmentcode):
    ts = time.time()
    try:       
       with open('eas_schroll_studentbaseinfo900.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select StudentID   , StudentCode   , Gender   , Ethnic   , PoliticsStatus   , MaritalStatus   , Hometown   ,to_char( BirthDate,'yyyy-mm-dd') , Education   , to_char(WorkingTime,'yyyy-mm-dd') , HuKou   , IDNumber   , Distribution   , Tuition   , AdmissionNumber   , WorkUnits   , WorkAddress   , WorkZipCode   , WorkPhone   , MyZipCode   , MyPhone   , DiplomaNumber   , ProfessionalSituation   , Mobile   , DocumentType   , IDCard   , MyAddress   , Email     from  EAS_SchRoll_StudentBasicInfo  where exists(select * from eas_schroll_student where studentid=eas_schroll_studentbasicinfo.studentid and substr(learningcentercode,1,2)=:segmentcode)"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_schroll_studentbaseinfo %r: took  %s seconds  '%(segmentcode,time.time()-ts))  

def geteas_elc_studystatus(segmentcode):
    ts = time.time()
    try:       
       with open('eas_elc_studentstudystatus900.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select *   from  EAS_elc_studentstudystatus  where exists(select * from eas_schroll_student where studentcode=eas_elc_studentstudystatus.studentcode and substr(learningcentercode,1,2)=:segmentcode)"
            con = cx_Oracle.connect(connstr)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_elc_studystatus %r: took  %s seconds  '%(segmentcode,time.time()-ts))  

def getcps_student(segmentcode):
    ts = time.time()
    try:       
       with open('cps_student900.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select StudentID   , BatchCode   , StudentCode   , TCPCode   , LearningCenterCode   , ClassCode   , SpyCode   , ProfessionalLevel   , StudentType   , StudentCategory   , OriginalCategory   , EnrollmentStatus   , to_char(AdmissionTime,'yyyy-mm-dd'), FullName  from  eas_schroll_student  where substr(learningcentercode,1,2)=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('cps_student %r: took  %s seconds  '%(segmentcode,time.time()-ts))  




def geteas_spy_openspylearn(segmentcode):
    ts = time.time()
    try:       
       with open('eas_spy_openspylearn'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            #sql = "select 1 SN   , SegmentOrgCode   , LearningCenterOrgCode   , SpyCode  , StudentType    , ProfessionalLevel  , OpenState    , to_char(CreateTime,'yyyy-mm-dd')  from EAS_Spy_OpenSpyLearningCenter where SegmentOrgCode=:segmentcode"
            sql = "select *  from EAS_Spy_OpenSpyLearningCenter where substr(SegmentOrgCode,1,1)=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_spy_openspylearn %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def geteas_spy_openspysegment(segmentcode):
    ts = time.time()
    try:       
       with open('eas_spy_openspysegment'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select 1 SN   , SegmentCode   , SpyCode  , StudentType    , ProfessionalLevel  , OpenState    , to_char(CreateTime,'yyyy-mm-dd')  from EAS_Spy_OpenSpySegment where segmentcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_spy_openspysegment %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getleasemcourse(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_learcentsemecour'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select 1 SN   , BatchCode   , OrgCode   , LearningCenterCode   , CourseID   , Semester   , IsExistTCP  , to_char(CreateTime ,'yyyy-mm-dd')  from EAS_TCP_LearCentSemeCour where orgcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_learcentsemecour %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getsegsemcourse(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_segmsemecourses'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select SN   , YearTerm   , OrgCode   , CourseID   , Semester   , IsExistTCP  , to_char(CreateTime,'yyyy-mm-dd') ,'end'    from EAS_TCP_SegmSemeCourses where orgcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_segmsemecourses %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getsegcourse(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_segmentcourses'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select 1 SN   , OrgCode   , CourseID   , CourseState   , to_char(CreateTime,'yyyy-mm-dd') as dd    from EAS_TCP_SegmentCourses where orgcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_segmentcourses %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getcomposescore(segmentcode):
    ts = time.time()
    try:       
       with open('exmm_composescore'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select 1 SN   , SegmentCode   , CollegeCode  , ClassCode  , ExamPlanCode  , ExamCategoryCode  , ExamUnit   , CourseID   , newpapercode(ExamPaperCode)  , LearningCenterCode   , StudentCode   , PaperScore   , PaperScoreCode   , XkScore   , XkScoreCode   , XkScale   , ComposeScore   , ComposeScoreCode  , to_char(ComposeDate,'yyyy-mm-dd') , to_char(PublishDate,'yyyy-mm-dd')  , IsComplex   , IsPublish   from EAS_ExmM_ComposeScore where segmentcode=:segmentcode"
            con = cx_Oracle.connect(connstr)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('exmm_composescore %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getclass(segmentcode):
    ts = time.time()
    try:       
       with open('EAS_Org_ClassInfo'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select 1 ClassID   , BatchCode   , LearningCenterCode   , ClassCode   , ClassName   , StudentCategory   , SpyCode   , ProfessionalLevel   , ExamSiteCode   , ClassTeacher   , to_char(CreateTime,'yyyy-mm-dd')    from EAS_Org_ClassInfo where substr(LearningCenterCode,1,3)=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('EAS_Org_ClassInfo %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getlearncourse(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_learcentcourse'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select SN   , SegOrgCode   , LearningCenterCode   , CourseID   , CourseState   , to_char(CreateTime,'yyyy-mm-dd')    from EAS_TCP_LearCentCourse where segorgcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_learcentcourse %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getimplcourse(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_implmodulecourse'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql ="select SN   , BatchCode   , TCPCode   , SegmentCode   , ModuleCode   , CourseID   , CourseNature   , ModifiedCourseNature   , ExamUnitType   , ModifiedExamUnitType   , Credit   , hour   , IsDegreeCourse   , IsExecutiveCourse   , IsExtendedCourse   , IsSimilarI   , ExtendedSource   ,to_char( CreateTime,'yyyy-mm-dd')  from EAS_TCP_ImplModuleCourse where segmentcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_implmodulecourse %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getimpl(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_implementation'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select SN   , BatchCode   , OrgCode   , TCPCode   , MinGradCredits   , MinExamCredits   , ExemptionMaxCredits   , EducationType   , StudentType   , ProfessionalLevel   , SpyCode   , SchoolSystem   , DegreeCollegeID   , DegreeSemester   , ImpState   ,to_char( CreateTime,'yyyy-mm-dd') , Implementer   , to_char(ImpTime,'yyyy-mm-dd')  from EAS_TCP_Implementation where orgcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_implementation %r: took  %s seconds  '%(segmentcode,time.time()-ts))  



def getexec(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_execution'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select SN   , BatchCode   , SegmentCode   , LearningCenterCode   , TCPCode   , MinGradCredits   , MinExamCredits   , ExemptionMaxCredits   , EducationType   , StudentType   , ProfessionalLevel   , SpyCode   , SchoolSystem   , DegreeCollegeID   , DegreeSemester   , ExcState   , to_char(CreateTime,'yyyy-mm-dd') , Executor   ,to_char(ExecuteTime,'yyyy-mm-dd') from EAS_TCP_Execution where segmentcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            #columns = [i[0] for i in cur.description]
            #print (len(columns))
            #for col in columns:
            #    print(col)
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_execution %r: took  %s seconds  '%(segmentcode,time.time()-ts))  


def getexecmodules(segmentcode):
    ts = time.time()
    try:       
       with open('eas_tcp_execmodulecourse'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select SN   , BatchCode   , TCPCode   , SegmentCode   , LearningCenterCode   , ModuleCode   , CourseID   , CourseNature   , ExamUnitType   , Credit   , hour   , SuggestOpenSemester   , PlanOpenSemester   , IsDegreeCourse   , IsSimilar   , to_char(CreateTime,'yyyy-mm-dd') from eas_tcp_execmodulecourse where segmentcode=:segmentcode"
            con = cx_Oracle.connect(connstr1)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            #columns = [i[0] for i in cur.description]
            #print (len(columns))
            #for col in columns:
            #    print(col)
            
            for row in cur:
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('eas_tcp_execmodulecourse %r: took  %s seconds  '%(segmentcode,time.time()-ts))  

def getsignupinfo(segmentcode):
    ts = time.time()
    try:       
       with open('eas_exmm_signup'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = "select 1 as sn ,a.exambatchcode,a.examplancode,a.examcategorycode,a.assessmode,examsitecode,newpapercode(a.exampapercode),a.courseid,a.segmentcode,a.collegecode,a.learningcentercode,a.classcode,a.studentcode,a.examunit,a.applicant,a.feecertificate,to_char(a.applicatdate,'yyyy-mm-dd'),a.isconfirm,a.coursename  from eas_exmm_signup a  where a.segmentcode=:segmentcode"
            con = cx_Oracle.connect(connstr)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            
            for row in cur:
                #wr.writerow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18]))
                wr.writerow((row))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('signup %r: took  %s seconds  '%(segmentcode,time.time()-ts))       

def getelcinfo(segmentcode):
    ts = time.time()
    try:       
       with open('elc_elc'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            #sql = "select 1 sn,A.BATCHCODE ,A.STUDENTCODE ,A.COURSEID ,A.LEARNINGCENTERCODE ,A.CLASSCODE ,A.ISPLAN ,A.OPERATOR ,A.ELCSTATE ,to_char(A.OPERATETIME,'yyyy-mm-dd') ,A.CONFIRMOPERATOR ,A.CONFIRMSTATE ,to_char(A.CONFIRMTIME,'yyyy-mm-dd') ,A.CURRENTSELECTNUMBER ,A.ISAPPLYEXAM ,A.ELCTYPE ,A.LEARNINGCENTERCODE||A.STUDENTCODE ,A.REFID ,A.SPYCODE  from eas_elc_studentelcinfo a  where a.learningcentercode like :learningcentercode"
            sql = "select a.*  from eas_elc_studentelcinfo a  where a.learningcentercode like :learningcentercode"
            con = cx_Oracle.connect(connstr)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'learningcentercode':segmentcode+'%'})
            for row in cur:
                #wr.writerow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18]))
                wr.writerow((row))
            cur.close()
            con.close()
    finally:
        csvfile.close()
    print('elc %r: took  %s seconds  '%(segmentcode,time.time()-ts))       


         


def main():
    global connstr,connstr1
    connstr = 'ouchnsys/Jw2015@10.100.134.179:1521/orcl'
    connstr1 = 'ouchnsys/Jw2015@10.100.134.177:1521/orcl'
    segments=['901','902','903','904','905','906','907']
    #geteas_elc_studystatus('90')
    geteas_spy_openspylearn('9')
    #geteas_schroll_studentbaseinfo('90')
    #getcps_student('90')
    #for segcode in segments:
         #getsignupinfo(segcode)
         #getelcinfo(segcode)
         #getexecmodules(segcode)
         #getexec(segcode)
         #getimpl(segcode)
         #getimplcourse(segcode)
         #getlearncourse(segcode)
         #getclass(segcode)
         #getcomposescore(segcode)
         #getsegcourse(segcode)
         #getsegsemcourse(segcode)
         #getleasemcourse(segcode)
         #geteas_spy_openspysegment(segcode)
         #geteas_spy_openspylearn(segcode)
        
#-------------
os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.ZHS16GBK'
if __name__=='__main__' :
     main()
