options(bindsize=65536000,readsize=80000000,rows=10000)
load data
CHARACTERSET ZHS16GBK 
infile *
BADFILE  './cps_classinfo.bad'
DISCARDFILE './cps_classinfo.dsc'
truncate into table CPS_ClassInfo
fields terminated by ','
trailing nullcols
(
ClassID  "org_class_Seq.nextval",
BatchCode  "TRIM(:BatchCode)",
LearningCenterCode  "TRIM(:LearningCenterCode)",
ClassCode  "TRIM(:ClassCode)",
ClassName  "TRIM(:ClassName)",
StudentCategory  "TRIM(:StudentCategory)",
SpyCode  "TRIM(:SpyCode)",
ProfessionalLevel  "TRIM(:ProfessionalLevel)",
ExamSiteCode  "TRIM(:ExamSiteCode)",
ClassTeacher  "TRIM(:ClassTeacher)",
CreateTime  DATE "yyyy-mm-dd" NULLIF (CreateTime="NULL")
)
begindata
