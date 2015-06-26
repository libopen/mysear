--
-- UPDATEGRADAUDITCONDITIONPASS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.UpdateGradAuditConditionPass(
isGradPass int,
isDegreePass int,
inStudentCode varchar2
) IS

    x_IsDegree int;--ÊÇ·ñÉêÇëÑ§Î»
    x_Result int;
BEGIN
    x_Result := 1;
    select isDegree into x_IsDegree from EAS_Grad_Audit where studentCode = inStudentCode;
    if x_IsDegree >0 then
        if isGradPass =0 then
            x_Result := 0;
        elsif isDegreePass = 0 then
            x_Result := 0;
        end if;
    else
      if isGradPass = 0 then
        x_Result :=0;
      end if;
    end if;
    
    update EAS_Grad_Audit set IsConditionPass = x_Result where studentCode = inStudentCode;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END UpdateGradAuditConditionPass;
/

