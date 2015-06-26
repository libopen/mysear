--
-- PR_TCP_ENABLE_IMPLENABLED  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Enable_ImplEnabled(i_implSN in varchar) 
IS
v_SN varchar(40);
v_ImplBatchCode EAS_TCP_Implementation.BatchCode%type; --批次
v_ImplOrgCode EAS_TCP_Implementation.OrgCode%type;--机构
v_ImplTCPCode EAS_TCP_Implementation.TCPCode%type;--专业规则编码

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
    NOTES:      启用实施性教学计划
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

   --SN,获取实施性教学计划
     SELECT BatchCode,OrgCode,TCPCode into v_ImplBatchCode,v_ImplOrgCode,v_ImplTCPCode  FROM EAS_TCP_Implementation WHERE SN =v_SN;
  
    
--1. 将实施性专业规则中所有课程（包括补修课程、专业规则模块下课程）、不存在于分校课程总表中的课程加入到分校课程总表中

     INSERT INTO EAS_TCP_SegmentCourses  (SN,OrgCode,  CourseID, CourseState,    CreateTime   )  

     SELECT (seq_TCP_SegmCour.nextval) SN, TTOrgCode,TTCourseID, ecbi.State,sysdate CreateTime  
     FROM  
     (  
          SELECT eti.OrgCode TTOrgCode,etmc.CourseID TTCourseID FROM EAS_TCP_ModuleCourses etmc --教学计划模块课程EAS_TCP_ModuleCourses中必修课
          INNER JOIN EAS_TCP_Implementation eti ON eti.TCPCode = etmc.TCPCode and ETMC.BATCHCODE=ETI.BATCHCODE 
                 AND eti.SN=v_SN  
          WHERE  etmc.CourseNature='1'  
          UNION  
            SELECT etimc.SegmentCode AS OrgCode,etimc.CourseID  FROM EAS_TCP_ImplModuleCourse etimc  --实施性教学计模块课程EAS_TCP_ImpModuleCourse中所有课
          UNION  
            SELECT eti.OrgCode,etcc.CourseID FROM EAS_TCP_ConversionCourse etcc  --补修课程表EAS_TCP_ConversionCourse
            INNER JOIN EAS_TCP_Implementation eti ON eti.TCPCode = etcc.TCPCode and etcc.batchCode=eti.Batchcode 
            AND eti.SN=v_SN
     )TT  
     INNER JOIN EAS_Course_BasicInfo ecbi ON ecbi.CourseID = TT.TTCourseID  
     WHERE  1=1  and rownum<3
      AND NOT EXISTS  
      (  
       SELECT  1  FROM EAS_TCP_SegmentCourses etsc   WHERE   TTCourseID=etsc.CourseID   AND TTOrgCode = etsc.OrgCode 
      ) ;
  
  

--2.各下属学习中心启用的开设专业EAS_Spy_OpenSpyLearningCenter，自动将实施性专业规则复制到执行性专业规则表中，启用状态为“未启用”

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

--3. 复制指导性专业规则的启用规则及启用模块规则到执行性教学计划中相应的启用规则及启用模块规则
--3.0 学分计算
/*
 指导性教学计划启用规则 EAS_TCP_GuidanceOnRule
实施性教学计划启用模块规则 EAS_TCP_ImplementationOnModuleRule
实施性教学计模块课程 EAS_TCP_ImpModuleCourse
指导性教学计划启用模块规则 EAS_TCP_GuidanceOnModuleRule
*/
--1.EAS_TCP_GuidanceOnRule
    --必修课总学分
    
    select count(*) into v_count from  EAS_TCP_GuidanceOnRule
    where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode;

    if v_count>0 then
    -- 必修课总学分
    select RequiredTotalCredits into RequiredTotalCredits
    from EAS_TCP_GuidanceOnRule where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode;

    v_count:=0;

    end if;




--2.EAS_TCP_GuidanceOnModuleRule
    --GuidanceOnModuleRuleCenter --总部必修课总学分
    -- GuidanceOnModuleRuleSegment --分部必修总学分
    select 
    sum(CenterCompulsoryCourseCredit) ModuleRuleCenter,--总部必修课总学分
    sum(SegmentCompulsoryCourseCredit) ModuleRuleSegment --分部必修总学分
    into GuidanceOnModuleRuleCenter , GuidanceOnModuleRuleSegment
    from EAS_TCP_GuidanceOnModuleRule
    where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode;

--3.EAS_TCP_ImplementationOnModuleRule

    select
    sum(SCSegmentTotalCredits) SCSegmentTotalCredits,--分部必修分部考试总学分
    sum(SCCenterTotalCredits) SCCenterTotalCredits --分部必修总部考试总学分
    into SCSegmentTotalCreditssum,SCCenterTotalCreditssum
    from EAS_TCP_ImplOnModuleRule where tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode  and SEGMENTCODE=v_ImplOrgCode;

--4.EAS_TCP_ImpModuleCourse
    --选修且是执行课学分
    select 
    nvl(sum(Credit),0.00) ExecutiveCourse into XuanExecutiveCourse --选修且是执行课学分
    from EAS_TCP_ImplModuleCourse 
    where CourseNature=3 and IsExecutiveCourse=1 
    and tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode and SEGMENTCODE=v_ImplOrgCode;
    
--5.EAS_TCP_ImpModuleCourse
    --选修且是执行课且考试单位是总部学分
    select 
    nvl(sum(Credit),0.00) CourseExamUnitCenter into ImpModuleCourseExamUnitCenter --选修且是执行课且考试单位是总部学分
    from EAS_TCP_ImplModuleCourse 
    where CourseNature=3  and IsExecutiveCourse=1 and ExamUnitType=1 
         and tcpcode=v_ImplTCPCode and BatchCode=v_ImplBatchCode  and SEGMENTCODE=v_ImplOrgCode;


--1.执行性教学计划启用规则.模块总学分计算

select (RequiredTotalCredits+SCSegmentTotalCreditssum+SCCenterTotalCreditssum+XuanExecutiveCourse)  modultotal into  ExecRuleModultotal from dual;

--2.执行性教学计划启用规则.总部考试总学分
select (GuidanceOnModuleRuleCenter+SCCenterTotalCreditssum+ImpModuleCourseExamUnitCenter) ExamUnitCenter into ExamUnitCenter from dual;

--3.执行性教学计划模块启用规则.模块总学分计算
select (GuidanceOnModuleRuleCenter+GuidanceOnModuleRuleSegment+SCSegmentTotalCreditssum+SCCenterTotalCreditssum+XuanExecutiveCourse) aa into ExecModulRultotal  from dual;

--4.执行性教学计划模块启用规则.总部考试总学分
select (GuidanceOnModuleRuleCenter+SCCenterTotalCreditssum+ImpModuleCourseExamUnitCenter) dd into ModulExamCenter from dual;



--3.1复制指导性专业规则的启用规则到执行性教学计划中相应的启用规则
 insert into  EAS_TCP_ExecOnRule 
 (
   SN,BATCHCODE,SEGMENTCODE,LEARNINGCENTERCODE,TCPCODE,TOTALCREDITS,MODULETOTALCREDITS
 ) 
 select  (seq_TCP_ExecOnRule.nextval) SN,
    gg.BatchCode, c.SegmentOrgCode,c.LearningCenterOrgCode, gg.TCPCode,
    --,总分,模板总分   
    ExamUnitCenter TOTALCREDITS,
    ExecRuleModultotal MODULETOTALCREDITS
  from EAS_TCP_GuidanceOnRule gg
    left join EAS_TCP_Guidance d on gg.TCPCode=d.TCPCode and gg.BatchCode=d.BatchCode 
    left join EAS_Spy_OpenSpyLearningCenter c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
    and c.ProfessionalLevel=d.ProfessionalLevel and c.SegmentOrgCode=v_ImplOrgCode
  where 1=1 and c.OpenState='1' 
        and  gg.TCPCode=v_ImplTCPCode and gg.BatchCode=v_ImplBatchCode;

--3.2.复制指导性专业规则的启用模块规则到执行性教学计划中相应的启用模块规则
  insert into  EAS_TCP_ExecOnModuleRule
    (
      SN,BATCHCODE,SEGMENTCODE,LEARNINGCENTERCODE,TCPCODE,MODULECODE,REQUIREDTOTALCREDITS,MODULETOTALCREDITS
    )
  select (seq_TCP_execOnModuRule.nextval) SN,
    g.BatchCode, c.SegmentOrgCode,c.LearningCenterOrgCode, g.TCPCode,g.ModuleCode
    --,RequiredTotalCredits,ModuleTotalCredits --总分,模板总分    
    ,ModulExamCenter REQUIREDTOTALCREDITS,ExecModulRultotal MODULETOTALCREDITS
  from EAS_TCP_GuidanceOnModuleRule g
    left join EAS_TCP_Guidance d on g.TCPCode=d.TCPCode and g.BatchCode=d.BatchCode 
    left join EAS_Spy_OpenSpyLearningCenter c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
    and c.ProfessionalLevel=d.ProfessionalLevel and c.SegmentOrgCode=v_ImplOrgCode
  where 1=1 and c.OpenState='1' 
        and  g.TCPCode=v_ImplTCPCode and g.BatchCode=v_ImplBatchCode;


--4.EAS_TCP_Implementation 修改状态
  UPDATE EAS_TCP_Implementation SET  
  ImpState = 1,  
  ImpTime = sysdate  
 WHERE SN = v_SN;  

END Pr_TCP_Enable_ImplEnabled;
/

