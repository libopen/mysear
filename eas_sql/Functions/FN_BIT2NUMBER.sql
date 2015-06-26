--
-- FN_BIT2NUMBER  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.FN_BIT2NUMBER(P_BIN IN VARCHAR2) RETURN NUMBER AS
  V_SQL    VARCHAR2(30000) := 'SELECT BIN_TO_NUM(';
  V_RETURN NUMBER;
BEGIN
  IF LENGTH(P_BIN) >= 256 THEN
    RAISE_APPLICATION_ERROR(-20001, 'INPUT BIN TOO LONG!');
  END IF;
  IF LTRIM(P_BIN, '01') IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'INPUT STR IS NOT VALID BIN VALUE!');
  END IF;
  FOR I IN 1 .. LENGTH(P_BIN) LOOP
    V_SQL := V_SQL || SUBSTR(P_BIN, I, 1) || ',';
  END LOOP;
  V_SQL := RTRIM(V_SQL, ',') || ') FROM DUAL';
  EXECUTE IMMEDIATE V_SQL
    INTO V_RETURN;
  RETURN V_RETURN;
END;
/

