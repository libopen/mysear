--
-- PR_TCP_ENABLE_GUIDANCEENABLED  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Enable_GuidanceEnabled(
    i_TCPCode in EAS_TCP_GUIDANCE.TCPCODE%type,--רҵ����
    i_EnableUser in  EAS_TCP_GUIDANCE.EnableUser%type--���ò�����
) IS
v_tcpCode EAS_TCP_GUIDANCE.TCPCODE%type;--רҵ����
v_batchcode EAS_TCP_GUIDANCE.BATCHCODE %type;--ѧ��
/******************************************************************************
   NAME:       Pr_GuidanceEnabled
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/16   liufengshuan       1. Created this procedure.

   NOTES:ָ����רҵ����--����

******************************************************************************/
BEGIN

--1.����TCPCode��ȡָ���Խ�ѧ�ƻ���ҵ��ʵ��
    SELECT  
      TCPCode,BatchCode into v_tcpCode,v_batchcode FROM EAS_TCP_Guidance WHERE TCPCode = i_TCPCode ;

--2.��ָ����רҵ�����Ƶ�ʵʩ��רҵ�������
    INSERT INTO EAS_TCP_Implementation  
    (   
      SN,BatchCode,OrgCode,TCPCode,MinGradCredits,  
      MinExamCredits,ExemptionMaxCredits,EducationType,  
      StudentType,ProfessionalLevel,SpyCode,SchoolSystem,  
      DegreeCollegeID,DegreeSemester,ImpState,CreateTime  
      --,Implementer,
      --ImpTime  
     )  
     select 
        sys_guid() SN,
        etg.Batchcode,
        esoss.SegmentCode ,  
        etg.TCPCode,
        etg.MinGradCredits,
        etg.MinExamCredits,
        etg.ExemptionMaxCredits,
        etg.EducationType,
        esoss.StudentType ,
        esoss.ProfessionalLevel , 
        esoss.SpyCode , 
        etg.SchoolSystem,
        etg.DegreeCollegeID,  
        etg.DegreeSemester,
        0  ImpState,  
        sysdate CreateTime  
        --,'' Implementer,  
        --sysdate ImpTime
        
     FROM EAS_TCP_Guidance etg
     left join EAS_Spy_OpenSpySegment esoss 
                on esoss.SpyCode = etg.SpyCode AND esoss.StudentType = etg.StudentType  
                AND esoss.ProfessionalLevel = etg.ProfessionalLevel   
     WHERE  esoss.OpenState=1  and etg.TCPCode =  i_TCPCode ;

--3.����ָ����רҵ��������ù���ʵʩ�Խ�ѧ�ƻ�����Ӧ�����ù���
 
   insert into EAS_TCP_ImplOnRule
        (SN,Batchcode,SegmentCode,TCPCode,ModuleTotalCredits,TotalCredits)
     select 
        seq_TCP_ImplOnRule.nextval SN, 
        d.BatchCode, c.SegmentCode,d.TCPCode
        ,(
            select nvl(sum(Credit),0.000) ModuleCredit from EAS_TCP_ModuleCourses
            where CourseNature=1 and Batchcode=v_batchcode and TCPCode=i_TCPCode
        ) ModuleTotalCredits--ģ����ѧ��
        ,(
             select nvl(sum(CenterCompulsoryCourseCredit),0.000) from EAS_TCP_GuidanceOnModuleRule
             where 1=1 and Batchcode=v_batchcode and TCPCode=i_TCPCode
        ) TotalCredits--�ܲ�������ѧ��
    from EAS_TCP_GuidanceOnRule g
    left join EAS_TCP_Guidance d on g.TCPCode=d.TCPCode and g.BatchCode=d.BatchCode 
    left join EAS_Spy_OpenSpySegment c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
    and c.ProfessionalLevel=d.ProfessionalLevel 
    where 1=1
    and c.OpenState='1' and  g.TCPCode=i_TCPCode and g.BatchCode=v_batchcode;
    
--4.����ָ����רҵ���������ģ�����ʵʩ�Խ�ѧ�ƻ�����Ӧ������ģ�����
 
    insert into EAS_TCP_ImplOnModuleRule
    ( SN,BatchCode,SegmentCode,TCPCode,ModuleCode,RequiredTotalCredits,ModuleTotalCredits,SCSegmentTotalCredits,SCCenterTotalCredits)
        select 
            seq_TCP_ImplModuRule.nextVal SN,
            g.BatchCode, c.SegmentCode, g.TCPCode,g.ModuleCode
            ,g.CenterCompulsoryCourseCredit RequiredTotalCredits --�ܲ�������ѧ��
            ,g.CenterCompulsoryCourseCredit+g.SegmentCompulsoryCourseCredit ModuleTotalCredits--ģ����ѧ��
              ,'0.00' SCSegmentTotalCredits,0.00 SCCenterTotalCredits
        from EAS_TCP_GuidanceOnModuleRule g
        left join EAS_TCP_Guidance d on g.TCPCode=d.TCPCode and g.BatchCode=d.BatchCode 
        left join EAS_Spy_OpenSpySegment c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
        and c.ProfessionalLevel=d.ProfessionalLevel
        where 1=1
        and c.OpenState='1' and  g.TCPCode=i_TCPCode and g.BatchCode=v_batchcode;

--5. ָ����רҵ�����״̬Ϊ����

      UPDATE EAS_TCP_Guidance SET  
          State =1,  
          EnableUser =i_EnableUser,  
          EnableTime = sysdate  
      WHERE TCPCode =i_TCPCode;

--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_TCP_Enable_GuidanceEnabled;
/

