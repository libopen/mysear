--
-- PR_EXMM_UPDATESTUSTADYSTATUS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_ExmM_upDateStuStadyStatus(InWhereStr VARCHAR2,OutCount out int )
IS 
TYPE stu_course IS REF CURSOR;
sc stu_course;
studentCode varchar2(20);
courseID varchar2(10);
strSql varchar2(3000);
--DECLARE CURSOR result is select StudentCode,CourseID from EAS_ExmM_SignUp ;
BEGIN
    strSql := 'select studentCode,courseID from EAS_ExmM_SignUp where '||InWhereStr;

    open sc for strSql;
    LOOP
    FETCH sc into studentCode,courseID;
    
    EXIT WHEN sc%NOTFOUND; 
    dbms_output.put_line('student='||studentCode);
     --UPDATE EAS_Elc_StudentStudyStatus set SignUpNum = SignUpNum+1 where StudentCode = studentCode and CourseID = courseID;
    END LOOP;
   CLOSE sc;
END PR_ExmM_upDateStuStadyStatus;
/

