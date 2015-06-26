--
-- PK_EXMM  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_ExmM AS
    



procedure pr_exmm_Getdblink(retcode out varchar2)
is
begin
 retcode:='abc';
end pr_exmm_getdblink;


procedure pr_exmm_batchaddnetscore(arr_Students in dbms_utility.lname_array ,arr_Courses in DBMS_UTILITY.LNAME_ARRAY ,arr_Score in DBMS_UTILITY.LNAME_ARRAY ,numTime out number)
IS
v_start number;
v_end   number;
BEGIN
 v_start := dbms_utility.get_time;
 for i in 1..arr_Students.count loop
  insert into TMP_EXMM_NETEXAMSCORE(SN,STUDENTCODE,courseid,score) values(1,arr_Students(i),arr_Courses(i),to_number(arr_Score(i),'99999.99'));
 end loop;
  v_end := dbms_utility.get_time;
  numTime :=(v_end-v_start);
end pr_exmm_batchaddnetscore;

procedure pr_exmm_batchaddnetscore2(arr_Students in LIST50_VARCHAR ,arr_Courses in LIST50_VARCHAR ,arr_Score in LIST50_VARCHAR ,numTime out number)
IS
v_start number;
v_end   number;
BEGIN
 v_start := dbms_utility.get_time;
 forall i in arr_Students.First..arr_Students.Last
   insert into TMP_EXMM_NETEXAMSCORE(SN,STUDENTCODE,courseid,score) values(1,arr_Students(i),arr_Courses(i),to_number(arr_Score(i),'99999.99'));
 
  v_end := dbms_utility.get_time;
  numTime :=(v_end-v_start);
end pr_exmm_batchaddnetscore2;

end PK_ExmM;
/

