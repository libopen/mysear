options(bindsize=65536000,readsize=80000000,rows=10000)
load data
CHARACTERSET ZHS16GBK 
infile *
BADFILE  './eas_schroll_student1.bad'
DISCARDFILE './eas_schroll_student1.dsc'
truncate into table eas_schroll_student1
fields terminated by ','
trailing nullcols
(
StudentID  "TRIM(:StudentID)",
StudentCode  "TRIM(:StudentCode)",
TCPCode  "TRIM(:TCPCode)",
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
