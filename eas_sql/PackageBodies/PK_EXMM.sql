--
-- PK_EXMM  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_EXMM AS
/******************************************************************************
   NAME:       PK_EXMM
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-10-23      libin       1. Created this package body.
******************************************************************************/
  -- �Զ�������׷�Ӽƻ������γ�
  
 PROCEDURE PR_EXMM_BATCHADDEXAMCOURSEPLAN(i_MAINTAINER IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_OperateType IN number,RETCODE OUT varchar2) IS
    
     v_iExamPlanSN EAS_EXMM_DEFINITION.sn %type :=i_EXAMPLANSN ;
     v_iExamCategorySN EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYTSN;
     v_iSegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
     v_iOperater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_MAINTAINER;  --������  
     v_iOperateType number := i_OperateType; -- 1.���� ��Ҫִ����ղ����� 2 ׷�� ֻ�����µ�
----------------�ƻ����� 
 
      v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������
      v_ExamPlan ExamPlan :=Examplan(v_iExamPlanSN,v_iSegmentCode,v_iExamCategorySN);   ----���Լƻ�����
 BEGIN
   ----�жϿ��Զ����Ƿ��Ѿ����� -----
  
      -- if v_ExamPlan.IsApply=1 then
      --  v_Continue := 'A';
      -- dbms_output.put_line('��������Ѿ��·�,�����Զ�����'); 
       --goto IsContinue;
    -- end if;
    
    if v_iOperateType = 1 then
      ----��ǰ����Ϊ������ͨ������ɾ����ɶ��ӱ��ɾ��--
      delete from EAS_ExmM_ExamCoursePlan where SegmentCode=v_iSegmentCode and  ExamPlanCode=v_ExamPlan.plancode and  ExamCategoryCode= v_ExamPlan.CateGoryCode ;
      dbms_output.put_line('���� ����ǰɾ���ܼ�¼��' ||  SQL%ROWCOUNT); 
    end if;
    
    -----��ʼ���������
   
    
     <<IsContinue>> 
     if v_Continue='OK' then 
     ---- ��ʼ����
       insert into EAS_ExmM_ExamCoursePlan(sn
                ,StudentCategory
                ,segmentcode,examplancode,examcategorycode,tcpcode,spycode,semester
                ,batchcode,modulecode,courseid,coursetype,coursenature,credit,examunit,ismutex,isconversion,ExamCourse_SN
                ,departmentcode
                ,iscomputerexam
                ,isintcp 
                ,maintainer,maintaindate)
       with examcourse as (select v_ExamPlan.CateGoryCode as ExamCategoryCode,v_ExamPlan.ExamType as ExamType 
                                  ,A.SEGMENTCODE 
                                  ,A.EXAMPLANCODE ,A.TCPCODE,A.SPYCODE  
                                  ,c.batchcode,c.modulecode, c.courseid,C.COURSETYPE ,C.COURSENATURE ,C.CREDIT ,C.EXAMUNIT ,C.ISMUTEX ,C.ISCONVERSION ,C.SEMESTER ,C.SN ,C.RSN,C.ISREPLACE
                                  ,A.EXAMCATEGORY_SN catesn ,A.STUDENTCATEGORY   from eas_exmm_examguidance a inner join eas_exmm_bin2semester b on A.USESEMESTER =B.BINSEMESTER 
                                  inner join eas_exmm_Examcourses c on A.TCPCODE =C.TCPCODE and B.SEMESTER =C.SEMESTER and A.SEGMENTCODE =C.SEGMENTCODE and A.STUDENTCATEGORY =C.STUDENTCATEGORY  
                                    where A.EXAMPLANCODE = trim(v_ExamPlan.plancode) and  A.EXAMCATEGORY_SN= v_iExamCategorySN and A.SEGMENTCODE =trim(v_iSegmentCode) and C.EXAMUNIT = trim(v_ExamPlan.Planuseorgtype) )
                                     
                    select seq_ExmM_ExamCoursePlan.nextval
                               ,studentcategory
                        ,segmentcode,examplancode,examcategorycode,tcpcode,spycode,semester
                        ,batchcode,modulecode,courseid,coursetype,coursenature,credit,examunit,ismutex,isconversion,sn 
                        ,department
                        ,iscomputerexam
                        ,isintcp
                     ,v_iOperater,sysdate
           from (      select  ta.STUDENTCATEGORY 
                      ,ta.segmentcode,ta.examplancode,ta.ExamCategoryCode,ta.tcpcode,ta.spycode,ta.semester
                      ,ta.batchcode,ta.modulecode,ta.courseid,ta.coursetype,ta.coursenature,ta.credit,ta.examunit,ta.ismutex,ta.isconversion,ta.sn
                      ,TE.DEPARTMENT ,1 as isintcp ,case when  TD.EXAMTYPE=1 then 0 else 1 end as iscomputerexam
                      
                         from examcourse ta inner join eas_exmm_examcourseslist tb on ta.sn=tb.sn
                      inner join  eas_exmm_excoursesmodenorm td on  ta.examtype=TD.EXAMTYPE 
                      inner join  eas_course_basicinfo te on ta.courseid=te.courseid
                      where ta.isreplace=0 
                      and exists(select * from eas_exmm_subject where exampapercode=tb.exampapercode and segmentcode=ta.segmentcode and ASSESSMODE=td.ASSESSMODE)
                      and  not exists(select * from EAS_ExmM_ExamCoursePlan l where L.EXAMCATEGORYCODE= ta.EXAMCATEGORYCODE and  l.EXAMPLANCODE =tA.EXAMPLANCODE and  l.SEGMENTCODE=tA.SEGMENTCODE and L.TCPCODE =tA.TCPCODE and L.COURSEID =ta.COURSEID and L.STUDENTCATEGORY = ta.studentcategory  )
                      union
                      select  ta.STUDENTCATEGORY 
                      ,ta.segmentcode,ta.examplancode,ta.examcategorycode,ta.tcpcode,ta.spycode,ta.semester
                      ,ta.batchcode,ta.modulecode,ta.courseid,ta.coursetype,ta.coursenature,ta.credit,ta.examunit,ta.ismutex,ta.isconversion,ta.rsn -- ʹ������ε�SN
                      ,TE.DEPARTMENT ,1 as isintcp ,case when  TD.EXAMTYPE=1 then 0 else 1 end as iscomputerexam
                               from examcourse ta inner join eas_exmm_examcourseslist tb on ta.rsn=tb.sn
                      inner join  eas_exmm_excoursesmodenorm td on   ta.examtype=TD.EXAMTYPE
                      inner join  eas_course_basicinfo te on ta.courseid=te.courseid
                      where ta.isreplace=1
                      and exists(select * from eas_exmm_subject where exampapercode=tb.exampapercode and segmentcode=ta.segmentcode and ASSESSMODE=td.ASSESSMODE)
                      and not exists(select * from EAS_ExmM_ExamCoursePlan l where L.EXAMCATEGORYCODE= ta.EXAMCATEGORYCODE and  l.EXAMPLANCODE =tA.EXAMPLANCODE and  l.SEGMENTCODE=tA.SEGMENTCODE and L.TCPCODE =tA.TCPCODE and L.COURSEID =ta.COURSEID and L.STUDENTCATEGORY = ta.studentcategory  )
                      );
                         v_Continue := SQL%ROWCOUNT;     
                      dbms_output.put_line('EAS_ExmM_ExamCoursePlan' ||  v_Continue);
            

                    insert into EAS_ExmM_ExamCoursePlanList(sn,normcode,exampapercode)
                        select a.sn,B.NORMCODE,B.EXAMPAPERCODE    from  EAS_ExmM_ExamCoursePlan a inner join EAS_ExmM_ExamCoursesList b on a.ExamCourse_SN=b.sn
                        inner join eas_exmm_subject c on B.EXAMPAPERCODE =C.EXAMPAPERCODE and A.SEGMENTCODE =c.segmentcode
                        inner join eas_exmm_excoursesmodenorm d on C.ASSESSMODE =D.ASSESSMODE 
                        where 
                         A.EXAMPLANCODE =v_ExamPlan.plancode and A.EXAMCATEGORYCODE =v_ExamPlan.CateGoryCode and A.SEGMENTCODE =v_iSegmentCode
                        and d.EXAMTYPE =v_ExamPlan.ExamType 
                        and not exists(select * from EAS_ExmM_ExamCoursePlanList l where l.sn=A.SN and L.NORMCODE =B.NORMCODE and L.EXAMPAPERCODE =B.EXAMPAPERCODE );
                         
                 dbms_output.put_line('EAS_ExmM_ExamCoursePlanList' ||  SQL%ROWCOUNT);

       

     
     end if;
     

     
       RETCODE :=v_Continue;
     
    dbms_output.put_line( 'RETCODE' || RETCODE );
    commit;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='0';
     rollback;
   
 END PR_EXMM_BATCHADDEXAMCOURSEPLAN;
 
  --�̳п����γ�
   PROCEDURE PR_EXMM_INHERITEXAMCOURSEPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2) IS
       v_ExamPlanSNSource EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_SOURCE ;
       v_ExamCategorySNSource EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_SOURCE;
         v_ExamPlanSNTarget EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_TARGET ;
         v_ExamCategorySNTarget EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_TARGET;
         v_SegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
         v_Operater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_Maintainer;
 -------------------------
    v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������ 
    v_ExamPlanSource ExamPlan :=Examplan(v_ExamPlanSNSource,v_SegmentCode,v_ExamCategorySNSource); ----���Լƻ�����
    v_ExamPlanTarget ExamPlan :=Examplan(v_ExamPlanSNTarget,v_SegmentCode,v_ExamCategorySNTarget); ----���Լƻ�����
 BEGIN
 ----�ж����������Զ����Ƿ��Ѿ����� -----
     
       if v_ExamPlanTarget.IsApply=1 then
         v_Continue := 'A';
        dbms_output.put_line('��������Ѿ��·�,�����Զ�����'); 
        goto IsContinue;
       end if;
 
        if v_ExamPlanSource.ExamType<>v_ExamPlanTarget.ExamType then
            v_Continue := 'B';
           dbms_output.put_line('ԭ������Ŀ�궨����ͬ�򿼺���ʽ��ͬ'); 
           goto IsContinue;
         end if;
          
        <<IsContinue>> 
     if v_Continue='OK' then 
     ---- ��ʼ�̳�
     insert into EAS_ExmM_ExamCoursePlan(sn
    ,StudentCategory
    ,segmentcode,examplancode,examcategorycode,tcpcode,spycode,semester
    ,batchcode    ,modulecode    ,courseid    ,coursetype,coursenature   ,credit  ,examunit ,ismutex         ,isconversion,ExamCourse_SN
    ,departmentcode
    ,iscomputerexam
    ,isintcp 
    ,maintainer,maintaindate)

     select seq_ExmM_ExamCoursePlan.nextval
     ,A.STUDENTCATEGORY 
     ,A.SEGMENTCODE ,v_ExamPlanTarget.plancode ,A.EXAMCATEGORYCODE ,A.TCPCODE ,A.SPYCODE ,A.SEMESTER 
     ,A.BATCHCODE ,A.MODULECODE ,A.COURSEID ,A.COURSETYPE ,A.COURSENATURE ,A.CREDIT,A.EXAMUNIT  ,A.ISMUTEX ,A.ISCONVERSION ,A.SN 
     ,A.DEPARTMENTCODE 
     ,A.ISCOMPUTEREXAM 
     ,A.ISINTCP 
     ,v_Operater,sysdate
      from EAS_ExmM_ExamCoursePlan a
       where  A.EXAMPLANCODE =v_ExamPlanSource.plancode and A.EXAMCATEGORYCODE =v_ExamPlanSource.CateGoryCode and A.SEGMENTCODE =v_SegmentCode
       and not exists(select * from EAS_ExmM_ExamCoursePlan l where L.SEGMENTCODE =A.SEGMENTCODE and L.EXAMCATEGORYCODE =A.EXAMCATEGORYCODE and A.TCPCODE =L.TCPCODE and A.COURSEID =L.COURSEID 
       and L.EXAMPLANCODE =v_ExamPlanTarget.plancode);
 
          
            v_Continue := SQL%ROWCOUNT;     
            dbms_output.put_line('EAS_ExmM_ExamCoursePlan' ||  v_Continue);
            

      insert into EAS_ExmM_ExamCoursePlanList(sn,normcode,exampapercode)
                        select a.sn,B.NORMCODE,B.EXAMPAPERCODE    from  EAS_ExmM_ExamCoursePlan a inner join EAS_ExmM_ExamCoursePlanList b on a.ExamCourse_SN=b.sn
                        where 
                         A.EXAMPLANCODE =v_ExamPlanTarget.plancode and A.EXAMCATEGORYCODE =v_ExamPlanSource.CateGoryCode and A.SEGMENTCODE =v_SegmentCode
                        and not exists(select * from EAS_ExmM_ExamCoursePlanList l where l.sn=A.SN and L.NORMCODE =B.NORMCODE and L.EXAMPAPERCODE =B.EXAMPAPERCODE );
                         
             dbms_output.put_line('EAS_ExmM_ExamCoursePlanList' ||  SQL%ROWCOUNT);
   
     end if; 
     RETCODE :=v_Continue;
     dbms_output.put_line( 'returnCode' || RETCODE );
    commit; 
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='0,�����쳣';
     rollback;
    
  END PR_EXMM_INHERITEXAMCOURSEPLAN;
 
 




  -- �Զ�������׷�Ӽƻ�������Ŀ
  PROCEDURE PR_EXMM_BATCHADDSUBJECTPLAN(i_MAINTAINER IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_EXAMTIMELENGTH IN number ,i_OperateType IN number,RETCODE OUT varchar2 ) IS
    v_iExamPlanSN EAS_EXMM_DEFINITION.sn %type :=i_EXAMPLANSN;
     v_iExamCategorySN EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYTSN;
     v_iSegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
     v_iOperater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_MAINTAINER;  --������  
     v_iOperateType number := i_OperateType; -- 1.���� ��Ҫִ����ղ����� 2 ׷�� ֻ�����µ�
     v_iEXAMTIMELENGTH   EAS_EXMM_SUBJECTPLAN.EXAMTIMELENGTH %type :=i_EXAMTIMELENGTH;  --0��ʾ��ָ������ʱ����ʹ��Ĭ��ֵ
      ----------------�ƻ����� 
      v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������
     v_ExamPlan ExamPlan :=Examplan(v_iExamPlanSN,v_iSegmentCode,v_iExamCategorySN); ----���Լƻ�����
 BEGIN
 ----�жϿ��Զ����Ƿ��Ѿ����� -----
    dbms_output.put_line(v_Examplan.plancode ||'-'||v_Examplan.isapply||'-'||v_ExamPlan.CateGoryCode||'-'||v_ExamPlan.ExamType);
-- End;
  
      
    -- if v_ExamPlan.IsApply=1 then
    --    v_Continue := 'A';
    --   dbms_output.put_line('��������Ѿ��·�,�����Զ�����'); 
    --   goto IsContinue;
    -- end if;
 
     if v_iOperateType = 1 then
      ----��ǰ����Ϊ������ͨ������ɾ����ɶ��ӱ��ɾ��--
         delete from EAS_ExmM_SubjectPlan where SegmentCode=v_iSegmentCode and  ExamPlanCode=v_Examplan.plancode and  ExamCategoryCode= v_ExamPlan.CateGoryCode;
         dbms_output.put_line('���� ����ǰɾ���ܼ�¼��' ||  SQL%ROWCOUNT); 
      end if;
      
      <<IsContinue>> 
      if v_Continue='OK' then 
     ---- ��ʼ����
     insert into EAS_EXMM_SUBJECTPLAN(  SN
                       ,EXAMPLANCODE ,EXAMCATEGORYCODE     ,SEGMENTCODE,EXAMSESSIONUNIT
        ,EXAMPAPERCODE  ,EXAMPAPERNAME     ,ASSESSMODE   ,EXAMMODE  ,ISINTCP      ,ISUSEANSWERCARD,ISHAVESUBJECTIVE     ,ISUSECD    ,ISUSERANSWERTAB,EXAMTOOLS
        ,EXAMTIMELENGTH  ,REMARK,sharesn
      ,ISARRANGE,ISALLOWMAKESCALE,ALLOWMAKEEXAMSESSION,ALLOWMAKEPAPER,ALLOWMAKEORDER,EXAMUNITTYPE
          ,MAINTAINER,MAINTAINDATE,ARRANGESTATE,ITEMGROUP)
     -----------------------------
     with tSource as (
          select   v_Examplan.plancode as examplancode ,v_ExamPlan.CateGoryCode examcategorycode,v_iSegmentCode segmentcode ,null examsessionunit, v_ExamPlan.PlanUseOrgType PlanUseOrgType
           , A.EXAMPAPERCODE ,A.EXAMPAPERNAME ,A.ASSESSMODE ,A.EXAMMODE ,A.ISINTCP ,A.ISUSEANSWERCARD ,A.ISHAVESUBJECTIVE ,A.ISUSECD ,A.ISUSERANSWERTAB ,A.EXAMTOOLS
          ,A.EXAMTIMELENGTH  ,A.remark,case when a.isopen='1' then A.SHARESN else 0 end sharesn,a.isopen
          from eas_exmm_subject a where exists(select * from  EAS_ExmM_ExamCoursePlanList b inner join  EAS_ExmM_ExamCoursePlan c on b.sn=C.SN where a.exampapercode=b.exampapercode
          and C.EXAMPLANCODE =v_Examplan.plancode and C.EXAMCATEGORYCODE =v_ExamPlan.CateGoryCode and  segmentcode=v_iSegmentCode) and segmentcode=v_iSegmentCode)
          -----------
      select   seq_ExmM_SubjectPlan.nextval,
                     A1.examplancode ,A1.examcategorycode,A1.segmentcode ,A1.examsessionunit,
        A1.EXAMPAPERCODE ,A1.EXAMPAPERNAME ,A1.ASSESSMODE ,A1.EXAMMODE ,A1.ISINTCP ,A1.ISUSEANSWERCARD ,A1.ISHAVESUBJECTIVE ,A1.ISUSECD ,A1.ISUSERANSWERTAB ,A1.EXAMTOOLS,
        case when v_iEXAMTIMELENGTH=0 then A1.EXAMTIMELENGTH else v_iEXAMTIMELENGTH end,A1.REMARK,A1.SHARESN,
        1 as isarrange,case when A1.PlanUseOrgType=1 then 0 else 1 end as isallowmakescale,case when A1.PlanUseOrgType=1 then 0 else 1 end as allowmakeexasession,case when A1.PlanUseOrgType=1 then 0 else 1 end as allowmakerpaper,0 as allowmarkorder,A1.PlanUseOrgType,
        v_iOperater,sysdate    ,2 as arrangestate,null as itemgroup 
        from tSource A1 where not exists(select * from  eas_exmm_subjectplan where examplancode=A1.ExamPlancode  and examcategorycode=A1.ExamCategoryCode 
        and segmentcode=A1.Segmentcode and exampapercode=A1.exampapercode);  
         
               v_Continue := SQL%ROWCOUNT;     
              dbms_output.put_line('EAS_EXMM_SUBJECTPLAN' ||  v_Continue);
      ------����������
      
      update EAS_EXMM_SUBJECTPLAN a  set (ASSESSMODE,ExamMode,ExamTools,ISUSEANSWERCARD,ISHAVESUBJECTIVE,ISUSECD,ISUSERANSWERTAB,EXAMTIMELENGTH)=(select 
      B.ASSESSMODE,b.ExamMode,b.EXAMTOOLS ,b.ISUSEANSWERCARD , b.ISHAVESUBJECTIVE,b.ISUSECD,b.ISUSERANSWERTAB,case when v_iEXAMTIMELENGTH=0 then b.EXAMTIMELENGTH else v_iEXAMTIMELENGTH end
        from EAS_EXMM_SUBJECT b where a.sharesn=b.sn   )
            where a.examplancode=v_Examplan.plancode and a.examcategorycode=v_ExamPlan.CateGoryCode and A.SEGMENTCODE =v_iSegmentCode and a.sharesn>0;

          dbms_output.put_line('�����Ŀ�޸ģ�EAS_EXMM_SUBJECTPLAN Ӱ���¼����' || SQL%ROWCOUNT);   

     
     end if;
     
   
     RETCODE :=v_Continue;
   
    dbms_output.put_line( 'returnCode' || v_Continue );
    commit; 
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='0,�����쳣';
     rollback;
  END PR_EXMM_BATCHADDSUBJECTPLAN;

 

  -- �̳мƻ�������Ŀ
     PROCEDURE PR_EXMM_INHERITSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2) IS
      v_ExamPlanSNSource EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_SOURCE ;
       v_ExamCategorySNSource EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_SOURCE;
         v_ExamPlanSNTarget EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_TARGET ;
         v_ExamCategorySNTarget EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_TARGET;
         v_SegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
         v_Operater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_Maintainer;
 -------------------------
    v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������ 
    v_ExamPlanSource ExamPlan :=Examplan(v_ExamPlanSNSource,v_SegmentCode,v_ExamCategorySNSource); ----���Լƻ�����
    v_ExamPlanTarget ExamPlan :=Examplan(v_ExamPlanSNTarget,v_SegmentCode,v_ExamCategorySNTarget); ----���Լƻ�����
  
 BEGIN
 ----�ж����������Զ����Ƿ��Ѿ����� -----
     if v_ExamPlanTarget.IsApply=1 then
        v_Continue := 'A';
       dbms_output.put_line('��������Ѿ��·�,�����Զ�����'); 
       goto IsContinue;
     end if;
 
    if v_ExamPlanSource.ExamType<>v_ExamPlanTarget.ExamType then
        v_Continue := 'B';
       dbms_output.put_line('ԭ������Ŀ�궨����ͬ�򿼺���ʽ��ͬ'); 
       goto IsContinue;
     end if;
    
       <<IsContinue>> 
     if v_Continue='OK' then 
     ---- ��ʼ�̳�
     insert into EAS_EXMM_SUBJECTPLAN(SN
         ,EXAMPLANCODE ,EXAMCATEGORYCODE     ,SEGMENTCODE,EXAMSESSIONUNIT
      ,EXAMPAPERCODE,EXAMPAPERNAME,ASSESSMODE    ,EXAMMODE  ,ISINTCP      ,ISUSEANSWERCARD,ISHAVESUBJECTIVE     ,ISUSECD    ,ISUSERANSWERTAB
        ,EXAMTIMELENGTH  
      ,ISARRANGE,ISALLOWMAKESCALE,ALLOWMAKEEXAMSESSION,ALLOWMAKEPAPER,ALLOWMAKEORDER,EXAMTOOLS,EXAMUNITTYPE
          ,MAINTAINER,MAINTAINDATE,ARRANGESTATE,ITEMGROUP,REMARK,sharesn)

      select    seq_ExmM_SubjectPlan.nextval
        ,v_ExamPlanTarget.planCode ,v_ExamPlanTarget.CateGoryCode ,A.SEGMENTCODE ,null as  EXAMSESSIONUNIT
     ,A.EXAMPAPERCODE  ,a.EXAMPAPERNAME ,a.ASSESSMODE ,a.EXAMMODE ,a.ISINTCP ,a.ISUSEANSWERCARD ,a.ISHAVESUBJECTIVE ,a.ISUSECD ,a.ISUSERANSWERTAB
      , a.EXAMTIMELENGTH 
      ,a.isarrange,  a.isallowmakescale,a.allowmakeexamsession,a.allowmakepaper,a.allowmakeorder,a.EXAMTOOLS ,v_ExamPlanTarget.PlanUseOrgType
           ,v_Operater,sysdate    ,2 as arrangestate,null as itemgroup,a.REMARK,a.SHARESN      
      from EAS_EXMM_SUBJECTPLAN a
        where
             a.examplancode=v_ExamPlanSource.plancode and a.examcategorycode=v_ExamPlanSource.CateGoryCode and A.SEGMENTCODE =v_SegmentCode
      and not exists(select * from  eas_exmm_subjectplan l where A.EXAMCATEGORYCODE =v_ExamPlanTarget.CateGoryCode and L.EXAMPLANCODE=v_ExamPlanTarget.plancode and A.SEGMENTCODE =L.SEGMENTCODE and a.EXAMPAPERCODE =L.EXAMPAPERCODE)
      and exists(select * from EAS_ExmM_ExamCoursePlan ta inner join EAS_ExmM_ExamCoursePlanList tb on ta.sn=tb.sn where tA.EXAMPLANCODE =v_ExamPlanTarget.plancode
      and tA.EXAMCATEGORYCODE = v_ExamPlanTarget.CateGoryCode and tA.SEGMENTCODE =v_SegmentCode and tB.EXAMPAPERCODE =A.EXAMPAPERCODE );
  
      
          v_Continue :=SQL%ROWCOUNT;
          dbms_output.put_line('EAS_EXMM_SUBJECTPLAN Ӱ���¼����' || v_Continue);
     
     
     end if; 
    
     RETCODE :=v_Continue;
    
    dbms_output.put_line( 'returnCode' || RETCODE );
    commit; 
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='0,�����쳣';
     rollback;
   
   END PR_EXMM_INHERITSUBJECTPLAN;
  
  --����ʱ�䵥Ԫ����
 PROCEDURE PR_EXMM_GETSESSIONUNIT(i_PlanSN number,i_CategoryCode varchar2, i_SegmentCode varchar2,i_tbFrom number,arrRet OUT SessionUnit_Array) IS
 arrSessionUnit SessionUnit_Array :=SessionUnit_Array('','','','','','','','');
 BEGIN
 --- �˴��������Ƿ��¼���ڵ��жϣ����е��ж������߼��н���
 -- i_planSN ���Զ���SN  i_SegmentCode �ֲ�����  i_tbFrom ��1����2�·���ȡ���� arrRet ���ض�Ӧ�Ŀ��Կ�ʼʱ������
  if i_tbFrom=1 then
              execute immediate 'select   Part1begin, Part2begin, Part3begin, Part4begin, Part5begin, Part6begin, Part7begin, Part8begin from eas_exmm_definitiondetail  where SN='||i_PlanSN||'and ExamCategoryCode='''||i_CategoryCode||'''' 
              into                          arrSessionUnit(1) ,arrSessionUnit(2),arrSessionUnit(3)  ,arrSessionUnit(4) ,arrSessionUnit(5)  ,arrSessionUnit(6),arrSessionUnit(7) ,arrSessionUnit(8);
  else
              execute immediate 'select   Part1begin, Part2begin, Part3begin, Part4begin, Part5begin, Part6begin, Part7begin, Part8begin from eas_exmm_definitiondetailPub  where SN='||i_PlanSN||' and Segmentcode='''||i_SegmentCode||'''and ExamCategoryCode='''||i_CategoryCode||''''
              into                          arrSessionUnit(1) ,arrSessionUnit(2),arrSessionUnit(3)  ,arrSessionUnit(4) ,arrSessionUnit(5)  ,arrSessionUnit(6),arrSessionUnit(7) ,arrSessionUnit(8);
  
  end if;
 arrRet := arrSessionUnit;
 END PR_EXMM_GETSESSIONUNIT;
 
  
 
  --���ؿ������� i_Operate 1 ֻʹ����ʱ��� 2 ʹ����չʱ���
 PROCEDURE PR_EXMM_GETEXAMDATELIST(i_NewBeginDate date,i_NewEndDate date,i_ExistBeginDate date,i_ExistEndDate date,i_Operate number,ExamDatelist out ExamDate_array) IS
 vExamDate_array ExamDate_array;
 v_count number;
 v_NewBeginDate date:=to_date(to_char(i_NewBeginDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 v_ExistBeginDate date:=to_date(to_char(i_ExistBeginDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 v_NewEndDate date:=to_date(to_char(i_NewEndDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 v_ExistEndDate date:=to_date(to_char(i_ExistEndDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 
 BEGIN
  vExamDate_array.Delete;
   if i_Operate=1 then -- ��ʼ��
          dbms_output.put_line('��ʼ����ʼ');
             for i in 1..v_NewEndDate-v_NewBeginDate+1
             loop
               vExamDate_array(i):=v_NewBeginDate+i-1;
             end loop;
     else    --���ӳ�ʼ��v_iOperateType=2
          dbms_output.put_line('������ʼ����ʼ');
               ----�ж� �ӳ���ʱ�䲻����ԭʱ�䷶Χ��
              if (v_NewBeginDate>v_ExistBeginDate and v_NewBeginDate<v_ExistEndDate) or (v_NewEndDate>v_ExistBeginDate and v_NewEndDate<v_ExistEndDate ) then
                 
                  dbms_output.put_line('�������ã��¿�ʼʱ����ԭʱ�䷶Χ�ڣ����½���ʱ����ԭʱ�䷶Χ�ڡ���ʱ�䣺'||i_NewBeginDate||'~~'||i_NewEndDate||'~ԭʱ��~'||i_ExistBeginDate||'~~'||i_ExistEndDate);
              else   -- ������ʱ��ο���ʱ��
                 if v_NewBeginDate>v_ExistEndDate or v_NewEndDate<v_ExistBeginDate then
                      for i in 1..v_NewEndDate-v_NewBeginDate+1
                      loop
                         vExamDate_array(i):=v_NewBeginDate+i-1;
                      end loop;
                   
                else
                 if v_NewBeginDate<v_ExistBeginDate then
                     for i in 1..v_ExistBeginDate-v_NewBeginDate --ʱ����ǰ�ӳ�
                     loop
                      vExamDate_array(i):=v_NewBeginDate+i-1;
                     end loop;
                 end if ;
                 v_count := vExamDate_array.count; -- ǰһ�ο���
                 if v_NewEndDate>v_ExistEndDate then
                    for j in 1..v_NewEndDate-v_ExistEndDate        --ʱ���Ӻ�
                     loop
                      vExamDate_array(v_count+j):=v_ExistEndDate+j;
                      end loop;
                  end if;
                end if;
              end if;
     
     end if;
     
    ExamDatelist:=vExamDate_array;
 END PR_EXMM_GETEXAMDATELIST;
 
 
  
  -- ���ؿ��Լƻ�����
 PROCEDURE PR_EXMM_GETEXAMPLANOBJ(i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,r_ExamPlan OUT EXAMPLAN) IS
  v_PlanMakeOrgCode VARCHAR2(20);
  v_PlanMakeOrgType VARCHAR2(3);
  v_PlanUseOrgCode VARCHAR2(20) :=i_PlanUseOrgCode;
  v_PlanUsrOrgType VARCHAR2(255);
  v_IsInPlanPub NUMBER :=0;   -- �Ƿ���ֽ���ƻ��·������м�¼ 1�У�0�ޣ� ֻ�Ե�λΪ�ֲ�����Ч�ܲ�ȱʡΪ1 
  v_IsApply     number;
  v_ExamSessionUnitMode NUMBER :=0;
  v_PlanCode      varchar2(20);
  v_CateGoryCode  varchar2(20);
  v_CateGoryOrgCode varchar2(20);
  v_CateGoryOrgType varchar2(3);
  v_IsInDetailPub   number :=0; --�Ƿ��ڼƻ�����ʱ���·������м�¼ 1��0�� ֻ�Էֲ���Ч���ܲ�ȱʡΪ1
  v_ExamType        number;
  v_IsDataOK        number; 
  v_ErrorCode       number;
 BEGIN
  execute immediate 'select a.examtype ,nvl(b.sn,0) from EAs_Exmm_definition a left join EAS_ExmM_PaperExamPlan b on a.sn=b.sn  where a.sn='||i_ExamPlanSN||''
  into v_ExamType,v_IsDataOK;
  if v_ExamType=1  then
    if  v_IsDataOK>0 then 
     v_ErrorCode :=0;
     
       execute immediate 'with planmake as (select a.sn, A.EXAMPLANCODE as plancode,B.CREATEORGCODE  as PlanMakeOrgCode,c.ORGANIZATIONTYPE as PlanMakeOrgType,B.ISAPPLY   from EAS_ExmM_PaperExamPlan a inner join EAs_Exmm_definition b on a.sn=b.sn inner join  eas_org_basicinfo c on B.CREATEORGCODE =c.ORGANIZATIONCODE where a.sn='||i_ExamPlanSN||')
                ,Useorg as (select A.ORGANIZATIONCODE planuseorgcode ,A.ORGANIZATIONTYPE planuseorgtype  from  eas_org_basicinfo a where A.ORGANIZATIONCODE ='''||i_PlanUseOrgCode||''')
                ,CateUse as (select A2.EXAMCATEGORYCODE as CateGoryCode, A2.SEGMENTCODE as CateGoryOrgCode,C2.ORGANIZATIONTYPE as CateGoryOrgType  from EAS_ExmM_ExamCategory a2 inner join   eas_org_basicinfo c2 on A2.SEGMENTCODE  =c2.ORGANIZATIONCODE where a2.sn='||i_ExamCategorySN||')
                select tb1.isapply, tb1.plancode,tb1.planmakeorgcode,tb1.planmakeorgtype,tb2.planuseorgcode,tb2.planuseorgtype,tb3.categorycode,tb3.categoryorgcode,tb3.categoryorgtype  from planmake tb1 cross join Useorg tb2 cross join cateUse tb3 '
                into  v_IsApply,     v_PlanCode ,v_PlanMakeOrgCode    ,v_PlanMakeOrgType   , v_PlanUseOrgCode,v_PlanUsrOrgType ,v_CateGoryCode  ,v_CateGoryOrgCode ,v_CateGoryOrgType;
                
      ----����Ƿֲ����ж���Ӧ���·����Ƿ��м�¼
      if   v_PlanUsrOrgType=2 then
          execute immediate 'with PaperplanPub as (select case when count(*)>0 then 1 else 0 end IsInPlanPub ,sum(ExamSessionUnitMode) ExamSessionUnitMode from EAS_ExmM_PaperExamPlanPub a1 where a1.sn='||i_ExamPlanSN||' and A1.SEGMENTCODE ='''||i_PlanUseOrgCode||''')
        ,ExamtimePub as (select case when count(*)>0 then 1 else 0 end IsInDetailPub from EAS_ExmM_definitionDetailPub a3 where a3.sn='||i_ExamPlanSN||' and A3.SEGMENTCODE ='''||i_PlanUseOrgCode||''' and exists(select * from EAS_ExmM_ExamCategory where EXAMCATEGORYCODE=a3.EXAMCATEGORYCODE and sn='||i_ExamCategorySN||'))
        select tb1.IsInPlanPub,tb1.ExamSessionUnitMode ,tb2.IsInDetailPub from PaperplanPub tb1 cross join   ExamtimePub tb2'
        into   v_IsInPlanPub    ,v_ExamSessionUnitMode, v_IsInDetailPub;
      else  ---�ܲ��жϿ��Լƻ�ʱ��
         execute immediate 'with 
         ExamtimePub as (select case when count(*)>0 then 1 else 0 end IsInDetailPub from EAS_ExmM_definitionDetail a3 where a3.sn='||i_ExamPlanSN||' and exists(select * from EAS_ExmM_ExamCategory where EXAMCATEGORYCODE=a3.EXAMCATEGORYCODE and sn='||i_ExamCategorySN||'))
         select tb2.IsInDetailPub from  ExamtimePub tb2'
        into    v_IsInDetailPub;
      end if;  
              
  
    else
      v_ErrorCode:=1; 
    end if;
      
    -- ��Ӧ���ж��Ƿ��·�����Ӧ����
/*PlanMakeOrgCode VARCHAR2(20),
  PlanMakeOrgType VARCHAR2(3),
  PlanUseOrgCode VARCHAR2(20),
  PlanUsrOrgType VARCHAR2(255),
  IsInPlanPub NUMBER,
  IsApply   NUMBER,
  ExamSessionUnitMode NUMBER,
  PlanCode      varchar2(20),
  CateGoryCode  varchar2(20),
  CateGoryOrgCode varchar2(20),
  CateGoryOrgType varchar2(3),
  RETMSG          varchar2(1000)*/
  end if ;
  --r_ExamPlan:=new EXAMPLAN(v_PlanMakeOrgCode,v_PlanMakeOrgType,v_PlanUseOrgCode,v_PlanUsrOrgType,v_IsInPlanPub,v_IsApply,v_ExamSessionUnitMode,v_PlanCode,v_CateGoryCode,v_CateGoryOrgCode,v_CateGoryOrgType,v_IsInDetailPub,v_ErrorCode);
 END PR_EXMM_GETEXAMPLANOBJ;
 
  -- ���ؼƻ�����ʱ�����
  PROCEDURE PR_EXMM_GETEXAMTIMEOBJ(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,i_OperateType number,r_EXAMTIME out EXAMTIME) IS
  v_PartNum number;
  v_NewBeginDate date;
  v_NewEndDate   date;
  v_ExistBeginDate date;
  v_ExistEndDate   date;
  v_BeginNumber number;
  v_SEGMENTTEGINNUMBER number;
  BEGIN
 --------i_OperateType :1��ʾ�ܲ����� 2��ʾ�ֲ�����
    if i_OperateType=1 then  --ȡ�ܲ�����ʱ�����ú��Ѿ����úõ�
       execute immediate ' with time1 as (select numofpart,begindate,enddate from EAS_ExmM_DefinitionDetail a  where A.EXAMPLANCODE ='''||i_ExamPlanCode||''' and A.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''' )
       ,examdate1 as (select nvl(max(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldend1  ,nvl(min(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldbegin1 ,nvl(max(to_number(A.EXAMSESSIONUNIT)),0) beginnumber from  EAS_ExmM_ExamSessionPlan a where a.EXAMPLANCODE ='''||i_ExamPlanCode||''' and a.SEGMENTCODE=''010'' and a.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''')
       select numofpart,begindate,enddate,oldbegin1,oldend1,beginnumber from time1 cross join examdate1 '
       into v_PartNum,v_NewBeginDate,v_NewEndDate,v_ExistBeginDate,v_ExistEndDate,v_BeginNumber;
    else  --�ֲ��Ŀ���ʱ�䴦��
        execute immediate '  with time1 as (select numofpart,begindate,enddate from EAS_ExmM_Definitiondetailpub a where A.EXAMPLANCODE ='''||i_ExamPlanCode||''' and A.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''' and A.SEGMENTCODE ='''||i_PlanUseOrgCode||''' )
       ,examdate1 as (select nvl(min(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldbegin1  ,nvl(max(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldend1,nvl(max(to_number(A.EXAMSESSIONUNIT)),0) beginnumber1 from  EAS_ExmM_ExamSessionPlan a where a.EXAMPLANCODE ='''||i_ExamPlanCode||''' and a.SEGMENTCODE=''010'' and a.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''')
       ,examdate2 as (select nvl(min(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldbegin2,nvl(max(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldend2,nvl(max(to_number(A.EXAMSESSIONUNIT)),0) beginnumber2 from  EAS_ExmM_ExamSessionPlan a where a.EXAMPLANCODE ='''||i_ExamPlanCode||''' and a.SEGMENTCODE='''||i_PlanUseOrgCode||''' and a.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''')
       select numofpart,begindate,enddate,case when oldbegin1>=oldbegin2 then oldbegin1 else oldbegin2 end ,case when oldend1>=oldend2 then oldend1 else oldend2 end,case when beginnumber1>beginnumber2 then beginnumber1 else beginnumber2 end,beginnumber2 from time1 cross join examdate1 cross join  examdate2'
       into v_PartNum,v_NewBeginDate,v_NewEndDate,v_ExistBeginDate,v_ExistEndDate,v_BeginNumber,v_SEGMENTTEGINNUMBER;
    end if;
    /*
    PARTSNUM NUMBER,
  NEWBEGINDATE DATE,
  NEWENDDATE DATE,
  EXISTBEGINDATE DATE,
  EXISTTENDDATE DATE,
  BEGINNUMBER  number*/
    r_EXAMTIME := new EXAMTIME(v_PartNum,v_NewBeginDate,v_NewEndDate,v_ExistBeginDate,v_ExistEndDate,v_BeginNumber,v_SEGMENTTEGINNUMBER);
    
  END PR_EXMM_GETEXAMTIMEOBJ;
  
  -- �Ƚϼƻ������γ��п�Ŀ��ƻ�������Ŀ
  PROCEDURE PR_EXMM_COMPAREPAPER(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,r_Ret out Number) IS
  v_cnt1 number;
  v_cnt2 number;
  v_com1 number;
  v_com2 number;
  BEGIN
   r_Ret:=-1;---û�м�¼
    execute immediate 'with examcourse as(select distinct B.EXAMPAPERCODE  from  EAS_ExmM_ExamCoursePlan a inner join EAS_ExmM_ExamCoursePlanlist b on a.sn=b.sn where A.EXAMPLANCODE ='''||i_ExamPlanCode||''' and A.SEGMENTCODE ='''||i_PlanUseOrgCode||''' and A.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||'''),
       subject  as (select a.exampapercode  from EAS_ExmM_SubjectPlan a where A.EXAMPLANCODE ='''||i_ExamPlanCode||''' and A.SEGMENTCODE ='''||i_PlanUseOrgCode||''' and A.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''')
       select cnt1,cnt2,com1,com2 from (select count(*) cnt1,sum(case when b.exampapercode is null then 1 else 0 end) com1 from examcourse a left join subject b  on a.exampapercode=b.exampapercode)
        cross join (select count(*) cnt2,sum(case when b.exampapercode is null then 1 else 0 end) com2 from subject a left join  examcourse b  on a.exampapercode=b.exampapercode)'
    into v_cnt1,v_cnt2,v_com1,v_com2;
    if v_cnt1=v_cnt2 and v_com1=0 and v_com2=0 and v_cnt1>0 then
      r_Ret:=1;
    end if;  
    
    if v_cnt1=0 or v_cnt2=0 and v_cnt1<>v_cnt2 then
      r_Ret :=0; 
    end if;
  END;
 
---------------------------�ܲ�ʱ�䵥Ԫ��ʼ����������ʼ��
  PROCEDURE PR_EXMM_DEALSESSIONUNIT1(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) IS
  
 
 v_iExamPlanCodeSN     number :=i_ExamPlanSN ;
 v_iExamCategoryCodeSN number:=i_ExamCategorySN;
 v_iSegmentCode      EAS_EXMM_SUBJECTPLAN.SEGMENTCODE  %type :=i_PlanUseOrgCode;  --- ���Լƻ���ʹ�õ�λ
 v_iOperater         EAS_EXMM_SUBJECTPLAN.MAINTAINER %type :=i_Maintainer;
 v_iOperateType      number :=i_OperateType;                        ----1����ʼ�� 2��������ʼ��
 
 v_objExamPlan ExamPlan:=EXAMPLAN(v_iExamPlanCodeSN,v_iSegmentCode,v_iExamCategoryCodeSN); -- ���Լƻ�����
 v_objExamTime ExamTime ; -- �������ڷ�Χ����
 ------����ʱ������
 v_arrSessionUnit PK_EXMM.SessionUnit_Array;
  --������������
 v_arrExamDate    PK_EXMM.ExamDate_array;
 v_beginnumber    number;

 v_count             number;
 ------ ͨ��
 v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������
 v_StrTemp           varchar2(1000);

 BEGIN
 
    
      
          ------------<�ж�����>-------------   
      --- �жϿ��Զ���Ϳ������ �Ƿ�һ�� �� ������λ -----
        --PK_EXMM.PR_EXMM_GETEXAMPLANOBJ(v_iExamPlanCodeSN,v_iExamCategoryCodeSN,v_iSegmentCode,v_objExamPlan);
        dbms_output.put_line(v_objExamPlan.PlanCode||'~~'||v_objExamPlan.CateGoryCode||'~~~~'||v_iSegmentCode);
        if v_objExamPlan.ErrorCode=1 then 
         v_Continue := 'A';
         dbms_output.put_line('�������󣺿��Զ������ݲ�����');
         goto IsContinue;
        end if;
     
       if v_objExamPlan.IsApply=1 then 
         v_Continue := 'A1';
         dbms_output.put_line('�������󣺿��Զ����Ѿ��·�');
         goto IsContinue;
        end if;
          
          ---���Զ���Ϊ�ܲ���ʹ�õ�λ�ܲ�
        if v_objExamPlan.PlanMakeOrgType=1 and v_iSegmentCode<>v_objExamPlan.PlanMakeOrgCode  then
          v_Continue :='B1';
         dbms_output.put_line('��ʼ������B���ϸ񣺿��Զ���Ϊ�ܲ���ʹ�õ�λΪ���ܲ�');
         goto IsContinue;
        end if ;
        
        if v_objExamPlan.PlanMakeOrgType=2 then
          v_Continue :='B2';
         dbms_output.put_line('��ʼ������B���ϸ񣺿��Զ���Ϊ�ֲ���ʹ�õ�λΪ�ܲ�');
         goto IsContinue;
        end if ;
        
          --C: �жϼƻ������γ��Ծ���뿪����Ŀ�Ծ���Ƿ���ȫ��ͬ
        PK_EXMM.PR_EXMM_COMPAREPAPER(v_objExamPlan.PlanCode,v_objExamPlan.CateGoryCode,v_iSegmentCode,v_count);
        
        if v_count<>1 then
          v_Continue :='C';
         dbms_output.put_line('��ʼ������C���ϸ񣺼ƻ������γ��뿪����Ŀ����ͬ');
         goto IsContinue;
        end if ;     
        
        --D: �жϣ��ƻ�����ʱ�����Ƿ��ж�Ӧ��¼
        /*
        if v_objExamPlan.IsInDetailPub =0  then
          v_Continue :='D1';
         dbms_output.put_line('�ƻ�����ʱ���������');
         goto IsContinue;
        end if ;
        */
        --F:���쿼�����ںͿ���ʱ������
        dbms_output.put_line('�ƻ�����ʱ��'||v_objExamTime.NewBeginDate||'~'||v_objExamTime.NewEndDate||'~'||v_objExamTime.ExistBeginDate||'~'||v_objExamTime.ExistEndDate);
        --goto IsContinue;
          
         --D: �жϣ������ʼ����ʱ�䵥Ԫ���ű�Ӧ��Ϊ�� ����������ʱ�䰲�ű�Ӧ��Ϊ��
         ----ȡʱ�����ö���
         
        PK_EXMM.PR_EXMM_GETEXAMTIMEOBJ(v_objExamPlan.PlanCode, v_objExamPlan.CateGoryCode, v_iSegmentCode,1, v_objExamTime);
        
        dbms_output.put_line(v_objExamTime.BEGINNUMBER||'~'||v_objExamTime.ExistEndDate);
        if v_objExamTime.BEGINNUMBER>0 and v_iOperateType=1 then
          v_Continue :='D2';
         dbms_output.put_line('��ʼ������D1���ϸ񣺳�ʼ������ʱ�Ѿ���ʱ�䵥Ԫ��¼');
         goto IsContinue;
        end if ;     
           
       if v_objExamTime.BEGINNUMBER =0 and v_iOperateType=2 then
          v_Continue :='D3';
         dbms_output.put_line('������������D2���ϸ���������ʱû��ʱ�䵥Ԫ��¼');
         goto IsContinue;
        end if ; 
         
       
         --���ؿ������� i_Operate 1 ֻʹ����ʱ��� 2 ʹ����չʱ���
       PK_EXMM.PR_EXMM_GETEXAMDATELIST(v_objExamTime.NewBeginDate,v_objExamTime.NewEndDate,v_objExamTime.ExistBeginDate,v_objExamTime.ExistEndDate,v_iOperateType,v_arrExamDate);
       --- i_planSN ���Զ���SN  i_SegmentCode �ֲ�����  i_tbFrom ��1����2�·���ȡ���� arrRet ���ض�Ӧ�Ŀ��Կ�ʼʱ����
       PK_EXMM.PR_EXMM_GETSESSIONUNIT(v_iExamPlanCodeSN, v_objExamPlan.CateGoryCode, v_iSegmentCode, 1, v_arrSessionUnit);
        
       ------------<�ж�����>------------- 
        
   <<IsContinue>>
    
     if v_Continue='OK' then
    
      for i in 1..v_arrExamDate.Count
        Loop
          --dbms_output.put_line(v_arrExamDate(i));
          
          for j in 1..v_objExamTime.PARTSNUM
          loop
            dbms_output.put_line(v_arrExamDate(i)||'~'||v_arrSessionUnit(j)||'~' || to_char((v_objExamTime.BEGINNUMBER+(i-1)*v_objExamTime.PARTSNUM+j),'fm099'));
              v_StrTemp := to_char((v_objExamTime.BEGINNUMBER+(i-1)*v_objExamTime.PARTSNUM+j),'fm099');
              insert into eas_exmm_examsessionplan(sn      ,segmentcode    ,examplancode         ,examcategorycode,examsessionunit ,examdate,remark,exambegintime,examtimelength,createorgcode,maintainer,maintaindate)
                     select seq_ExmM_ExamSessionUnit.nextval,v_iSegmentCode,v_objExamPlan.PlanCode,v_objExamPlan.CateGoryCode,v_StrTemp,v_arrExamDate(i),null,v_arrSessionUnit(j),null,v_objExamPlan.PlanMakeOrgCode,v_iOperater,sysdate
                     from dual 
                     where not  exists(select * from eas_exmm_examsessionplan  where examsessionunit=v_StrTemp and EXAMPLANCODE =v_objExamPlan.PlanCode 
                     and EXAMCATEGORYCODE =v_objExamPlan.CateGoryCode and SEGMENTCODE =v_iSegmentCode);
          end loop;
          
        End Loop;
    
     end if ;
     --dbms_output.put_line(v_Continue);   
     

 
     RETCODE :=v_Continue;
    dbms_output.put_line( 'returnCode:' || RETCODE );
    if RETCODE='OK' then
        commit;
    end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
  END PR_EXMM_DEALSESSIONUNIT1;
  
  
  ---------------------------�ֲ�ʱ�䵥Ԫ��ʼ����������ʼ��
  PROCEDURE PR_EXMM_DEALSESSIONUNIT2(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) IS
 v_iExamPlanCodeSN     number :=i_ExamPlanSN ;
 v_iExamCategoryCodeSN number:=i_ExamCategorySN;
 v_iSegmentCode      EAS_EXMM_SUBJECTPLAN.SEGMENTCODE  %type :=i_PlanUseOrgCode;  --- ���Լƻ���ʹ�õ�λ
 v_iOperater         EAS_EXMM_SUBJECTPLAN.MAINTAINER %type :=i_Maintainer;
 v_iOperateType      number :=i_OperateType;                        ----1����ʼ�� 2��������ʼ��
 
 v_objExamPlan ExamPlan:=EXAMPLAN(v_iExamPlanCodeSN,v_iSegmentCode,v_iExamCategoryCodeSN); -- ���Լƻ�����
 v_objExamTime ExamTime ; -- �������ڷ�Χ����
 ------����ʱ������
 v_arrSessionUnit PK_EXMM.SessionUnit_Array;
  --������������
 v_arrExamDate    PK_EXMM.ExamDate_array;
 v_beginNumber      number ; -- ʱ�䵥Ԫ��ʼ����

 v_count             number;
 ------ ͨ��
 v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������
 v_StrTemp           varchar2(1000);

 BEGIN
 
    
      --- �жϿ��Զ���Ϳ������ �Ƿ�һ�� �� ������λ -----
        --PK_EXMM.PR_EXMM_GETEXAMPLANOBJ(v_iExamPlanCodeSN,v_iExamCategoryCodeSN,v_iSegmentCode,v_objExamPlan);
        dbms_output.put_line(v_objExamPlan.PlanCode||'~~'||v_objExamPlan.CateGoryCode||'~~~~'||v_iSegmentCode||'~'||v_objExamPlan.PlanUseOrgType);
        if v_objExamPlan.ErrorCode=1 then 
         v_Continue := 'A';
         dbms_output.put_line('�������󣺿��Զ������ݲ�����');
         goto IsContinue;
        end if;
        
        if v_objExamPlan.PlanUseOrgType=1 then 
         v_Continue := 'A1';
         dbms_output.put_line('�������󣺵�ǰʹ�õ�Ԫ���Ƿֲ�');
         goto IsContinue;
        end if;
        
     
       if v_objExamPlan.IsApply=1 then 
         v_Continue := 'A2';
         dbms_output.put_line('�������󣺿��Զ����Ѿ��·�');
         goto IsContinue;
        end if;
        
         if v_objExamPlan.PlanMakeOrgType=1 and  v_objExamPlan.ExamSessionUnitMode=2 then
          v_Continue :='A3';
         dbms_output.put_line('���������ܲ��ƻ��»��ŷ�ʽ�����д���');
         goto IsContinue;
        end if ;   
        --goto IsContinue;  
          ---�ƻ�ֽ�����Լƻ��·����м�¼�ж�
         /* 
        if v_objExamPlan.IsInPlanPub=0  then
          v_Continue :='B1';
         dbms_output.put_line('��ʼ������B1���ϸ񣺼ƻ�ֽ�����Լƻ��·����޼�¼');
         goto IsContinue;
        end if ;
        ---�ƻ�ֽ������ʱ���·����м�¼�ж�
        if v_objExamPlan.IsInDetailPub=0  then
          v_Continue :='B2';
         dbms_output.put_line('��ʼ������B2���ϸ�-�ƻ�ֽ������ʱ���·����޼�¼');
         goto IsContinue;
        end if ;
        
        ---�ƻ�ֽ������ʱ���·����м�¼�ж�
        if v_objExamPlan.IsInDetailPub=0  then
          v_Continue :='B2';
         dbms_output.put_line('��ʼ������B2���ϸ�-�ƻ�ֽ������ʱ���·����޼�¼');
         goto IsContinue;
        end if ;
        */
          --B: �жϼƻ������γ��Ծ���뿪����Ŀ�Ծ���Ƿ���ȫ��ͬ
        PK_EXMM.PR_EXMM_COMPAREPAPER(v_objExamPlan.PlanCode,v_objExamPlan.CateGoryCode,v_iSegmentCode,v_count);
        
        if v_count<>1 then
          v_Continue :='C';
         dbms_output.put_line('��ʼ������C���ϸ񣺼ƻ�������Ŀ�뿪����Ŀ����ͬ');
         goto IsContinue;
        end if ;     

       --E: �жϣ��ƻ�����ʱ�����Ƿ��ж�Ӧ��¼
        if v_objExamPlan.IsInDetailPub =0  then
          v_Continue :='E1';
         dbms_output.put_line('�ƻ�����ʱ���������');
         goto IsContinue;
        end if ;
      
         --D: �жϣ������ʼ����ʱ�䵥Ԫ���ű�Ӧ��Ϊ�� ����������ʱ�䰲�ű�Ӧ��Ϊ��
         ----ȡʱ�����ö���
         
        PK_EXMM.PR_EXMM_GETEXAMTIMEOBJ(v_objExamPlan.PlanCode, v_objExamPlan.CateGoryCode, v_iSegmentCode,2, v_objExamTime);
        
        dbms_output.put_line(v_objExamTime.BEGINNUMBER||'~'||v_objExamTime.ExistEndDate);
        ----D�� ���Ż��Ŵ�����ʼʱ�䵥Ԫ������
           --�ܲ��ƶ��ļƻ� ����
        if v_objExamPlan.PlanMakeOrgType=1 and v_objExamPlan.ExamSessionUnitMode=1 then
        --- ��ʼ������
          if v_iOperateType=1 then 
              if  v_objExamTime.SegmentBeginNumber>0 then
                  v_Continue :='D1';
                   dbms_output.put_line('��ʼ������D1���ϸ񣺷��Ų�����ʼ���Ѿ���ɡ�');
                  goto IsContinue;
              else
                 v_beginnumber:=v_objExamTime.BEGINNUMBER; --��ʼ������ȡ�ܲ������Ԫ
              end if;
          else  -- ��������
              if  v_objExamTime.SegmentBeginNumber=0 then
                  v_Continue :='D2';
                   dbms_output.put_line('��ʼ������D2���ϸ񣺷��Ų�������û�н��г�ʼ�����ܴ�������������');
                  goto IsContinue;
              else
                 v_beginnumber:=v_objExamTime.SegmentBeginNumber;
              end if;
          end if;
        end if ;
        
        if v_objExamPlan.PlanMakeOrgType=2 then
          if v_iOperateType=1 then
            if v_objExamTime.SegmentBeginNumber>0 then
              v_Continue :='D3';
             dbms_output.put_line('��ʼ������D3���ϸ񣺷ֲ��ƻ�����ʼ������ʱ�Ѿ���ʱ�䵥Ԫ��¼');
             goto IsContinue;
            else
              v_beginnumber:=0;
            end if ;     
          else  -- ��������
             if v_objExamTime.SegmentBeginNumber =0 then
               v_Continue :='D4';
               dbms_output.put_line('������������D4���ϸ���������ʱû��ʱ�䵥Ԫ��¼');
               goto IsContinue;
             else
               v_beginnumber :=v_objExamTime.SegmentBeginNumber; 
             end if ; 
          end if ; 
        end if ;
        --F:���쿼�����ںͿ���ʱ������
        dbms_output.put_line('�ƻ�����ʱ��'||v_objExamTime.NewBeginDate||'~'||v_objExamTime.NewEndDate||'~'||v_objExamTime.ExistBeginDate||'~'||v_objExamTime.ExistEndDate);
        --goto IsContinue;
        
         --���ؿ������� i_Operate 1 ֻʹ����ʱ��� 2 ʹ����չʱ���
           --F:���쿼�����ںͿ���ʱ������ ʱ�䵥Ԫ������λΪ�ֲ�ʱ��Ϊ��ʼ������ ��ʹ�ò���1���������ʹ����չʱ�䵥Ԫ��
        if v_objExamPlan.PlanMakeOrgType=2  and  v_iOperateType=1  then
           PK_EXMM.PR_EXMM_GETEXAMDATELIST(v_objExamTime.NewBeginDate,v_objExamTime.NewEndDate,v_objExamTime.ExistBeginDate,v_objExamTime.ExistEndDate,1,v_arrExamDate);
        else
           PK_EXMM.PR_EXMM_GETEXAMDATELIST(v_objExamTime.NewBeginDate,v_objExamTime.NewEndDate,v_objExamTime.ExistBeginDate,v_objExamTime.ExistEndDate,2,v_arrExamDate);
        end if ;
 
       --- i_planSN ���Զ���SN  i_SegmentCode �ֲ�����  i_tbFrom ��1����2�·���ȡ���� arrRet ���ض�Ӧ�Ŀ��Կ�ʼʱ����
       PK_EXMM.PR_EXMM_GETSESSIONUNIT(v_iExamPlanCodeSN, v_objExamPlan.CateGoryCode, v_iSegmentCode, 2, v_arrSessionUnit);
        
   <<IsContinue>>
    
     if v_Continue='OK' then
    
      for i in 1..v_arrExamDate.Count
        Loop
          --dbms_output.put_line(v_arrExamDate(i));
          
          for j in 1..v_objExamTime.PARTSNUM
          loop
            dbms_output.put_line(v_arrExamDate(i)||'~'||v_arrSessionUnit(j)||'~' || to_char((v_objExamTime.BEGINNUMBER+(i-1)*v_objExamTime.PARTSNUM+j),'fm099'));
              v_StrTemp := to_char((v_objExamTime.BEGINNUMBER+(i-1)*v_objExamTime.PARTSNUM+j),'fm099');
              insert into eas_exmm_examsessionplan(sn      ,segmentcode    ,examplancode         ,examcategorycode,examsessionunit ,examdate,remark,exambegintime,examtimelength,createorgcode,maintainer,maintaindate)
                     select seq_ExmM_ExamSessionUnit.nextval,v_iSegmentCode,v_objExamPlan.PlanCode,v_objExamPlan.CateGoryCode,v_StrTemp,v_arrExamDate(i),null,v_arrSessionUnit(j),null,v_objExamPlan.PlanMakeOrgCode,v_iOperater,sysdate
                     from dual 
                     where not  exists(select * from eas_exmm_examsessionplan  where examsessionunit=v_StrTemp and EXAMPLANCODE =v_objExamPlan.PlanCode 
                     and EXAMCATEGORYCODE =v_objExamPlan.CateGoryCode and SEGMENTCODE =v_iSegmentCode);
          end loop;
          
        End Loop;
    
     end if ;
    
    RETCODE :=v_Continue;
    dbms_output.put_line( 'returnCode:' || RETCODE );
    if RETCODE='OK' then
        commit;
    end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
  END  PR_EXMM_DEALSESSIONUNIT2;
  
  ------����ָ���ֲ��������ܲ��ļƻ�������Ŀ ��귽ʽ
  Function FN_Exmm_Get010Paper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList
  IS
  PaperList t_PaperList :=t_PaperList();
  cursor cur_1 is 
   
     with paperlist as (select distinct  a.sn,A.EXAMCATEGORYCODE ,C.TCPCODE ,C.COURSEID,a.ExamPapercode,A.ALLOWMAKEEXAMSESSION ,A.ALLOWMAKEPAPER,d.openedsemester   
          from eas_exmm_subjectplan a inner join eas_exmm_examcourseplanlist b on A.EXAMPAPERCODE =B.EXAMPAPERCODE 
       inner join eas_exmm_examcourseplan c on b.sn=c.sn and A.EXAMCATEGORYCODE =C.EXAMCATEGORYCODE and A.EXAMPLANCODE =C.EXAMPLANCODE and A.SEGMENTCODE =C.SEGMENTCODE
       inner join  eas_tcp_modulecourses d on c.tcpcode=d.tcpcode and c.courseid=d.courseid
        where a.examplancode=i_ExamPlanCode and a.segmentcode='010' )
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE ='010' and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=i_SegmentCode)
         )
        ,tcp2 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=i_SegmentCode
         where a2.segmentcode=i_SegmentCode and   A2.EXAMPLANCODE =i_ExamPlanCode    )
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp010 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          union  
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp2 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid;    
  
   
   cur_1_info cur_1%rowtype;
  begin
     open cur_1;
     loop
       Fetch cur_1 into cur_1_info;
       Exit when cur_1%notfound;
        PaperList.extend();
       PaperList(PaperList.count):=R_PaperList(cur_1_info.sn,cur_1_info.examcategorycode,cur_1_info.exampapercode,cur_1_info.ALLOWMAKEEXAMSESSION,cur_1_info.ALLOWMAKEPAPER);
     end loop;
       
     return PaperList;
  Exception
       when others then
          close cur_1;
      if cur_1%isopen then
        close cur_1;
      end if ;
  End ;
  
   ------����ָ���ֲ��������ܲ��ļƻ�������Ŀ ��귽ʽ
  Function FN_Exmm_Get010Paper2(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList
  IS
  PaperList t_PaperList :=t_PaperList();
 
  BEGIN
   
    for v_r in (
      with paperlist as (select distinct  a.sn,A.EXAMCATEGORYCODE ,C.TCPCODE ,C.COURSEID,a.ExamPapercode,A.ALLOWMAKEEXAMSESSION ,A.ALLOWMAKEPAPER,d.openedsemester   
          from eas_exmm_subjectplan a inner join eas_exmm_examcourseplanlist b on A.EXAMPAPERCODE =B.EXAMPAPERCODE 
       inner join eas_exmm_examcourseplan c on b.sn=c.sn and A.EXAMCATEGORYCODE =C.EXAMCATEGORYCODE and A.EXAMPLANCODE =C.EXAMPLANCODE and A.SEGMENTCODE =C.SEGMENTCODE
       inner join  eas_tcp_modulecourses d on c.tcpcode=d.tcpcode and c.courseid=d.courseid
        where a.examplancode=i_ExamPlanCode and a.segmentcode='010' )
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE ='010' and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=i_SegmentCode)
         )
        ,tcp2 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=i_SegmentCode
         where a2.segmentcode=i_SegmentCode and   A2.EXAMPLANCODE =i_ExamPlanCode    )
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp010 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          union  
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp2 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid    
  )

    
     loop
       
        PaperList.extend();
        PaperList(PaperList.count):=R_PaperList(v_r.sn,v_r.examcategorycode,v_r.exampapercode,v_r.ALLOWMAKEEXAMSESSION,v_r.ALLOWMAKEPAPER);
     end loop;
       
     return PaperList;
  
  End ;
  
  Function FN_Exmm_GetExecSegmentPaper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList
  IS
    PaperList t_PaperList :=t_PaperList();
    v_ScourceCode EAS_ORG_BASICINFO.ORGANIZATIONCODE  %type:=i_SegmentCode;
    v_LearnCode EAS_ORG_BASICINFO.ORGANIZATIONCODE  %type  ;
    v_SegCode EAS_ORG_BASICINFO.ORGANIZATIONCODE  %type  ;
 
  BEGIN
  
     v_LearnCode := v_ScourceCode;
     v_SegCode   := substr(v_ScourceCode,1,3);
     
     for v_r in ( 
       with paperlist as (select distinct  a.sn,A.EXAMCATEGORYCODE ,C.TCPCODE ,C.COURSEID,a.ExamPapercode,A.ALLOWMAKEEXAMSESSION ,A.ALLOWMAKEPAPER,d.openedsemester   
          from eas_exmm_subjectplan a inner join eas_exmm_examcourseplanlist b on A.EXAMPAPERCODE =B.EXAMPAPERCODE 
       inner join eas_exmm_examcourseplan c on b.sn=c.sn and A.EXAMCATEGORYCODE =C.EXAMCATEGORYCODE and A.EXAMPLANCODE =C.EXAMPLANCODE and A.SEGMENTCODE =C.SEGMENTCODE
       inner join  eas_tcp_modulecourses d on c.tcpcode=d.tcpcode and c.courseid=d.courseid
        where a.examplancode=i_ExamPlanCode and a.segmentcode=v_SegCode )--and a.exampapercode='1200'
        ----ͬһרҵ������ָ������
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE = v_SegCode and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=v_SegCode)
         )
         
         -- ʵʩ����
        ,tcp2 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode= v_SegCode and D2.COURSENATURE <>'3'
         where a2.segmentcode=v_SegCode and   A2.EXAMPLANCODE =i_ExamPlanCode    )
       ,tcp3 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=v_SegCode and D2.COURSENATURE ='3'
         inner join Eas_tcp_execmodulecourse d3 on c2.tcpcode=d3.tcpcode and c2.courseid=d3.courseid and d3.segmentcode=v_SegCode and D3.LEARNINGCENTERCODE = v_LearnCode
         where a2.segmentcode=v_SegCode and   A2.EXAMPLANCODE =i_ExamPlanCode    ) 
         
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp010 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          union  
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp2 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid    
          union 
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp3 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          
    )
      loop
       
        PaperList.extend();
        PaperList(PaperList.count):=R_PaperList(v_r.sn,v_r.examcategorycode,v_r.exampapercode,v_r.ALLOWMAKEEXAMSESSION,v_r.ALLOWMAKEPAPER);
     end loop; 
       
     return PaperList;
  
  End ;


Function FN_Exmm_GetExecPaper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList
  IS
    PaperList t_PaperList :=t_PaperList();
    v_ScourceCode EAS_ORG_BASICINFO.ORGANIZATIONCODE  %type:=i_SegmentCode;
    v_LearnCode EAS_ORG_BASICINFO.ORGANIZATIONCODE  %type  ;
    v_SegCode EAS_ORG_BASICINFO.ORGANIZATIONCODE  %type  ;
 
  BEGIN
  
   if length(v_ScourceCode)>3 then
     v_LearnCode := v_ScourceCode;
     v_SegCode   := substr(v_ScourceCode,1,3);
     
     for v_r in ( 
       with paperlist as (select distinct  a.sn,A.EXAMCATEGORYCODE ,C.TCPCODE ,C.COURSEID,a.ExamPapercode,A.ALLOWMAKEEXAMSESSION ,A.ALLOWMAKEPAPER,d.openedsemester   
          from eas_exmm_subjectplan a inner join eas_exmm_examcourseplanlist b on A.EXAMPAPERCODE =B.EXAMPAPERCODE 
       inner join eas_exmm_examcourseplan c on b.sn=c.sn and A.EXAMCATEGORYCODE =C.EXAMCATEGORYCODE and A.EXAMPLANCODE =C.EXAMPLANCODE and A.SEGMENTCODE =C.SEGMENTCODE
       inner join  eas_tcp_modulecourses d on c.tcpcode=d.tcpcode and c.courseid=d.courseid
        where a.examplancode=i_ExamPlanCode and a.segmentcode='010' )--and a.exampapercode='1200'
        ----ͬһרҵ������ָ������
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE ='010' and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=v_SegCode)
         )
         
         -- ʵʩ����
        ,tcp2 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=v_SegCode and D2.COURSENATURE <>'3'
         where a2.segmentcode=v_SegCode and   A2.EXAMPLANCODE =i_ExamPlanCode    )
       ,tcp3 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=v_SegCode and D2.COURSENATURE ='3'
         inner join Eas_tcp_execmodulecourse d3 on c2.tcpcode=d3.tcpcode and c2.courseid=d3.courseid and d3.segmentcode=v_SegCode and D3.LEARNINGCENTERCODE = v_LearnCode
         where a2.segmentcode=v_SegCode and   A2.EXAMPLANCODE =i_ExamPlanCode    ) 
         
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp010 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          union  
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp2 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid    
          union 
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp3 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          
    )
      loop
       
        PaperList.extend();
        PaperList(PaperList.count):=R_PaperList(v_r.sn,v_r.examcategorycode,v_r.exampapercode,v_r.ALLOWMAKEEXAMSESSION,v_r.ALLOWMAKEPAPER);
     end loop;
     
   else 
    
     v_SegCode   := v_ScourceCode;
     
     for v_r in ( 
      with paperlist as (select distinct  a.sn,A.EXAMCATEGORYCODE ,C.TCPCODE ,C.COURSEID,a.ExamPapercode,A.ALLOWMAKEEXAMSESSION ,A.ALLOWMAKEPAPER,d.openedsemester   
          from eas_exmm_subjectplan a inner join eas_exmm_examcourseplanlist b on A.EXAMPAPERCODE =B.EXAMPAPERCODE 
       inner join eas_exmm_examcourseplan c on b.sn=c.sn and A.EXAMCATEGORYCODE =C.EXAMCATEGORYCODE and A.EXAMPLANCODE =C.EXAMPLANCODE and A.SEGMENTCODE =C.SEGMENTCODE
       inner join  eas_tcp_modulecourses d on c.tcpcode=d.tcpcode and c.courseid=d.courseid
        where a.examplancode=i_ExamPlanCode and a.segmentcode='010' )--and a.exampapercode='1200'
        ----ͬһרҵ������ָ������
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE ='010' and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=v_SegCode)
         )
         
         -- ʵʩ����
        ,tcp2 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=v_SegCode and D2.COURSENATURE <>'3'
         where a2.segmentcode=v_SegCode and   A2.EXAMPLANCODE =i_ExamPlanCode    )
       ,tcp3 as (  
        select A2.TCPCODE ,C2.COURSEID ,C2.COURSENATURE,b2.semester,A2.USESEMESTER    from EAS_ExmM_ExamGuidance a2 inner join eas_exmm_bin2semester b2 on a2.usesemester=B2.BINSEMESTER 
         inner join eas_tcp_modulecourses c2 on a2.tcpcode=C2.TCPCODE and B2.SEMESTER =C2.OPENEDSEMESTER   
         inner join EAS_TCP_ImplModuleCourse d2 on c2.tcpcode=d2.tcpcode and c2.courseid=d2.courseid and d2.segmentcode=v_SegCode and D2.COURSENATURE ='3'
         inner join Eas_tcp_execmodulecourse d3 on c2.tcpcode=d3.tcpcode and c2.courseid=d3.courseid and d3.segmentcode=v_SegCode 
         where a2.segmentcode=v_SegCode and   A2.EXAMPLANCODE =i_ExamPlanCode    ) 
         
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp010 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          union  
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp2 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid    
          union 
        select sa.sn,sa.examcategorycode,sa.exampapercode ,sa.ALLOWMAKEEXAMSESSION,sa.ALLOWMAKEPAPER from paperlist sa inner join tcp3 sb on sa.tcpcode=sb.tcpcode and sa.courseid=sb.courseid
          
    )
  loop
       
        PaperList.extend();
        PaperList(PaperList.count):=R_PaperList(v_r.sn,v_r.examcategorycode,v_r.exampapercode,v_r.ALLOWMAKEEXAMSESSION,v_r.ALLOWMAKEPAPER);
     end loop;
     
    end if ;
   
   
       
     return PaperList;
  
  End ;
  
  
  PROCEDURE PR_EXMM_CLEARSESSIONUNIT(i_MAINTAINER IN varchar2,I_EXAMPLANSN NUMBER,I_EXAMCATEGORYCODE VARCHAR2,I_SEGMENTCODE VARCHAR2 ,RETCODE OUT varchar2) IS
  
 v_iExamPlanSN EAS_ExmM_PaperExamPlanPub.SN  %type :=I_EXAMPLANSN ;
 v_iExamCategoryCode EAS_EXMM_EXAMCATEGORY.EXAMCATEGORYCODE  %type:=I_EXAMCATEGORYCODE;
 v_iSegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=I_SEGMENTCODE;
 v_iOperater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_MAINTAINER;  --������   
 v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������
 v_OrgType number;
 Type ExamPlan is Record
 ( 
   ExamPlanCode varchar2(20),
   IsPublish  number
 );
   v_ExamPlan_source ExamPlan ;
  
   
 BEGIN
      
  select A.ORGANIZATIONTYPE into v_OrgType from EAS_ORG_BASICINFO a where A.ORGANIZATIONCODE =v_iSegmentCode;
   if v_OrgType>2 then
      v_Continue := 'F';
      dbms_output.put_line('��λ���Ͳ���ȷ'); 
      goto IsContinue;
   end if ;
 
  if v_OrgType=2 then 
    if exists2('select * from EAS_ExmM_PaperExamPlanPub a where A.SN ='||v_iExamPlanSN||' and A.SEGMENTCODE ='''||v_iSegmentCode||'''')=1 then
         with tbdef as ( select a.ExamPlanCode,a.IsPublish from EAS_ExmM_PaperExamPlanPub a where A.SN =v_iExamPlanSN and A.SEGMENTCODE =v_iSegmentCode ) 
         select  ExamPlanCode,IsPublish into v_Examplan_Source from tbdef ;
    else
         v_Continue := 'A0';
        dbms_output.put_line('�ƻ�ֽ�����Լƻ��·����޼�¼'); 
      goto IsContinue;
    end if;
  end if ; 
   if v_OrgType=1 then 
        if exists2('select * from EAS_ExmM_definition a where A.SN ='||v_iExamPlanSN||' and A.CreateOrgCode ='''||v_iSegmentCode||'''')=1 then
             with tbdef as ( select a.ExamPlanCode,a.IsApply from EAS_ExmM_definition a where A.SN =v_iExamPlanSN and A.CreateOrgCode =v_iSegmentCode ) 
             select  ExamPlanCode,IsApply into v_Examplan_Source from tbdef ;
        else
             v_Continue := 'A1';
            dbms_output.put_line('�ƻ�ֽ�����Լƻ��޼�¼'); 
          goto IsContinue;
       end if;
   end if ;
   --goto IsContinue;
   --a)   ״̬Ϊ���ѷ���������ɾ�����ɹ�������������ʾ
   if  v_Examplan_Source.IsPublish=1  then
    v_Continue := 'A2';
      dbms_output.put_line('�˿��Զ�������Ѿ������������޸�'); 
      goto IsContinue;
   end if;
   
   
   
    <<IsContinue>>
    
     if v_Continue='OK' then
      ----- ִ�м̳в���
        -----���±��ֲ��� 
        update EAS_ExmM_SubjectPlan a set ExamSessionUnit=null,Maintainer=v_iOperater,Maintaindate=sysdate,ArrangeState='2'
        where A.EXAMPLANCODE =v_Examplan_Source.examplancode and A.EXAMCATEGORYCODE =v_iExamCategoryCode and a.segmentcode=v_iSegmentCode;
        v_Continue := SQL%ROWCOUNT;
      dbms_output.put_line('EAS_EXMM_SUBJECTPLAN Ӱ���¼����' || SQL%ROWCOUNT);
      ----- ���¿������ܲ���
      if v_OrgType=2 then 
      for v_r in (
         select a.* from EAS_ExmM_SubjectPlan a  where A.ALLOWMAKEEXAMSESSION =1 and A.EXAMPLANCODE =v_Examplan_Source.examplancode and A.EXAMCATEGORYCODE =v_iExamCategoryCode
       and exists(select * from table(PK_EXMM.FN_Exmm_Get010Paper2(v_Examplan_Source.examplancode,v_iSegmentCode)) where sn=a.sn))
       loop
         dbms_output.put_line('��ǰ���ؽ����'|| v_r.sn);
         update EAS_ExmM_SubjectPlan  set ExamSessionUnit=null,Maintainer=v_iOperater,Maintaindate=sysdate,ArrangeState='2'
         where sn=v_r.sn;
       
       end loop; 
      end if; 
     else
     
       dbms_output.put_line(v_Continue);   
     end if ;
     
    RETCODE :=v_Continue;
    dbms_output.put_line( 'returnCode:' || RETCODE );
    if RETCODE='OK' then
        commit;
    end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
    
 END PR_EXMM_CLEARSESSIONUNIT;  
 
 
 
 PROCEDURE PR_EXMM_INHERITSESSIONUNIT(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSNSOURCE IN number,i_EXAMCATEGORYTCODESOURCE IN varchar2,i_EXAMPLANSNTARGET IN number,i_EXAMCATEGORYTCODETARGET IN varchar2,RETCODE OUT varchar2) AS
 
 v_iExamPlanSNSource EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSNSOURCE ;
 v_iExamCategoryCodeSource EAS_EXMM_EXAMCATEGORY.EXAMCATEGORYCODE  %type:=i_EXAMCATEGORYTCODESOURCE;
 v_iExamPlanSNTarget EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSNTARGET;
 v_iExamCategoryCodeTarget EAS_EXMM_EXAMCATEGORY.EXAMCATEGORYCODE  %type:=i_EXAMCATEGORYTCODETARGET;
 v_iSegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
 
 v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������
 
 v_cnt1 number;      ---��¼������Դ�ƻ��еĿ�Ŀ����
 v_cnt2 number;      ---��¼�Ѿ����ŵĿ�Ŀ����
   
   v_objExamPlan_Source ExamPlan:=Examplan(v_iExamPlanSNSource,v_iSegmentCode);
   v_objExamPlan_Target ExamPlan:=Examplan(v_iExamPlanSNTarget,v_iSegmentCode);
   
 BEGIN
   dbms_output.put_line(v_objExamPlan_Source.plancode ||'-'||v_objExamPlan_Source.isapply||'-'||v_objExamPlan_Source.ExamType); 
   dbms_output.put_line(v_objExamPlan_Target.plancode ||'-'||v_objExamPlan_Target.isapply||'-'||v_objExamPlan_Target.ExamType);
  -- end;
  --d)    ���ѡ���Դ����������Ŀ�꿼�����ƣ�������ͬ����������ɹ�����ʾ������Ϣ
    if v_iExamPlanSNSource=v_iExamPlanSNTarget then
    v_Continue := 'D';
      dbms_output.put_line('Դ����������Ŀ�꿼�����ƣ�������ͬ'); 
      goto IsContinue;
   end if;
   
  ----e)    ������Զ����ѷ��������ܲ���
   if v_objExamplan_Target.IsApply=1 then
    v_Continue := 'E';
      dbms_output.put_line('Ŀ�꿼�Լƻ��ѷ���'); 
      goto IsContinue;
   end if;
   --b)    ������Դ���Զ����Ŀ�꿼�Զ���Ŀ�����ʽ��ͬ����̳в��ɹ�
   if v_objExamplan_Target.ExamType<>v_objExamplan_Source.ExamType then
    v_Continue := 'B';
      dbms_output.put_line('������ʽ'); 
      goto IsContinue;
   end if;
   
    --a)    ���Դ���Զ����Ŀ�꿼�Զ����У������ڼƻ�������Ŀ����������ɹ�����ʾ������Ϣ
     with subjectSource as (select exampapercode from  eas_exmm_subjectplan where examplancode=v_objExamPlan_Source.plancode and segmentcode=v_iSegmentCode and examcategorycode=v_iExamCategoryCodeSource)
   , subjecttarget as ( select exampapercode,examsessionunit from  eas_exmm_subjectplan where examplancode=v_objExamPlan_Target.plancode and segmentcode=v_iSegmentCode and examcategorycode=v_iExamCategoryCodeTarget)
  select nvl(sum(case when b.exampapercode is null then 1 else 0 end),-1) cnt1,nvl(sum(case when a.examsessionunit is not null then 1 else 0 end),-1) as cnt2 
   into v_cnt1,v_cnt2
    from subjecttarget a left join subjectSource b on a.exampapercode=b.exampapercode;
 
   
   dbms_output.put_line(v_cnt1 ||'~'||v_cnt2);
   
   --goto IsContinue;
   
   if v_cnt1>0 or v_cnt2>0 or v_cnt1=-1 or v_cnt2=-1 then
    v_Continue := 'A';
      dbms_output.put_line('�����ϼ̳й����2��'); 
      goto IsContinue;
   end if;
   
       
    <<IsContinue>>
    
     if v_Continue='OK' then
      ----- ִ�м̳в���
        
      update eas_exmm_subjectplan a set (examsessionunit,maintainer,maintainDate)=(select examsessionunit,i_Maintainer,sysdate from eas_exmm_subjectplan where exampapercode=a.exampapercode and examcategorycode=a.examcategorycode and examplancode=v_objExamplan_Source.plancode and segmentcode=v_iSegmentCode)
      where A.EXAMPLANCODE =v_objExamplan_Target.plancode and A.EXAMCATEGORYCODE =v_iExamCategoryCodeTarget and a.segmentcode=v_iSegmentCode;
      dbms_output.put_line('EAS_EXMM_SUBJECTPLAN Ӱ���¼����' || SQL%ROWCOUNT);
          
     else
     
       dbms_output.put_line(v_Continue);   
     end if ;
       
    RETCODE :=v_Continue;
    dbms_output.put_line( 'returnCode:' || RETCODE );
    if RETCODE='OK' then
        commit;
    end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
 END PR_EXMM_INHERITSESSIONUNIT;
 
 procedure PR_GetPlan(i_PlanSN IN number,i_SegmentCode IN varchar2 ,objPlan out EXAMPLAN) IS
 v_iExamPlanSN EAS_EXMM_DEFINITION.SN %type :=i_PlanSN ;
 v_iSegmentCode varchar2(30) :=i_SegmentCode;

 BEGIN
  objPlan := EXAMPLAN(v_iExamPlanSN,v_iSegmentCode);
 
 END PR_GetPlan;
 
 
 
 
     
  --�̳п��Կ�Ŀ����
   --�ɹ�����OK�����򷵻ش�����Ϣ�У�
     -- 1 �쳣��EXCEPTION 
     -- 2: a Դ���Զ����У������ڿ��Կ�Ŀ�ɼ��ϳɱ�����Ϣ
     --3: b û�л����һ��Ŀ��רҵ����
     --4:e �����Ѿ��·�,�����Զ�����
     
     PROCEDURE PR_EXMM_INHERITXKSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2) IS
         v_ExamPlanSNSource EAS_EXMM_DEFINITION.SN %type       :=i_EXAMPLANSN_SOURCE ;
         v_ExamCategorySNSource EAS_EXMM_EXAMCATEGORY.SN %type :=i_EXAMCATEGORYSN_SOURCE;
         v_ExamPlanSNTarget EAS_EXMM_DEFINITION.SN %type       :=i_EXAMPLANSN_TARGET ;
         v_ExamCategorySNTarget EAS_EXMM_EXAMCATEGORY.SN %type :=i_EXAMCATEGORYSN_TARGET;
         v_SegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type:=i_SEGMENTCODE;
         v_Operater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_Maintainer;
 -------------------------
    v_Rows              number;
    v_Maintaindate      date;
    v_Continue         varchar2(1000) :='OK'; ---�ж������Ƿ����OK���� �����ַ�������ֲ��������� ������ 
    v_ExamPlanSource ExamPlan :=Examplan(v_ExamPlanSNSource,v_SegmentCode,v_ExamCategorySNSource); ----���Լƻ�����
    v_ExamPlanTarget ExamPlan :=Examplan(v_ExamPlanSNTarget,v_SegmentCode,v_ExamCategorySNTarget); ----���Լƻ�����
  
 BEGIN
 ----�ж����������Զ����Ƿ��Ѿ����� -----
  --   if v_ExamPlanTarget.IsApply=1 then
  --      v_Continue := 'e';
  --     dbms_output.put_line('��������Ѿ��·�,�����Զ�����'); 
  --     goto IsContinue;
  --   end if;
 
    if v_ExamPlanSource.ExamType<>v_ExamPlanTarget.ExamType then
        v_Continue := 'b';
       dbms_output.put_line('ԭ������Ŀ�궨����ͬ�򿼺���ʽ��ͬ'); 
       goto IsContinue;
     end if;
      select count(*) into v_Rows from EAS_ExmM_SubjectPlan a inner join 
     EAS_ExmM_XKStandardPlan b on a.sn=B.SUBJECTPLAN_SN 
     where a.examplancode=v_ExamPlanSource.plancode and a.examcategorycode=v_ExamPlanSource.CateGoryCode and a.segmentcode=v_SegmentCode;
     
     if v_Rows=0 then
        v_Continue := 'a';
       dbms_output.put_line('Դ���Զ����У������ڿ��Կ�Ŀ�ɼ��ϳɱ�����Ϣ'); 
       goto IsContinue;
     end if;
    
       <<IsContinue>> 
     if v_Continue='OK' then
     
       v_Maintaindate :=sysdate; 
     ---- ��ʼ�̳�
     merge into EAS_ExmM_XKStandardPlan aa
     using (
        with t1 as ( select a.sn,a.exampapercode,b.sn as xksn from EAS_ExmM_SubjectPlan a inner join 
         EAS_ExmM_XKStandardPlan b on a.sn=B.SUBJECTPLAN_SN 
           where a.examplancode=v_ExamPlanSource.plancode and a.examcategorycode=v_ExamPlanSource.CateGoryCode and a.segmentcode=v_SegmentCode) --Դ
           ,t2 as (select a.sn,a.exampapercode,A.EXAMPLANCODE  from EAS_ExmM_SubjectPlan a where a.examplancode=v_ExamPlanTarget.plancode and a.examcategorycode=v_ExamPlanTarget.CateGoryCode and a.segmentcode=v_SegmentCode)
           select t2.sn as SubjectPlan_SN,nvl(B.SEGMENTCODE,'1') SEGMENTCODE, nvl(B.COLLEGECODE,'1') COLLEGECODE ,nvl(B.LEARNINGCENTERCODE,'1') LEARNINGCENTERCODE ,t2.examplancode,t2.exampapercode,B.EXAMCATEGORYCODE,B.TOTALSCORE 
           ,B.PAPERSCALE ,B.XKSCALE ,B.MIDTERMSCALE ,B.ISXKSCOREPASS ,B.ISPAPERSCOREPASS ,t1.sn as maintainer,v_Maintaindate as MaintainDate,b.xk_sn
            from t1 inner join EAS_ExmM_XKStandardPlan b on t1.xksn=b.sn
           inner join t2 on t1.exampapercode=t2.exampapercode) bb
      on (aa.SubjectPlan_SN=bb.SubjectPlan_SN and nvl(aa.segmentcode,'1')=bb.segmentcode and nvl(aa.collegecode,'1')=bb.collegecode and nvl(aa.learningcentercode,'1')=bb.learningcentercode)
      WHEN NOT MATCHED THEN
           insert (
            sn,SubjectPlan_SN,SEGMENTCODE , COLLEGECODE ,LEARNINGCENTERCODE ,examplancode,exampapercode,EXAMCATEGORYCODE,TOTALSCORE 
           ,PAPERSCALE ,XKSCALE ,MIDTERMSCALE ,ISXKSCOREPASS ,ISPAPERSCOREPASS ,maintainer,MaintainDate,xk_sn)
           values( seq_ExmM_XKSubjectPlan.nextval,bb.SubjectPlan_SN,bb.segmentcode,bb.collegecode,bb.learningcentercode,bb.examplancode,bb.exampapercode,bb.examcategorycode,bb.totalscore
           ,bb.paperscale,bb.xkscale,bb.midtermscale,bb.isxkscorepass,bb.ispaperscorepass,bb.maintainer,bb.MaintainDate,bb.xk_sn);
         
          dbms_output.put_line('insert  EAS_ExmM_XKStandardPlan' ||  SQL%ROWCOUNT);
       
           merge into EAS_ExmM_XKStandardPlanDetail aa
       using (
       with t1 as (select sn,to_number(maintainer) as SourceSN from EAS_ExmM_XKStandardPlan  where MaintainDate=v_Maintaindate)
       select t1.sn,B.ITEMCODE ,B.ITEMSCALE  from t1 inner join EAS_ExmM_XKStandardPlanDetail b on t1.sourceSn=B.SN) bb
       on (aa.sn=bb.sn)
       WHEN NOT MATCHED THEN
       insert (
        SN, ITEMCODE,ITEMSCALE)
        values(bb.sn,bb.ITEMCODE,bb.ITEMSCALE)  ;
       
         
          dbms_output.put_line('EAS_ExmM_XKStandardPlanDetail Ӱ���¼����' || SQL%ROWCOUNT);
     
     
     end if; 
    
     RETCODE :=v_Continue;
    
    dbms_output.put_line( 'returnCode' || RETCODE );
    commit; 
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
   
   END PR_EXMM_INHERITXKSUBJECTPLAN;
  
END PK_EXMM;
/

