--
-- SPLITSTR  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.splitstr(p_string in varchar2,p_delimiter in varchar2) RETURN str_split PIPELINED
IS
v_length NUMBER := LENGTH(p_string);
v_start  NUMBER := 1;
v_index  NUMBER;
/******************************************************************************
   NAME:       splitstr
   PURPOSE:    ²ð·Ö×Ö·û´®

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/03   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     splitstr
      Sysdate:         2014/06/03
      Date and Time:   2014/06/03, 14:20:43, and 2014/06/03 14:20:43
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   
 WHILE(v_start <= v_length)
    LOOP
        v_index := INSTR(p_string, p_delimiter, v_start);

        IF v_index = 0
        THEN
            PIPE ROW(SUBSTR(p_string, v_start));
            v_start := v_length + 1;
        ELSE
            PIPE ROW(SUBSTR(p_string, v_start, v_index - v_start));
            v_start := v_index + 1;
        END IF;
    END LOOP;

    RETURN;

END splitstr;
/

