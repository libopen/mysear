options(bindsize=65536000,readsize=80000000,rows=10000)
load data
CHARACTERSET ZHS16GBK 
infile *
BADFILE  './cps_student.bad'
DISCARDFILE './cps_student.dsc'
truncate into table cps_student
fields terminated by ','
trailing nullcols
(
StudentID  "TRIM(:StudentID)",
gzbatch  "TRIM(:gzbatch)",
StudentCode  "TRIM(:StudentCode)",
oldTCPCode  "TRIM(:oldTCPCode)",
LearningCenterCode  "TRIM(:LearningCenterCode)",
ClassCode  "TRIM(:ClassCode)",
SpyCode  "TRIM(:SpyCode)",
ProfessionalLevel  "TRIM(:ProfessionalLevel)",
StudentType  "TRIM(:StudentType)",
StudentCategory  "TRIM(:StudentCategory)",
OriginalCategory  "TRIM(:OriginalCategory)",
EnrollmentStatus  "TRIM(:EnrollmentStatus)",
AdmissionTime DATE "yyyy-mm-dd"  NULLIF (AdmissionTime="sysdate"),
batchcode "trim(:batchcode)",
FullName  "TRIM(:FullName)"
)
begindata

