--
-- EXISTS2  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.EXISTS2 (IN_SQL IN VARCHAR2)
  RETURN NUMBER
IS
  /**********************************************************
  * ʹ��ʾ��
  * begin
  *   if EXISTS2('select * from dual where 1=1')=1 then
  *     dbms_output.put_line('�м�¼');
  *   else
  *     dbms_output.put_line('�޼�¼');
  *   end if;
  * end;
  *****************************************************************/
  V_SQL VARCHAR2(4000);
  V_CNT NUMBER(1);
BEGIN
  V_SQL := 'SELECT COUNT(*) FROM DUAL WHERE EXISTS (' || IN_SQL || ')';
  EXECUTE IMMEDIATE V_SQL INTO V_CNT;
  RETURN(V_CNT);
END;
/

