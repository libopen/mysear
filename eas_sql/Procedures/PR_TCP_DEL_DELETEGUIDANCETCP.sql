--
-- PR_TCP_DEL_DELETEGUIDANCETCP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Del_DeleteGuidanceTCP
(
  i_TCPCode in EAS_TCP_GUIDANCE.TCPCODE%type--专业规则
)
 IS
v_count NUMBER:=0;
/******************************************************************************
   NAME:       Pr_GuidanceDeleteTCP
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/17   Administrator       1. Created this procedure.

   NOTES:--指导性专业规则---删除专业规则

******************************************************************************/
BEGIN


    --1.获取专业规则 停用状态的数量
    SELECT     count(*) into v_count FROM EAS_TCP_Guidance WHERE state=0 and  TCPCode = i_TCPCode;

    if v_count>0 then 


        --2. 删除（指定规则）补修课
         DELETE FROM EAS_TCP_ConversionCourse WHERE TCPCode =i_TCPCode;
         
        --3. 删除似课（指定规则）
        DELETE FROM EAS_TCP_SimilarCourses WHERE TCPCode =i_TCPCode;

        --4. 删除模块课程（指定规则）
        DELETE FROM EAS_TCP_ModuleCourses WHERE TCPCode =i_TCPCode;

        --5. 删除教学计划模块（指定规则）
         DELETE FROM EAS_TCP_Module WHERE TCPCode =i_TCPCode;
         
        --6.删除启用模块规则（指定规则）
          DELETE FROM EAS_TCP_GuidanceOnModuleRule WHERE TCPCode =i_TCPCode;
         --7. 删除启用规则（指定规则）
          DELETE FROM EAS_TCP_GuidanceOnRule WHERE TCPCode =i_TCPCode;

        --8.删除指导性专业规则（指定规则）
         DELETE FROM EAS_TCP_Guidance WHERE TCPCode =i_TCPCode;

    end if;
    
--   tmpVar := 0;
--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_TCP_Del_DeleteGuidanceTCP;
/

