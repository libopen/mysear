--
-- PR_TCP_ENABLE_IMPLENABLED  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Enable_ImplEnabled(i_implSN in varchar) 
IS
v_SN varchar(40);
v_ImplBatchCode EAS_TCP_Implementation.BatchCode%type; --����
v_ImplOrgCode EAS_TCP_Implementation.OrgCode%type;--����
v_ImplTCPCode EAS_TCP_Implementation.TCPCode%type;--רҵ�������

RequiredTotalCredits number(7,2);
GuidanceOnModuleRuleCenter number(7,2);
GuidanceOnModuleRuleSegment number(7,2);
SCSegmentTotalCreditssum number(7,2);
SCCenterTotalCreditssum number(7,2);
XuanExecutiveCourse number(7,2);
ImpModuleCourseExamUnitCenter number(7,2);

ExecRuleModultotal number(7,2):=0.00;
ExamUnitCenter number(7,2);
ExecModulRultotal number(7,2);
ModulExamCenter number(7,2);

v_count  number := 0;

/******************************************************************************
    NAME:       ImplementationEnabled 
    NOTES:      ����ʵʩ�Խ�ѧ�ƻ�
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/26   Administrator       1. Created this procedure.
******************************************************************************/
BEGIN
    
    if i_implSN is not null then
        
        v_SN:=i_implSN;
    end if;

   --SN,��ȡʵʩ�Խ�ѧ�ƻ�
     SELECT BatchCode,OrgCode,TCPCode into v_ImplBatchCode,v_ImplOrgCode,v_ImplTCPCode  FROM EAS_TCP_Implementation WHERE SN =v_SN;
  
    
--1. ��ʵʩ��רҵ���������пγ̣��������޿γ̡�רҵ����ģ���¿γ̣����������ڷ�У�γ��ܱ��еĿγ̼��뵽��У�γ��ܱ���

     INSERT INTO EAS_TCP_SegmentCourses  (SN,OrgCode,  CourseID, CourseState,    CreateTime   )  

     SELECT (seq_TCP_SegmCour.nextval) SN, TTOrgCode,TTCourseID, ecbi.State,sysdate CreateTime  
     FROM  
     (  
          SELECT eti.OrgCode TTOrgCode,etmc.CourseID TTCourseID FROM EAS_TCP_ModuleCourses etmc --��ѧ�ƻ�ģ��γ�EAS_TCP_ModuleCourses�б��޿�
          INNER JOIN EAS_TCP_Implementation eti ON eti.TCPCode = etmc.TCPCode and ETMC.BATCHCODE=ETI.BATCHCODE 
                 AND eti.SN=v_SN  
          WHERE  etmc.CourseNature='1'  
          UNION  
            SELECT etimc.SegmentCode AS OrgCode,etimc.CourseID  FROM EAS_TCP_ImplModuleCourse etimc  --ʵʩ�Խ�ѧ��ģ��γ�EAS_TCP_ImpModuleCourse�����п�
          UNION  
            SELECT eti.OrgCode,etcc.CourseID FROM EAS_TCP_ConversionCourse etcc  --���޿γ̱�EAS_TCP_ConversionCourse
            INNER JOIN EAS_TCP_Implementation eti ON eti.TCPCode = etcc.TCPCode and etcc.batchCode=eti.Batchcode 
            AND eti.SN=v_SN
     )TT  
     INNER JOIN EAS_Course_BasicInfo ecbi ON ecbi.CourseID = TT.TTCourseID  
     WHERE  1=1  and rownum<3
      AND NOT EXISTS  
      (  
       SELECT  1  FROM EAS_TCP_SegmentCourses etsc   WHERE   TTCourseID=etsc.CourseID   AND TTOrgCode = etsc.OrgCode 
      ) ;
  
  

--2.������ѧϰ�������õĿ���רҵEAS_Spy_OpenSpyLearningCenter���Զ���ʵʩ��רҵ�����Ƶ�ִ����רҵ������У�����״̬Ϊ��δ���á�

     insert into EAS_TCP_Execution
   select SYS_GUID() SN,
      d.BatchCode,d.orgcode SEGMENTCODE,c.LearningCenterOrgCode,d.TCPCode,d.MinGradCredits,d.MinExamCredits,d.ExemptionMaxCredits,
      d.EducationType,d.StudentType,d.ProfessionalLevel,d.SpyCode,d.SchoolSystem,d.DegreeCollegeID,d.DEGREESEMESTER,0 ExcState,
      sysdate CreateTime,d.implementer executor,sysdate EXECUTETIME
  from EAS_TCP_Implementation d
  left join EAS_Spy_OpenSpyLearningCenter c 
  on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType and c.ProfessionalLevel=d.ProfessionalLevel and d.orgCode=c.segmentorgcode
  where 1=1 and c.OpenState='1'  and d.orgcode=v_ImplOrgCode
  and d.TCPCode=v_ImplTCPCode and d.BatchCode=v_ImplBatchCode ;

--3. ����ָ����רҵ��������ù�������ģ�����ִ���Խ�ѧ�ƻ�����Ӧ�����ù�������ģ�����
--3.0 ѧ�ּ���
/*
 ָ���Խ�ѧ�ƻ����ù��� EAS_TCP_GuidanceOnRule
ʵʩ�Խ�ѧ�ƻ�����ģ����� EAS_TCP_ImplementationOnModuleRule
ʵʩ�Խ�ѧ��ģ��γ� EAS_TCP_ImpModuleCourse
ָ���Խ�ѧ�ƻ�����ģ����� EAS_TCP_GuidanceOnModuleRule
*/
--1.EAS_TCP_GuidanceOnRule
    --���޿���ѧ��
    
    select count(*) into v_count from  EAS_TCP_GuidanceOnRule
    where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode;

    if v_count>0 then
    -- ���޿���ѧ��
    select RequiredTotalCredits into RequiredTotalCredits
    from EAS_TCP_GuidanceOnRule where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode;

    v_count:=0;

    end if;




--2.EAS_TCP_GuidanceOnModuleRule
    --GuidanceOnModuleRuleCenter --�ܲ����޿���ѧ��
    -- GuidanceOnModuleRuleSegment --�ֲ�������ѧ��
    select 
    sum(CenterCompulsoryCourseCredit) ModuleRuleCenter,--�ܲ����޿���ѧ��
    sum(SegmentCompulsoryCourseCredit) ModuleRuleSegment --�ֲ�������ѧ��
    into GuidanceOnModuleRuleCenter , GuidanceOnModuleRuleSegment
    from EAS_TCP_GuidanceOnModuleRule
    where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode;

--3.EAS_TCP_ImplementationOnModuleRule

    select
    sum(SCSegmentTotalCredits) SCSegmentTotalCredits,--�ֲ����޷ֲ�������ѧ��
    sum(SCCenterTotalCredits) SCCenterTotalCredits --�ֲ������ܲ�������ѧ��
    into SCSegmentTotalCreditssum,SCCenterTotalCreditssum
    from EAS_TCP_ImplOnModuleRule where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode  and SEGMENTCODE=v_ImplOrgCode;

--4.EAS_TCP_ImpModuleCourse
    --ѡ������ִ�п�ѧ��
    select 
    nvl(sum(Credit),0.00) ExecutiveCourse into XuanExecutiveCourse --ѡ������ִ�п�ѧ��
    from EAS_TCP_ImplModuleCourse 
    where CourseNature=3 and IsExecutiveCourse=1 
    and tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode and SEGMENTCODE=v_ImplOrgCode;
    
--5.EAS_TCP_ImpModuleCourse
    --ѡ������ִ�п��ҿ��Ե�λ���ܲ�ѧ��
    select 
    nvl(sum(Credit),0.00) CourseExamUnitCenter into ImpModuleCourseExamUnitCenter --ѡ������ִ�п��ҿ��Ե�λ���ܲ�ѧ��
    from EAS_TCP_ImplModuleCourse 
    where CourseNature=3  and IsExecutiveCourse=1 and ExamUnitType=1 
         and tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode  and SEGMENTCODE=v_ImplOrgCode;


--1.ִ���Խ�ѧ�ƻ����ù���.ģ����ѧ�ּ���

select (RequiredTotalCredits+SCSegmentTotalCreditssum+SCCenterTotalCreditssum+XuanExecutiveCourse)  modultotal into  ExecRuleModultotal from dual;

--2.ִ���Խ�ѧ�ƻ����ù���.�ܲ�������ѧ��
select (GuidanceOnModuleRuleCenter+SCCenterTotalCreditssum+ImpModuleCourseExamUnitCenter) ExamUnitCenter into ExamUnitCenter from dual;

--3.ִ���Խ�ѧ�ƻ�ģ�����ù���.ģ����ѧ�ּ���
select (GuidanceOnModuleRuleCenter+GuidanceOnModuleRuleSegment+SCSegmentTotalCreditssum+SCCenterTotalCreditssum+XuanExecutiveCourse) aa into ExecModulRultotal  from dual;

--4.ִ���Խ�ѧ�ƻ�ģ�����ù���.�ܲ�������ѧ��
select (GuidanceOnModuleRuleCenter+SCCenterTotalCreditssum+ImpModuleCourseExamUnitCenter) dd into ModulExamCenter from dual;



--3.1����ָ����רҵ��������ù���ִ���Խ�ѧ�ƻ�����Ӧ�����ù���
 insert into  EAS_TCP_ExecOnRule 
 (
   SN,BATCHCODE,SEGMENTCODE,LEARNINGCENTERCODE,TCPCODE,TOTALCREDITS,MODULETOTALCREDITS
 ) 
 select  (seq_TCP_ExecOnRule.nextval) SN,
    gg.BatchCode, c.SegmentOrgCode,c.LearningCenterOrgCode, gg.TCPCode,
    --,�ܷ�,ģ���ܷ�   
    ExamUnitCenter TOTALCREDITS,
    ExecRuleModultotal MODULETOTALCREDITS
  from EAS_TCP_GuidanceOnRule gg
    left join EAS_TCP_Guidance d on gg.TCPCode=d.TCPCode and gg.BatchCode=d.BatchCode 
    left join EAS_Spy_OpenSpyLearningCenter c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
    and c.ProfessionalLevel=d.ProfessionalLevel and c.SegmentOrgCode=v_ImplOrgCode
  where 1=1 and c.OpenState='1' 
        and  gg.TCPCode=v_ImplTCPCode and gg.BatchCode=v_ImplBatchCode;

--3.2.����ָ����רҵ���������ģ�����ִ���Խ�ѧ�ƻ�����Ӧ������ģ�����
  insert into  EAS_TCP_ExecOnModuleRule
    (
      SN,BATCHCODE,SEGMENTCODE,LEARNINGCENTERCODE,TCPCODE,MODULECODE,REQUIREDTOTALCREDITS,MODULETOTALCREDITS
    )
  select (seq_TCP_execOnModuRule.nextval) SN,
    g.BatchCode, c.SegmentOrgCode,c.LearningCenterOrgCode, g.TCPCode,g.ModuleCode
    --,RequiredTotalCredits,ModuleTotalCredits --�ܷ�,ģ���ܷ�    
    ,ModulExamCenter REQUIREDTOTALCREDITS,ExecModulRultotal MODULETOTALCREDITS
  from EAS_TCP_GuidanceOnModuleRule g
    left join EAS_TCP_Guidance d on g.TCPCode=d.TCPCode and g.BatchCode=d.BatchCode 
    left join EAS_Spy_OpenSpyLearningCenter c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
    and c.ProfessionalLevel=d.ProfessionalLevel and c.SegmentOrgCode=v_ImplOrgCode
  where 1=1 and c.OpenState='1' 
        and  g.TCPCode=v_ImplTCPCode and g.BatchCode=v_ImplBatchCode;


--4.EAS_TCP_Implementation �޸�״̬
  UPDATE EAS_TCP_Implementation SET  
  ImpState = 1,  
  ImpTime = sysdate  
 WHERE SN = v_SN;  

END Pr_TCP_Enable_ImplEnabled;
/

