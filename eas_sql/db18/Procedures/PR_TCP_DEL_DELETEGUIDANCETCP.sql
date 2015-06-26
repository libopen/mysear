--
-- PR_TCP_DEL_DELETEGUIDANCETCP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Del_DeleteGuidanceTCP
(
  i_TCPCode in EAS_TCP_GUIDANCE.TCPCODE%type--רҵ����
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

   NOTES:--ָ����רҵ����---ɾ��רҵ����

******************************************************************************/
BEGIN


    --1.��ȡרҵ���� ͣ��״̬������
    SELECT     count(*) into v_count FROM EAS_TCP_Guidance WHERE state=0 and  TCPCode = i_TCPCode;

    if v_count>0 then 


        --2. ɾ����ָ�����򣩲��޿�
         DELETE FROM EAS_TCP_ConversionCourse WHERE TCPCode =i_TCPCode;
         
        --3. ɾ���ƿΣ�ָ������
        DELETE FROM EAS_TCP_SimilarCourses WHERE TCPCode =i_TCPCode;

        --4. ɾ��ģ��γ̣�ָ������
        DELETE FROM EAS_TCP_ModuleCourses WHERE TCPCode =i_TCPCode;

        --5. ɾ����ѧ�ƻ�ģ�飨ָ������
         DELETE FROM EAS_TCP_Module WHERE TCPCode =i_TCPCode;
         
        --6.ɾ������ģ�����ָ������
          DELETE FROM EAS_TCP_GuidanceOnModuleRule WHERE TCPCode =i_TCPCode;
         --7. ɾ�����ù���ָ������
          DELETE FROM EAS_TCP_GuidanceOnRule WHERE TCPCode =i_TCPCode;

        --8.ɾ��ָ����רҵ����ָ������
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

