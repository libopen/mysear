--
-- PR_TCP_EXT_IMPLEXTENDCOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Ext_ImplExtendCourse(
i_implSN in varchar
)
 IS
 
v_sn varchar(40):=i_implSN;
v_ImplBatchCode EAS_TCP_Implementation.BatchCode%type; --批次
v_ImplOrgCode EAS_TCP_Implementation.OrgCode%type;--机构
v_ImplTCPCode EAS_TCP_Implementation.TCPCode%type;--专业规则编码
v_implSpyCode EAS_TCP_Implementation.SPYCODE%type;--专业编码
v_prevBatchCode EAS_TCP_RECRUITBATCH.BatchCode%type;--上一年度学期 
v_moduletotalcredits EAS_TCP_IMPLONRULE.MODULETOTALCREDITS%type;--模块总学分
v_centerTotalCredits EAS_TCP_IMPLONRULE.TOTALCREDITS%type;--总部课程学分


/******************************************************************************
   NAME:       Pr_ImplementationExtendedCours
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/9   Administrator       1. Created this procedure.

   NOTES:实施性专业规则--延用课程

******************************************************************************/
BEGIN
   
   --SN,获取实施性教学计划
     SELECT BatchCode,OrgCode,TCPCode,SpyCode 
     into v_ImplBatchCode,v_ImplOrgCode,v_ImplTCPCode,v_implSpyCode  --为变量赋值
     FROM EAS_TCP_Implementation 
     --v_sn
     WHERE SN =v_sn;

    --获取上一年度学期
    select BatchCode into v_prevBatchCode from EAS_TCP_RECRUITBATCH Batch
    where Batch.BATCHCODE<(
    SELECT BatchCode FROM EAS_TCP_Implementation WHERE SN =v_sn--v_sn;
    ) and rownum<=1
    order by Batch.BATCHCODE desc;

--课程
    insert into EAS_TCP_ImplModuleCourse
    select
    sys_guid() SN,
    v_ImplBatchCode BatchCode,
   --'200709' BatchCode,
    eti.TCPCode,
    eti.OrgCode SegmentCode,
    etimc.ModuleCode,
    etimc.CourseID,
    etimc.CourseNature,
    etimc.ModifiedCourseNature,
    etimc.ExamUnitType,
    etimc.ModifiedExamUnitType,
    etimc.Credit,
    etimc.Hour,
    etimc.IsDegreeCourse,
    etimc.IsExecutiveCourse,
    etimc.IsExtendedCourse,
    etimc.ISSIMILARI,
    etimc.ExtendedSource,
    sysdate CreateTime
    
    from EAS_TCP_Implementation eti
    left join EAS_TCP_ImplModuleCourse etimc 
    on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode

    where 1=1
    and eti.spycode=v_implSpyCode--'11030100'--v_implSpyCode
    and eti.batchcode= v_prevBatchCode --'200703'-- v_prevBatchCode 上一年度学期
    --( select ba.BatchCode from EAS_TCP_RECRUITBATCH Ba where Ba.BATCHCODE<'200709' and rownum<=1 order by BATCHCODE desc) 
    --非必修课程及非学位课程
    and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
    --且课程存在于新年度学期指导性专业规则中
    and exists(
    select etg.batchcode,etg.tcpcode,etg.spycode,etmc.courseID from EAS_TCP_Guidance etg
    left join EAS_TCP_ModuleCourses etmc on etg.tcpcode=etmc.tcpcode and etg.BatchCode=etmc.BatchCode
    where etg.batchcode=v_ImplBatchCode--v_ImplBatchCode'200709'  新年度学期
    );
    
    
--专业规则管理_实施性教学计划启用规则EAS_TCP_ImplementationOnRule 学分seq_TCP_ImplOnRule.nextval
    --获取新增课程的模块总学分和总部考试总学分
    select
    sum(etimc.credit) moduletotalcredits,--模块总学分
    (case etimc.ExamUnitType when '1' then sum(etimc.credit)end) centerTotalCredits--总部课程总学分
    into v_moduletotalcredits,v_centerTotalCredits
    from EAS_TCP_Implementation eti
    left join EAS_TCP_ImplModuleCourse etimc 
    on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode

    where 1=1
    and eti.spycode=v_implSpyCode--'11030100'
    and eti.batchcode=v_prevBatchCode-- v_prevBatchCode'200703' 上一年度学期
    --非必修课程及非学位课程
    and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
    --且课程存在于新年度学期指导性专业规则中
    and exists(
    select etg.batchcode,etg.tcpcode,etg.spycode,etmc.courseID from EAS_TCP_Guidance etg
    left join EAS_TCP_ModuleCourses etmc on etg.tcpcode=etmc.tcpcode and etg.BatchCode=etmc.BatchCode
    where etg.batchcode=v_ImplBatchCode --v_ImplBatchCode '200709' 新年度学期
    )group by etimc.ExamUnitType    ;

 --更新实施性专业规则启用规则：模块总学分和总部考试总学分
    update EAS_TCP_ImplOnRule set  MODULETOTALCREDITS=MODULETOTALCREDITS+v_moduletotalcredits,TOTALCREDITS=TOTALCREDITS+ v_centerTotalCredits
    where TCPCode=v_ImplTCPCode--'070901411030100' '120'
     and SegmentCode=v_ImplOrgCode;

--更新 实施性教学计划启用模块规则EAS_TCP_ImplementationOnModuleRule
    update EAS_TCP_ImplOnModuleRule a
    set(
        RequiredTotalCredits,
        ModuleTotalCredits,
        SCSegmentTotalCredits,
        SCCenterTotalCredits
    )=(

        select 
            a.ModuleTotalCredits modu,--模块总学分
            a.RequiredTotalCredits+TotalCredits,--总部考试总学分
            a.SCCenterTotalCredits+ SCCenterTotalCredits,--分部必修总部考试总学分
            a.SCSegmentTotalCredits+SCSegmentTotalCredits--分部必修分部考试总学分
        from(        
                select
                    etimc.tcpcode,
                    eti.OrgCode,
                    etimc.ModuleCode,
                    sum(etimc.credit) modu,--模块总学分
                    (case etimc.ExamUnitType when '1' then sum(etimc.credit)end) TotalCredits,--总部考试总学分
                    (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='1') then sum(etimc.credit)end) SCCenterTotalCredits,--分部必修总部考试总学分
                    (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='2') then sum(etimc.credit)end) SCSegmentTotalCredits--分部必修分部考试总学分

                 from EAS_TCP_Implementation eti
                left join EAS_TCP_ImplModuleCourse etimc 
                on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode

                where eti.spycode=v_implSpyCode and eti.batchcode =v_prevBatchCode
                --非必修课程及非学位课程
                and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
                --且课程存在于新年度学期指导性专业规则中
                and exists(
                select etg.batchcode,etg.tcpcode,etg.spycode,etmc.courseID from EAS_TCP_Guidance etg
                left join EAS_TCP_ModuleCourses etmc on etg.tcpcode=etmc.tcpcode and etg.BatchCode=etmc.BatchCode
                where etg.batchcode=v_ImplBatchCode--'200709'
                )
                group by etimc.ModuleCode,etimc.ExamUnitType,etimc.CourseNature,etimc.tcpcode,eti.OrgCode
        )b
        where  a.tcpcode=b.tcpcode  and  a.SEGMENTCODE=b.OrgCode   and a.ModuleCode=b.ModuleCode
         and exists(
                select 1
                from(        
                        select
                            etimc.tcpcode,
                            eti.OrgCode,
                            etimc.ModuleCode,
                            sum(etimc.credit) modu,--模块总学分
                            (case etimc.ExamUnitType when '1' then sum(etimc.credit)end) TotalCredits,--总部考试总学分
                            (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='1') then sum(etimc.credit)end) SCCenterTotalCredits,--分部必修总部考试总学分
                            (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='2') then sum(etimc.credit)end) SCSegmentTotalCredits--分部必修分部考试总学分

                         from EAS_TCP_Implementation eti
                        left join EAS_TCP_ImplModuleCourse etimc 
                        on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode
                        --where eti.spycode='09010206' and eti.batchcode ='200703'
                        where eti.spycode=v_implSpyCode and eti.batchcode =v_prevBatchCode 
                        --非必修课程及非学位课程
                        and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
                        --且课程存在于新年度学期指导性专业规则中
                        and exists(
                        select etg.batchcode,etg.tcpcode,etg.spycode,etmc.courseID from EAS_TCP_Guidance etg
                        left join EAS_TCP_ModuleCourses etmc on etg.tcpcode=etmc.tcpcode and etg.BatchCode=etmc.BatchCode
                        where etg.batchcode=v_ImplBatchCode --'200709'
                        )
                        group by etimc.ModuleCode,etimc.ExamUnitType,etimc.CourseNature,etimc.tcpcode,eti.OrgCode
                )b
                where  a.tcpcode=b.tcpcode  and  a.SEGMENTCODE=b.OrgCode   and a.ModuleCode=b.ModuleCode
        )
 );



--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_TCP_Ext_ImplExtendCourse;
/

