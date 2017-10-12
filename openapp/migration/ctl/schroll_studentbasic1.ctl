options(bindsize=6553600,readsize=9000000,rows=1000,errors=1000)
load data 
CHARACTERSET ZHS16GBK 
infile *
BADFILE  './eas_schroll_studentbasic1.bad'
DISCARDFILE './eas_schroll_studentbasic1.dsc'
truncate into table eas_schroll_studentbasic1
fields terminated by ','
trailing nullcols
(
StudentID  "TRIM(:StudentID)",
StudentCode  "TRIM(:StudentCode)",
Gender  "TRIM(:Gender)",
Ethnic  "TRIM(:Ethnic)",
PoliticsStatus  "TRIM(:PoliticsStatus)",
MaritalStatus  "TRIM(:MaritalStatus)",
Hometown  "TRIM(:Hometown)",
BirthDate DATE"yyyy-mm-dd"NULLIF (BirthDate="NULL"),
Education  "TRIM(:Education)",
WorkingTime DATE"yyyy-mm-dd"NULLIF (WorkingTime="NULL"),
HuKou  "TRIM(:HuKou)",
IDNumber  "TRIM(:IDNumber)",
Distribution  "TRIM(:Distribution)",
Tuition  "TRIM(:Tuition)",
AdmissionNumber  "TRIM(:AdmissionNumber)",
WorkUnits  "TRIM(:WorkUnits)",
WorkAddress  "TRIM(:WorkAddress)",
WorkZipCode  "TRIM(:WorkZipCode)",
WorkPhone  "TRIM(:WorkPhone)",
MyZipCode  "TRIM(:MyZipCode)",
MyPhone  "TRIM(:MyPhone)",
DiplomaNumber  "TRIM(:DiplomaNumber)",
ProfessionalSituation  "TRIM(:ProfessionalSituation)",
Mobile  "TRIM(:Mobile)",
DocumentType  "TRIM(:DocumentType)",
IDCard  "TRIM(:IDCard)",
MyAddress  "TRIM(:MyAddress)",
Email  "TRIM(:Email)"
)
begindata
