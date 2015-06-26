--
-- PR_TCP_EXT_IMPLEXTENDCOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Ext_ImplExtendCourse(
i_implSN in varchar
)
 IS
 
v_sn varchar(40):=i_implSN;
v_ImplBatchCode EAS_TCP_Implementation.BatchCode%type; --����
v_ImplOrgCode EAS_TCP_Implementation.OrgCode%type;--����
v_ImplTCPCode EAS_TCP_Implementation.TCPCode%type;--רҵ�������
v_implSpyCode EAS_TCP_Implementation.SPYCODE%type;--רҵ����
v_prevBatchCode EAS_TCP_RECRUITBATCH.BatchCode%type;--��һ���ѧ�� 
v_moduletotalcredits EAS_TCP_IMPLONRULE.MODULETOTALCREDITS%type;--ģ����ѧ��
v_centerTotalCredits EAS_TCP_IMPLONRULE.TOTALCREDITS%type;--�ܲ��γ�ѧ��


/******************************************************************************
   NAME:       Pr_ImplementationExtendedCours
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/9   Administrator       1. Created this procedure.

   NOTES:ʵʩ��רҵ����--���ÿγ�

******************************************************************************/
BEGIN
   
   --SN,��ȡʵʩ�Խ�ѧ�ƻ�
     SELECT BatchCode,OrgCode,TCPCode,SpyCode 
     into v_ImplBatchCode,v_ImplOrgCode,v_ImplTCPCode,v_implSpyCode  --Ϊ������ֵ
     FROM EAS_TCP_Implementation 
     --v_sn
     WHERE SN =v_sn;

    --��ȡ��һ���ѧ��
    select BatchCode into v_prevBatchCode from EAS_TCP_RECRUITBATCH Batch
    where Batch.BATCHCODE<(
    SELECT BatchCode FROM EAS_TCP_Implementation WHERE SN =v_sn--v_sn;
    ) and rownum<=1
    order by Batch.BATCHCODE desc;

--�γ�
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
    and eti.batchcode= v_prevBatchCode --'200703'-- v_prevBatchCode ��һ���ѧ��
    --( select ba.BatchCode from EAS_TCP_RECRUITBATCH Ba where Ba.BATCHCODE<'200709' and rownum<=1 order by BATCHCODE desc) 
    --�Ǳ��޿γ̼���ѧλ�γ�
    and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
    --�ҿγ̴����������ѧ��ָ����רҵ������
    and exists(
    select etg.batchcode,etg.tcpcode,etg.spycode,etmc.courseID from EAS_TCP_Guidance etg
    left join EAS_TCP_ModuleCourses etmc on etg.tcpcode=etmc.tcpcode and etg.BatchCode=etmc.BatchCode
    where etg.batchcode=v_ImplBatchCode--v_ImplBatchCode'200709'  �����ѧ��
    );
    
    
--רҵ�������_ʵʩ�Խ�ѧ�ƻ����ù���EAS_TCP_ImplementationOnRule ѧ��seq_TCP_ImplOnRule.nextval
    --��ȡ�����γ̵�ģ����ѧ�ֺ��ܲ�������ѧ��
    select
    sum(etimc.credit) moduletotalcredits,--ģ����ѧ��
    (case etimc.ExamUnitType when '1' then sum(etimc.credit)end) centerTotalCredits--�ܲ��γ���ѧ��
    into v_moduletotalcredits,v_centerTotalCredits
    from EAS_TCP_Implementation eti
    left join EAS_TCP_ImplModuleCourse etimc 
    on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode

    where 1=1
    and eti.spycode=v_implSpyCode--'11030100'
    and eti.batchcode=v_prevBatchCode-- v_prevBatchCode'200703' ��һ���ѧ��
    --�Ǳ��޿γ̼���ѧλ�γ�
    and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
    --�ҿγ̴����������ѧ��ָ����רҵ������
    and exists(
    select etg.batchcode,etg.tcpcode,etg.spycode,etmc.courseID from EAS_TCP_Guidance etg
    left join EAS_TCP_ModuleCourses etmc on etg.tcpcode=etmc.tcpcode and etg.BatchCode=etmc.BatchCode
    where etg.batchcode=v_ImplBatchCode --v_ImplBatchCode '200709' �����ѧ��
    )group by etimc.ExamUnitType    ;

 --����ʵʩ��רҵ�������ù���ģ����ѧ�ֺ��ܲ�������ѧ��
    update EAS_TCP_ImplOnRule set  MODULETOTALCREDITS=MODULETOTALCREDITS+v_moduletotalcredits,TOTALCREDITS=TOTALCREDITS+ v_centerTotalCredits
    where TCPCode=v_ImplTCPCode--'070901411030100' '120'
     and SegmentCode=v_ImplOrgCode;

--���� ʵʩ�Խ�ѧ�ƻ�����ģ�����EAS_TCP_ImplementationOnModuleRule
    update EAS_TCP_ImplOnModuleRule a
    set(
        RequiredTotalCredits,
        ModuleTotalCredits,
        SCSegmentTotalCredits,
        SCCenterTotalCredits
    )=(

        select 
            a.ModuleTotalCredits modu,--ģ����ѧ��
            a.RequiredTotalCredits+TotalCredits,--�ܲ�������ѧ��
            a.SCCenterTotalCredits+ SCCenterTotalCredits,--�ֲ������ܲ�������ѧ��
            a.SCSegmentTotalCredits+SCSegmentTotalCredits--�ֲ����޷ֲ�������ѧ��
        from(        
                select
                    etimc.tcpcode,
                    eti.OrgCode,
                    etimc.ModuleCode,
                    sum(etimc.credit) modu,--ģ����ѧ��
                    (case etimc.ExamUnitType when '1' then sum(etimc.credit)end) TotalCredits,--�ܲ�������ѧ��
                    (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='1') then sum(etimc.credit)end) SCCenterTotalCredits,--�ֲ������ܲ�������ѧ��
                    (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='2') then sum(etimc.credit)end) SCSegmentTotalCredits--�ֲ����޷ֲ�������ѧ��

                 from EAS_TCP_Implementation eti
                left join EAS_TCP_ImplModuleCourse etimc 
                on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode

                where eti.spycode=v_implSpyCode and eti.batchcode =v_prevBatchCode
                --�Ǳ��޿γ̼���ѧλ�γ�
                and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
                --�ҿγ̴����������ѧ��ָ����רҵ������
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
                            sum(etimc.credit) modu,--ģ����ѧ��
                            (case etimc.ExamUnitType when '1' then sum(etimc.credit)end) TotalCredits,--�ܲ�������ѧ��
                            (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='1') then sum(etimc.credit)end) SCCenterTotalCredits,--�ֲ������ܲ�������ѧ��
                            (case  when (etimc.CourseNature='2' and etimc.ExamUnitType='2') then sum(etimc.credit)end) SCSegmentTotalCredits--�ֲ����޷ֲ�������ѧ��

                         from EAS_TCP_Implementation eti
                        left join EAS_TCP_ImplModuleCourse etimc 
                        on eti.tcpcode=etimc.tcpcode and eti.orgcode=etimc.SegmentCode and eti.BatchCode=etimc.BatchCode
                        --where eti.spycode='09010206' and eti.batchcode ='200703'
                        where eti.spycode=v_implSpyCode and eti.batchcode =v_prevBatchCode 
                        --�Ǳ��޿γ̼���ѧλ�γ�
                        and etimc.CourseNature!=1 and etimc.IsDegreeCourse=0 
                        --�ҿγ̴����������ѧ��ָ����רҵ������
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

