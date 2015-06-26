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
  -- 自动建立或追加计划开考课程
  
 PROCEDURE PR_EXMM_BATCHADDEXAMCOURSEPLAN(i_MAINTAINER IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_OperateType IN number,RETCODE OUT varchar2) IS
    
     v_iExamPlanSN EAS_EXMM_DEFINITION.sn %type :=i_EXAMPLANSN ;
     v_iExamCategorySN EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYTSN;
     v_iSegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
     v_iOperater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_MAINTAINER;  --操作人  
     v_iOperateType number := i_OperateType; -- 1.建立 需要执行清空操作。 2 追加 只增加新的
----------------计划对象 
 
      v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续
      v_ExamPlan ExamPlan :=Examplan(v_iExamPlanSN,v_iSegmentCode,v_iExamCategorySN);   ----考试计划对象
 BEGIN
   ----判断考试定义是否已经发布 -----
  
      -- if v_ExamPlan.IsApply=1 then
      --  v_Continue := 'A';
      -- dbms_output.put_line('这个批次已经下发,不能自动建立'); 
       --goto IsContinue;
    -- end if;
    
    if v_iOperateType = 1 then
      ----当前操作为建立，通过级联删除完成对子表的删除--
      delete from EAS_ExmM_ExamCoursePlan where SegmentCode=v_iSegmentCode and  ExamPlanCode=v_ExamPlan.plancode and  ExamCategoryCode= v_ExamPlan.CateGoryCode ;
      dbms_output.put_line('建立 操作前删除总记录数' ||  SQL%ROWCOUNT); 
    end if;
    
    -----初始化考试类别
   
    
     <<IsContinue>> 
     if v_Continue='OK' then 
     ---- 开始创建
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
                      ,ta.batchcode,ta.modulecode,ta.courseid,ta.coursetype,ta.coursenature,ta.credit,ta.examunit,ta.ismutex,ta.isconversion,ta.rsn -- 使用替代课的SN
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
 
  --继承开考课程
   PROCEDURE PR_EXMM_INHERITEXAMCOURSEPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2) IS
       v_ExamPlanSNSource EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_SOURCE ;
       v_ExamCategorySNSource EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_SOURCE;
         v_ExamPlanSNTarget EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_TARGET ;
         v_ExamCategorySNTarget EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_TARGET;
         v_SegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
         v_Operater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_Maintainer;
 -------------------------
    v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续 
    v_ExamPlanSource ExamPlan :=Examplan(v_ExamPlanSNSource,v_SegmentCode,v_ExamCategorySNSource); ----考试计划对象
    v_ExamPlanTarget ExamPlan :=Examplan(v_ExamPlanSNTarget,v_SegmentCode,v_ExamCategorySNTarget); ----考试计划对象
 BEGIN
 ----判断条件：考试定义是否已经发布 -----
     
       if v_ExamPlanTarget.IsApply=1 then
         v_Continue := 'A';
        dbms_output.put_line('这个批次已经下发,不能自动建立'); 
        goto IsContinue;
       end if;
 
        if v_ExamPlanSource.ExamType<>v_ExamPlanTarget.ExamType then
            v_Continue := 'B';
           dbms_output.put_line('原定义与目标定义相同或考核形式不同'); 
           goto IsContinue;
         end if;
          
        <<IsContinue>> 
     if v_Continue='OK' then 
     ---- 开始继承
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
     RETCODE:='0,返回异常';
     rollback;
    
  END PR_EXMM_INHERITEXAMCOURSEPLAN;
 
 




  -- 自动建立或追加计划开考科目
  PROCEDURE PR_EXMM_BATCHADDSUBJECTPLAN(i_MAINTAINER IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_EXAMTIMELENGTH IN number ,i_OperateType IN number,RETCODE OUT varchar2 ) IS
    v_iExamPlanSN EAS_EXMM_DEFINITION.sn %type :=i_EXAMPLANSN;
     v_iExamCategorySN EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYTSN;
     v_iSegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
     v_iOperater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_MAINTAINER;  --操作人  
     v_iOperateType number := i_OperateType; -- 1.建立 需要执行清空操作。 2 追加 只增加新的
     v_iEXAMTIMELENGTH   EAS_EXMM_SUBJECTPLAN.EXAMTIMELENGTH %type :=i_EXAMTIMELENGTH;  --0表示不指定考试时长而使用默认值
      ----------------计划对象 
      v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续
     v_ExamPlan ExamPlan :=Examplan(v_iExamPlanSN,v_iSegmentCode,v_iExamCategorySN); ----考试计划对象
 BEGIN
 ----判断考试定义是否已经发布 -----
    dbms_output.put_line(v_Examplan.plancode ||'-'||v_Examplan.isapply||'-'||v_ExamPlan.CateGoryCode||'-'||v_ExamPlan.ExamType);
-- End;
  
      
    -- if v_ExamPlan.IsApply=1 then
    --    v_Continue := 'A';
    --   dbms_output.put_line('这个批次已经下发,不能自动建立'); 
    --   goto IsContinue;
    -- end if;
 
     if v_iOperateType = 1 then
      ----当前操作为建立，通过级联删除完成对子表的删除--
         delete from EAS_ExmM_SubjectPlan where SegmentCode=v_iSegmentCode and  ExamPlanCode=v_Examplan.plancode and  ExamCategoryCode= v_ExamPlan.CateGoryCode;
         dbms_output.put_line('建立 操作前删除总记录数' ||  SQL%ROWCOUNT); 
      end if;
      
      <<IsContinue>> 
      if v_Continue='OK' then 
     ---- 开始创建
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
      ------处理共用属性
      
      update EAS_EXMM_SUBJECTPLAN a  set (ASSESSMODE,ExamMode,ExamTools,ISUSEANSWERCARD,ISHAVESUBJECTIVE,ISUSECD,ISUSERANSWERTAB,EXAMTIMELENGTH)=(select 
      B.ASSESSMODE,b.ExamMode,b.EXAMTOOLS ,b.ISUSEANSWERCARD , b.ISHAVESUBJECTIVE,b.ISUSECD,b.ISUSERANSWERTAB,case when v_iEXAMTIMELENGTH=0 then b.EXAMTIMELENGTH else v_iEXAMTIMELENGTH end
        from EAS_EXMM_SUBJECT b where a.sharesn=b.sn   )
            where a.examplancode=v_Examplan.plancode and a.examcategorycode=v_ExamPlan.CateGoryCode and A.SEGMENTCODE =v_iSegmentCode and a.sharesn>0;

          dbms_output.put_line('共享科目修改：EAS_EXMM_SUBJECTPLAN 影响记录数：' || SQL%ROWCOUNT);   

     
     end if;
     
   
     RETCODE :=v_Continue;
   
    dbms_output.put_line( 'returnCode' || v_Continue );
    commit; 
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='0,返回异常';
     rollback;
  END PR_EXMM_BATCHADDSUBJECTPLAN;

 

  -- 继承计划开考科目
     PROCEDURE PR_EXMM_INHERITSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2) IS
      v_ExamPlanSNSource EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_SOURCE ;
       v_ExamCategorySNSource EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_SOURCE;
         v_ExamPlanSNTarget EAS_EXMM_DEFINITION.SN %type :=i_EXAMPLANSN_TARGET ;
         v_ExamCategorySNTarget EAS_EXMM_EXAMCATEGORY.SN %type:=i_EXAMCATEGORYSN_TARGET;
         v_SegmentCode  EAS_EXMM_DEFINITION.CREATEORGCODE %type :=i_SEGMENTCODE;
         v_Operater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_Maintainer;
 -------------------------
    v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续 
    v_ExamPlanSource ExamPlan :=Examplan(v_ExamPlanSNSource,v_SegmentCode,v_ExamCategorySNSource); ----考试计划对象
    v_ExamPlanTarget ExamPlan :=Examplan(v_ExamPlanSNTarget,v_SegmentCode,v_ExamCategorySNTarget); ----考试计划对象
  
 BEGIN
 ----判断条件：考试定义是否已经发布 -----
     if v_ExamPlanTarget.IsApply=1 then
        v_Continue := 'A';
       dbms_output.put_line('这个批次已经下发,不能自动建立'); 
       goto IsContinue;
     end if;
 
    if v_ExamPlanSource.ExamType<>v_ExamPlanTarget.ExamType then
        v_Continue := 'B';
       dbms_output.put_line('原定义与目标定义相同或考核形式不同'); 
       goto IsContinue;
     end if;
    
       <<IsContinue>> 
     if v_Continue='OK' then 
     ---- 开始继承
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
          dbms_output.put_line('EAS_EXMM_SUBJECTPLAN 影响记录数：' || v_Continue);
     
     
     end if; 
    
     RETCODE :=v_Continue;
    
    dbms_output.put_line( 'returnCode' || RETCODE );
    commit; 
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='0,返回异常';
     rollback;
   
   END PR_EXMM_INHERITSUBJECTPLAN;
  
  --返回时间单元数组
 PROCEDURE PR_EXMM_GETSESSIONUNIT(i_PlanSN number,i_CategoryCode varchar2, i_SegmentCode varchar2,i_tbFrom number,arrRet OUT SessionUnit_Array) IS
 arrSessionUnit SessionUnit_Array :=SessionUnit_Array('','','','','','','','');
 BEGIN
 --- 此处不进行是否记录存在的判断，所有的判断是主逻辑中进行
 -- i_planSN 考试定义SN  i_SegmentCode 分部代码  i_tbFrom 从1主表2下发表取数据 arrRet 返回对应的考试开始时间数据
  if i_tbFrom=1 then
              execute immediate 'select   Part1begin, Part2begin, Part3begin, Part4begin, Part5begin, Part6begin, Part7begin, Part8begin from eas_exmm_definitiondetail  where SN='||i_PlanSN||'and ExamCategoryCode='''||i_CategoryCode||'''' 
              into                          arrSessionUnit(1) ,arrSessionUnit(2),arrSessionUnit(3)  ,arrSessionUnit(4) ,arrSessionUnit(5)  ,arrSessionUnit(6),arrSessionUnit(7) ,arrSessionUnit(8);
  else
              execute immediate 'select   Part1begin, Part2begin, Part3begin, Part4begin, Part5begin, Part6begin, Part7begin, Part8begin from eas_exmm_definitiondetailPub  where SN='||i_PlanSN||' and Segmentcode='''||i_SegmentCode||'''and ExamCategoryCode='''||i_CategoryCode||''''
              into                          arrSessionUnit(1) ,arrSessionUnit(2),arrSessionUnit(3)  ,arrSessionUnit(4) ,arrSessionUnit(5)  ,arrSessionUnit(6),arrSessionUnit(7) ,arrSessionUnit(8);
  
  end if;
 arrRet := arrSessionUnit;
 END PR_EXMM_GETSESSIONUNIT;
 
  
 
  --返回考试日期 i_Operate 1 只使用新时间段 2 使用扩展时间段
 PROCEDURE PR_EXMM_GETEXAMDATELIST(i_NewBeginDate date,i_NewEndDate date,i_ExistBeginDate date,i_ExistEndDate date,i_Operate number,ExamDatelist out ExamDate_array) IS
 vExamDate_array ExamDate_array;
 v_count number;
 v_NewBeginDate date:=to_date(to_char(i_NewBeginDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 v_ExistBeginDate date:=to_date(to_char(i_ExistBeginDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 v_NewEndDate date:=to_date(to_char(i_NewEndDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 v_ExistEndDate date:=to_date(to_char(i_ExistEndDate,'yyyy-mm-dd'),'yyyy-mm-dd');
 
 BEGIN
  vExamDate_array.Delete;
   if i_Operate=1 then -- 初始化
          dbms_output.put_line('初始化开始');
             for i in 1..v_NewEndDate-v_NewBeginDate+1
             loop
               vExamDate_array(i):=v_NewBeginDate+i-1;
             end loop;
     else    --增加初始化v_iOperateType=2
          dbms_output.put_line('增量初始化开始');
               ----判断 延长的时间不能在原时间范围内
              if (v_NewBeginDate>v_ExistBeginDate and v_NewBeginDate<v_ExistEndDate) or (v_NewEndDate>v_ExistBeginDate and v_NewEndDate<v_ExistEndDate ) then
                 
                  dbms_output.put_line('错误设置：新开始时间在原时间范围内，或新结束时间在原时间范围内。新时间：'||i_NewBeginDate||'~~'||i_NewEndDate||'~原时间~'||i_ExistBeginDate||'~~'||i_ExistEndDate);
              else   -- 设置新时间段考试时间
                 if v_NewBeginDate>v_ExistEndDate or v_NewEndDate<v_ExistBeginDate then
                      for i in 1..v_NewEndDate-v_NewBeginDate+1
                      loop
                         vExamDate_array(i):=v_NewBeginDate+i-1;
                      end loop;
                   
                else
                 if v_NewBeginDate<v_ExistBeginDate then
                     for i in 1..v_ExistBeginDate-v_NewBeginDate --时间向前延长
                     loop
                      vExamDate_array(i):=v_NewBeginDate+i-1;
                     end loop;
                 end if ;
                 v_count := vExamDate_array.count; -- 前一段开数
                 if v_NewEndDate>v_ExistEndDate then
                    for j in 1..v_NewEndDate-v_ExistEndDate        --时间延后
                     loop
                      vExamDate_array(v_count+j):=v_ExistEndDate+j;
                      end loop;
                  end if;
                end if;
              end if;
     
     end if;
     
    ExamDatelist:=vExamDate_array;
 END PR_EXMM_GETEXAMDATELIST;
 
 
  
  -- 返回考试计划对象
 PROCEDURE PR_EXMM_GETEXAMPLANOBJ(i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,r_ExamPlan OUT EXAMPLAN) IS
  v_PlanMakeOrgCode VARCHAR2(20);
  v_PlanMakeOrgType VARCHAR2(3);
  v_PlanUseOrgCode VARCHAR2(20) :=i_PlanUseOrgCode;
  v_PlanUsrOrgType VARCHAR2(255);
  v_IsInPlanPub NUMBER :=0;   -- 是否在纸考计划下发表中有记录 1有，0无， 只对单位为分部的有效总部缺省为1 
  v_IsApply     number;
  v_ExamSessionUnitMode NUMBER :=0;
  v_PlanCode      varchar2(20);
  v_CateGoryCode  varchar2(20);
  v_CateGoryOrgCode varchar2(20);
  v_CateGoryOrgType varchar2(3);
  v_IsInDetailPub   number :=0; --是否在计划考试时间下发表中有记录 1有0无 只对分部有效，总部缺省为1
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
                
      ----如果是分部，判断相应的下发表是否有记录
      if   v_PlanUsrOrgType=2 then
          execute immediate 'with PaperplanPub as (select case when count(*)>0 then 1 else 0 end IsInPlanPub ,sum(ExamSessionUnitMode) ExamSessionUnitMode from EAS_ExmM_PaperExamPlanPub a1 where a1.sn='||i_ExamPlanSN||' and A1.SEGMENTCODE ='''||i_PlanUseOrgCode||''')
        ,ExamtimePub as (select case when count(*)>0 then 1 else 0 end IsInDetailPub from EAS_ExmM_definitionDetailPub a3 where a3.sn='||i_ExamPlanSN||' and A3.SEGMENTCODE ='''||i_PlanUseOrgCode||''' and exists(select * from EAS_ExmM_ExamCategory where EXAMCATEGORYCODE=a3.EXAMCATEGORYCODE and sn='||i_ExamCategorySN||'))
        select tb1.IsInPlanPub,tb1.ExamSessionUnitMode ,tb2.IsInDetailPub from PaperplanPub tb1 cross join   ExamtimePub tb2'
        into   v_IsInPlanPub    ,v_ExamSessionUnitMode, v_IsInDetailPub;
      else  ---总部判断考试计划时间
         execute immediate 'with 
         ExamtimePub as (select case when count(*)>0 then 1 else 0 end IsInDetailPub from EAS_ExmM_definitionDetail a3 where a3.sn='||i_ExamPlanSN||' and exists(select * from EAS_ExmM_ExamCategory where EXAMCATEGORYCODE=a3.EXAMCATEGORYCODE and sn='||i_ExamCategorySN||'))
         select tb2.IsInDetailPub from  ExamtimePub tb2'
        into    v_IsInDetailPub;
      end if;  
              
  
    else
      v_ErrorCode:=1; 
    end if;
      
    -- 还应该判断是否下发到对应表中
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
 
  -- 返回计划考试时间对象
  PROCEDURE PR_EXMM_GETEXAMTIMEOBJ(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,i_OperateType number,r_EXAMTIME out EXAMTIME) IS
  v_PartNum number;
  v_NewBeginDate date;
  v_NewEndDate   date;
  v_ExistBeginDate date;
  v_ExistEndDate   date;
  v_BeginNumber number;
  v_SEGMENTTEGINNUMBER number;
  BEGIN
 --------i_OperateType :1表示总部设置 2表示分部设置
    if i_OperateType=1 then  --取总部考试时间设置和已经设置好的
       execute immediate ' with time1 as (select numofpart,begindate,enddate from EAS_ExmM_DefinitionDetail a  where A.EXAMPLANCODE ='''||i_ExamPlanCode||''' and A.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''' )
       ,examdate1 as (select nvl(max(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldend1  ,nvl(min(examdate),to_date(''1900-1-1'',''yyyy-dd-mm'')) oldbegin1 ,nvl(max(to_number(A.EXAMSESSIONUNIT)),0) beginnumber from  EAS_ExmM_ExamSessionPlan a where a.EXAMPLANCODE ='''||i_ExamPlanCode||''' and a.SEGMENTCODE=''010'' and a.EXAMCATEGORYCODE ='''||i_ExamCategoryCode||''')
       select numofpart,begindate,enddate,oldbegin1,oldend1,beginnumber from time1 cross join examdate1 '
       into v_PartNum,v_NewBeginDate,v_NewEndDate,v_ExistBeginDate,v_ExistEndDate,v_BeginNumber;
    else  --分部的考试时间处理
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
  
  -- 比较计划开考课程中科目与计划开考科目
  PROCEDURE PR_EXMM_COMPAREPAPER(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,r_Ret out Number) IS
  v_cnt1 number;
  v_cnt2 number;
  v_com1 number;
  v_com2 number;
  BEGIN
   r_Ret:=-1;---没有记录
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
 
---------------------------总部时间单元初始化及增量初始化
  PROCEDURE PR_EXMM_DEALSESSIONUNIT1(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) IS
  
 
 v_iExamPlanCodeSN     number :=i_ExamPlanSN ;
 v_iExamCategoryCodeSN number:=i_ExamCategorySN;
 v_iSegmentCode      EAS_EXMM_SUBJECTPLAN.SEGMENTCODE  %type :=i_PlanUseOrgCode;  --- 考试计划的使用单位
 v_iOperater         EAS_EXMM_SUBJECTPLAN.MAINTAINER %type :=i_Maintainer;
 v_iOperateType      number :=i_OperateType;                        ----1：初始化 2：增量初始化
 
 v_objExamPlan ExamPlan:=EXAMPLAN(v_iExamPlanCodeSN,v_iSegmentCode,v_iExamCategoryCodeSN); -- 考试计划对象
 v_objExamTime ExamTime ; -- 考试日期范围对象
 ------考试时间数组
 v_arrSessionUnit PK_EXMM.SessionUnit_Array;
  --考试日期数组
 v_arrExamDate    PK_EXMM.ExamDate_array;
 v_beginnumber    number;

 v_count             number;
 ------ 通用
 v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续
 v_StrTemp           varchar2(1000);

 BEGIN
 
    
      
          ------------<判断条件>-------------   
      --- 判断考试定义和考试类别 是否一致 及 创建单位 -----
        --PK_EXMM.PR_EXMM_GETEXAMPLANOBJ(v_iExamPlanCodeSN,v_iExamCategoryCodeSN,v_iSegmentCode,v_objExamPlan);
        dbms_output.put_line(v_objExamPlan.PlanCode||'~~'||v_objExamPlan.CateGoryCode||'~~~~'||v_iSegmentCode);
        if v_objExamPlan.ErrorCode=1 then 
         v_Continue := 'A';
         dbms_output.put_line('致命错误：考试定义数据不完整');
         goto IsContinue;
        end if;
     
       if v_objExamPlan.IsApply=1 then 
         v_Continue := 'A1';
         dbms_output.put_line('致命错误：考试定义已经下发');
         goto IsContinue;
        end if;
          
          ---考试定义为总部，使用单位总部
        if v_objExamPlan.PlanMakeOrgType=1 and v_iSegmentCode<>v_objExamPlan.PlanMakeOrgCode  then
          v_Continue :='B1';
         dbms_output.put_line('初始化条件B不合格：考试定义为总部，使用单位为非总部');
         goto IsContinue;
        end if ;
        
        if v_objExamPlan.PlanMakeOrgType=2 then
          v_Continue :='B2';
         dbms_output.put_line('初始化条件B不合格：考试定义为分部，使用单位为总部');
         goto IsContinue;
        end if ;
        
          --C: 判断计划开考课程试卷号与开考科目试卷号是否完全相同
        PK_EXMM.PR_EXMM_COMPAREPAPER(v_objExamPlan.PlanCode,v_objExamPlan.CateGoryCode,v_iSegmentCode,v_count);
        
        if v_count<>1 then
          v_Continue :='C';
         dbms_output.put_line('初始化条件C不合格：计划开考课程与开考科目不相同');
         goto IsContinue;
        end if ;     
        
        --D: 判断：计划考试时间中是否有对应记录
        /*
        if v_objExamPlan.IsInDetailPub =0  then
          v_Continue :='D1';
         dbms_output.put_line('计划考试时间表无设置');
         goto IsContinue;
        end if ;
        */
        --F:构造考试日期和开考时间数组
        dbms_output.put_line('计划考试时间'||v_objExamTime.NewBeginDate||'~'||v_objExamTime.NewEndDate||'~'||v_objExamTime.ExistBeginDate||'~'||v_objExamTime.ExistEndDate);
        --goto IsContinue;
          
         --D: 判断：如果初始化，时间单元安排表应该为空 增量操作，时间安排表不应该为空
         ----取时间设置对象
         
        PK_EXMM.PR_EXMM_GETEXAMTIMEOBJ(v_objExamPlan.PlanCode, v_objExamPlan.CateGoryCode, v_iSegmentCode,1, v_objExamTime);
        
        dbms_output.put_line(v_objExamTime.BEGINNUMBER||'~'||v_objExamTime.ExistEndDate);
        if v_objExamTime.BEGINNUMBER>0 and v_iOperateType=1 then
          v_Continue :='D2';
         dbms_output.put_line('初始化条件D1不合格：初始化操作时已经有时间单元记录');
         goto IsContinue;
        end if ;     
           
       if v_objExamTime.BEGINNUMBER =0 and v_iOperateType=2 then
          v_Continue :='D3';
         dbms_output.put_line('增量操作条件D2不合格：增量操作时没有时间单元记录');
         goto IsContinue;
        end if ; 
         
       
         --返回考试日期 i_Operate 1 只使用新时间段 2 使用扩展时间段
       PK_EXMM.PR_EXMM_GETEXAMDATELIST(v_objExamTime.NewBeginDate,v_objExamTime.NewEndDate,v_objExamTime.ExistBeginDate,v_objExamTime.ExistEndDate,v_iOperateType,v_arrExamDate);
       --- i_planSN 考试定义SN  i_SegmentCode 分部代码  i_tbFrom 从1主表2下发表取数据 arrRet 返回对应的考试开始时间数
       PK_EXMM.PR_EXMM_GETSESSIONUNIT(v_iExamPlanCodeSN, v_objExamPlan.CateGoryCode, v_iSegmentCode, 1, v_arrSessionUnit);
        
       ------------<判断条件>------------- 
        
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
  
  
  ---------------------------分部时间单元初始化及增量初始化
  PROCEDURE PR_EXMM_DEALSESSIONUNIT2(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) IS
 v_iExamPlanCodeSN     number :=i_ExamPlanSN ;
 v_iExamCategoryCodeSN number:=i_ExamCategorySN;
 v_iSegmentCode      EAS_EXMM_SUBJECTPLAN.SEGMENTCODE  %type :=i_PlanUseOrgCode;  --- 考试计划的使用单位
 v_iOperater         EAS_EXMM_SUBJECTPLAN.MAINTAINER %type :=i_Maintainer;
 v_iOperateType      number :=i_OperateType;                        ----1：初始化 2：增量初始化
 
 v_objExamPlan ExamPlan:=EXAMPLAN(v_iExamPlanCodeSN,v_iSegmentCode,v_iExamCategoryCodeSN); -- 考试计划对象
 v_objExamTime ExamTime ; -- 考试日期范围对象
 ------考试时间数组
 v_arrSessionUnit PK_EXMM.SessionUnit_Array;
  --考试日期数组
 v_arrExamDate    PK_EXMM.ExamDate_array;
 v_beginNumber      number ; -- 时间单元起始号码

 v_count             number;
 ------ 通用
 v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续
 v_StrTemp           varchar2(1000);

 BEGIN
 
    
      --- 判断考试定义和考试类别 是否一致 及 创建单位 -----
        --PK_EXMM.PR_EXMM_GETEXAMPLANOBJ(v_iExamPlanCodeSN,v_iExamCategoryCodeSN,v_iSegmentCode,v_objExamPlan);
        dbms_output.put_line(v_objExamPlan.PlanCode||'~~'||v_objExamPlan.CateGoryCode||'~~~~'||v_iSegmentCode||'~'||v_objExamPlan.PlanUseOrgType);
        if v_objExamPlan.ErrorCode=1 then 
         v_Continue := 'A';
         dbms_output.put_line('致命错误：考试定义数据不完整');
         goto IsContinue;
        end if;
        
        if v_objExamPlan.PlanUseOrgType=1 then 
         v_Continue := 'A1';
         dbms_output.put_line('致命错误：当前使用单元不是分部');
         goto IsContinue;
        end if;
        
     
       if v_objExamPlan.IsApply=1 then 
         v_Continue := 'A2';
         dbms_output.put_line('致命错误：考试定义已经下发');
         goto IsContinue;
        end if;
        
         if v_objExamPlan.PlanMakeOrgType=1 and  v_objExamPlan.ExamSessionUnitMode=2 then
          v_Continue :='A3';
         dbms_output.put_line('致命错误：总部计划下混排方式不进行处理');
         goto IsContinue;
        end if ;   
        --goto IsContinue;  
          ---计划纸考考试计划下发表有记录判断
         /* 
        if v_objExamPlan.IsInPlanPub=0  then
          v_Continue :='B1';
         dbms_output.put_line('初始化条件B1不合格：计划纸考考试计划下发表，无记录');
         goto IsContinue;
        end if ;
        ---计划纸考考试时间下发表有记录判断
        if v_objExamPlan.IsInDetailPub=0  then
          v_Continue :='B2';
         dbms_output.put_line('初始化条件B2不合格：-计划纸考考试时间下发表，无记录');
         goto IsContinue;
        end if ;
        
        ---计划纸考考试时间下发表有记录判断
        if v_objExamPlan.IsInDetailPub=0  then
          v_Continue :='B2';
         dbms_output.put_line('初始化条件B2不合格：-计划纸考考试时间下发表，无记录');
         goto IsContinue;
        end if ;
        */
          --B: 判断计划开考课程试卷号与开考科目试卷号是否完全相同
        PK_EXMM.PR_EXMM_COMPAREPAPER(v_objExamPlan.PlanCode,v_objExamPlan.CateGoryCode,v_iSegmentCode,v_count);
        
        if v_count<>1 then
          v_Continue :='C';
         dbms_output.put_line('初始化条件C不合格：计划开考科目与开考科目不相同');
         goto IsContinue;
        end if ;     

       --E: 判断：计划考试时间中是否有对应记录
        if v_objExamPlan.IsInDetailPub =0  then
          v_Continue :='E1';
         dbms_output.put_line('计划考试时间表无设置');
         goto IsContinue;
        end if ;
      
         --D: 判断：如果初始化，时间单元安排表应该为空 增量操作，时间安排表不应该为空
         ----取时间设置对象
         
        PK_EXMM.PR_EXMM_GETEXAMTIMEOBJ(v_objExamPlan.PlanCode, v_objExamPlan.CateGoryCode, v_iSegmentCode,2, v_objExamTime);
        
        dbms_output.put_line(v_objExamTime.BEGINNUMBER||'~'||v_objExamTime.ExistEndDate);
        ----D： 分排混排处理及起始时间单元号设置
           --总部制定的计划 分排
        if v_objExamPlan.PlanMakeOrgType=1 and v_objExamPlan.ExamSessionUnitMode=1 then
        --- 初始化操作
          if v_iOperateType=1 then 
              if  v_objExamTime.SegmentBeginNumber>0 then
                  v_Continue :='D1';
                   dbms_output.put_line('初始化条件D1不合格：分排操作初始化已经完成。');
                  goto IsContinue;
              else
                 v_beginnumber:=v_objExamTime.BEGINNUMBER; --初始化操作取总部的最大单元
              end if;
          else  -- 增量操作
              if  v_objExamTime.SegmentBeginNumber=0 then
                  v_Continue :='D2';
                   dbms_output.put_line('初始化条件D2不合格：分排操作，还没有进行初始化不能处理增量操作。');
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
             dbms_output.put_line('初始化条件D3不合格：分部计划，初始化操作时已经有时间单元记录');
             goto IsContinue;
            else
              v_beginnumber:=0;
            end if ;     
          else  -- 增量操作
             if v_objExamTime.SegmentBeginNumber =0 then
               v_Continue :='D4';
               dbms_output.put_line('增量操作条件D4不合格：增量操作时没有时间单元记录');
               goto IsContinue;
             else
               v_beginnumber :=v_objExamTime.SegmentBeginNumber; 
             end if ; 
          end if ; 
        end if ;
        --F:构造考试日期和开考时间数组
        dbms_output.put_line('计划考试时间'||v_objExamTime.NewBeginDate||'~'||v_objExamTime.NewEndDate||'~'||v_objExamTime.ExistBeginDate||'~'||v_objExamTime.ExistEndDate);
        --goto IsContinue;
        
         --返回考试日期 i_Operate 1 只使用新时间段 2 使用扩展时间段
           --F:构造考试日期和开考时间数组 时间单元创建单位为分部时且为初始化操作 才使用参数1，其它情况使用扩展时间单元，
        if v_objExamPlan.PlanMakeOrgType=2  and  v_iOperateType=1  then
           PK_EXMM.PR_EXMM_GETEXAMDATELIST(v_objExamTime.NewBeginDate,v_objExamTime.NewEndDate,v_objExamTime.ExistBeginDate,v_objExamTime.ExistEndDate,1,v_arrExamDate);
        else
           PK_EXMM.PR_EXMM_GETEXAMDATELIST(v_objExamTime.NewBeginDate,v_objExamTime.NewEndDate,v_objExamTime.ExistBeginDate,v_objExamTime.ExistEndDate,2,v_arrExamDate);
        end if ;
 
       --- i_planSN 考试定义SN  i_SegmentCode 分部代码  i_tbFrom 从1主表2下发表取数据 arrRet 返回对应的考试开始时间数
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
  
  ------返回指定分部中属于总部的计划开考科目 光标方式
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
  
   ------返回指定分部中属于总部的计划开考科目 光标方式
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
        ----同一专业规则下指导必修
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE = v_SegCode and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=v_SegCode)
         )
         
         -- 实施必修
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
        ----同一专业规则下指导必修
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE ='010' and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=v_SegCode)
         )
         
         -- 实施必修
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
        ----同一专业规则下指导必修
        ,tcp010 as (
        select A1.TCPCODE ,C1.COURSEID ,C1.COURSENATURE,B1.SEMESTER    from EAS_ExmM_ExamGuidance a1 inner join eas_exmm_bin2semester b1 on a1.usesemester=B1.BINSEMESTER 
         inner join eas_tcp_modulecourses c1 on a1.tcpcode=C1.TCPCODE and B1.SEMESTER =C1.OPENEDSEMESTER  
         where A1.SEGMENTCODE ='010' and A1.EXAMPLANCODE =i_ExamPlanCode and C1.COURSENATURE ='1' 
         and exists(select * from EAS_ExmM_ExamGuidance where EXAMPLANCODE=a1.EXAMPLANCODE and tcpcode=a1.tcpcode and segmentcode=v_SegCode)
         )
         
         -- 实施必修
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
 v_iOperater EAS_EXMM_DEFINITION.MAINTAINER %type :=i_MAINTAINER;  --操作人   
 v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续
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
      dbms_output.put_line('单位类型不正确'); 
      goto IsContinue;
   end if ;
 
  if v_OrgType=2 then 
    if exists2('select * from EAS_ExmM_PaperExamPlanPub a where A.SN ='||v_iExamPlanSN||' and A.SEGMENTCODE ='''||v_iSegmentCode||'''')=1 then
         with tbdef as ( select a.ExamPlanCode,a.IsPublish from EAS_ExmM_PaperExamPlanPub a where A.SN =v_iExamPlanSN and A.SEGMENTCODE =v_iSegmentCode ) 
         select  ExamPlanCode,IsPublish into v_Examplan_Source from tbdef ;
    else
         v_Continue := 'A0';
        dbms_output.put_line('计划纸考考试计划下发表无记录'); 
      goto IsContinue;
    end if;
  end if ; 
   if v_OrgType=1 then 
        if exists2('select * from EAS_ExmM_definition a where A.SN ='||v_iExamPlanSN||' and A.CreateOrgCode ='''||v_iSegmentCode||'''')=1 then
             with tbdef as ( select a.ExamPlanCode,a.IsApply from EAS_ExmM_definition a where A.SN =v_iExamPlanSN and A.CreateOrgCode =v_iSegmentCode ) 
             select  ExamPlanCode,IsApply into v_Examplan_Source from tbdef ;
        else
             v_Continue := 'A1';
            dbms_output.put_line('计划纸考考试计划无记录'); 
          goto IsContinue;
       end if;
   end if ;
   --goto IsContinue;
   --a)   状态为“已发布”，则删除不成功，弹出错误提示
   if  v_Examplan_Source.IsPublish=1  then
    v_Continue := 'A2';
      dbms_output.put_line('此考试定义编排已经发布，不能修改'); 
      goto IsContinue;
   end if;
   
   
   
    <<IsContinue>>
    
     if v_Continue='OK' then
      ----- 执行继承操作
        -----更新本分部的 
        update EAS_ExmM_SubjectPlan a set ExamSessionUnit=null,Maintainer=v_iOperater,Maintaindate=sysdate,ArrangeState='2'
        where A.EXAMPLANCODE =v_Examplan_Source.examplancode and A.EXAMCATEGORYCODE =v_iExamCategoryCode and a.segmentcode=v_iSegmentCode;
        v_Continue := SQL%ROWCOUNT;
      dbms_output.put_line('EAS_EXMM_SUBJECTPLAN 影响记录数：' || SQL%ROWCOUNT);
      ----- 更新可能是总部的
      if v_OrgType=2 then 
      for v_r in (
         select a.* from EAS_ExmM_SubjectPlan a  where A.ALLOWMAKEEXAMSESSION =1 and A.EXAMPLANCODE =v_Examplan_Source.examplancode and A.EXAMCATEGORYCODE =v_iExamCategoryCode
       and exists(select * from table(PK_EXMM.FN_Exmm_Get010Paper2(v_Examplan_Source.examplancode,v_iSegmentCode)) where sn=a.sn))
       loop
         dbms_output.put_line('当前返回结果：'|| v_r.sn);
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
 
 v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续
 
 v_cnt1 number;      ---记录不存在源计划中的科目数量
 v_cnt2 number;      ---记录已经编排的科目数量
   
   v_objExamPlan_Source ExamPlan:=Examplan(v_iExamPlanSNSource,v_iSegmentCode);
   v_objExamPlan_Target ExamPlan:=Examplan(v_iExamPlanSNTarget,v_iSegmentCode);
   
 BEGIN
   dbms_output.put_line(v_objExamPlan_Source.plancode ||'-'||v_objExamPlan_Source.isapply||'-'||v_objExamPlan_Source.ExamType); 
   dbms_output.put_line(v_objExamPlan_Target.plancode ||'-'||v_objExamPlan_Target.isapply||'-'||v_objExamPlan_Target.ExamType);
  -- end;
  --d)    如果选择的源考试名称与目标考试名称，内容相同，则操作不成功，提示错误信息
    if v_iExamPlanSNSource=v_iExamPlanSNTarget then
    v_Continue := 'D';
      dbms_output.put_line('源考试名称与目标考试名称，内容相同'); 
      goto IsContinue;
   end if;
   
  ----e)    如果考试定义已发布，则不能操作
   if v_objExamplan_Target.IsApply=1 then
    v_Continue := 'E';
      dbms_output.put_line('目标考试计划已发布'); 
      goto IsContinue;
   end if;
   --b)    如果如果源考试定义和目标考试定义的考核形式不同，则继承不成功
   if v_objExamplan_Target.ExamType<>v_objExamplan_Source.ExamType then
    v_Continue := 'B';
      dbms_output.put_line('考核形式'); 
      goto IsContinue;
   end if;
   
    --a)    如果源考试定义或目标考试定义中，不存在计划开考科目，则操作不成功，提示错误信息
     with subjectSource as (select exampapercode from  eas_exmm_subjectplan where examplancode=v_objExamPlan_Source.plancode and segmentcode=v_iSegmentCode and examcategorycode=v_iExamCategoryCodeSource)
   , subjecttarget as ( select exampapercode,examsessionunit from  eas_exmm_subjectplan where examplancode=v_objExamPlan_Target.plancode and segmentcode=v_iSegmentCode and examcategorycode=v_iExamCategoryCodeTarget)
  select nvl(sum(case when b.exampapercode is null then 1 else 0 end),-1) cnt1,nvl(sum(case when a.examsessionunit is not null then 1 else 0 end),-1) as cnt2 
   into v_cnt1,v_cnt2
    from subjecttarget a left join subjectSource b on a.exampapercode=b.exampapercode;
 
   
   dbms_output.put_line(v_cnt1 ||'~'||v_cnt2);
   
   --goto IsContinue;
   
   if v_cnt1>0 or v_cnt2>0 or v_cnt1=-1 or v_cnt2=-1 then
    v_Continue := 'A';
      dbms_output.put_line('不符合继承规则第2条'); 
      goto IsContinue;
   end if;
   
       
    <<IsContinue>>
    
     if v_Continue='OK' then
      ----- 执行继承操作
        
      update eas_exmm_subjectplan a set (examsessionunit,maintainer,maintainDate)=(select examsessionunit,i_Maintainer,sysdate from eas_exmm_subjectplan where exampapercode=a.exampapercode and examcategorycode=a.examcategorycode and examplancode=v_objExamplan_Source.plancode and segmentcode=v_iSegmentCode)
      where A.EXAMPLANCODE =v_objExamplan_Target.plancode and A.EXAMCATEGORYCODE =v_iExamCategoryCodeTarget and a.segmentcode=v_iSegmentCode;
      dbms_output.put_line('EAS_EXMM_SUBJECTPLAN 影响记录数：' || SQL%ROWCOUNT);
          
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
 
 
 
 
     
  --继承考试科目比例
   --成功返回OK，否则返回错误信息有：
     -- 1 异常：EXCEPTION 
     -- 2: a 源考试定义中，不存在考试科目成绩合成比例信息
     --3: b 没有或多于一个目标专业规则
     --4:e 批次已经下发,不能自动建立
     
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
    v_Continue         varchar2(1000) :='OK'; ---判断条件是否成立OK继续 其它字符代表各种不满足条件 不继续 
    v_ExamPlanSource ExamPlan :=Examplan(v_ExamPlanSNSource,v_SegmentCode,v_ExamCategorySNSource); ----考试计划对象
    v_ExamPlanTarget ExamPlan :=Examplan(v_ExamPlanSNTarget,v_SegmentCode,v_ExamCategorySNTarget); ----考试计划对象
  
 BEGIN
 ----判断条件：考试定义是否已经发布 -----
  --   if v_ExamPlanTarget.IsApply=1 then
  --      v_Continue := 'e';
  --     dbms_output.put_line('这个批次已经下发,不能自动建立'); 
  --     goto IsContinue;
  --   end if;
 
    if v_ExamPlanSource.ExamType<>v_ExamPlanTarget.ExamType then
        v_Continue := 'b';
       dbms_output.put_line('原定义与目标定义相同或考核形式不同'); 
       goto IsContinue;
     end if;
      select count(*) into v_Rows from EAS_ExmM_SubjectPlan a inner join 
     EAS_ExmM_XKStandardPlan b on a.sn=B.SUBJECTPLAN_SN 
     where a.examplancode=v_ExamPlanSource.plancode and a.examcategorycode=v_ExamPlanSource.CateGoryCode and a.segmentcode=v_SegmentCode;
     
     if v_Rows=0 then
        v_Continue := 'a';
       dbms_output.put_line('源考试定义中，不存在考试科目成绩合成比例信息'); 
       goto IsContinue;
     end if;
    
       <<IsContinue>> 
     if v_Continue='OK' then
     
       v_Maintaindate :=sysdate; 
     ---- 开始继承
     merge into EAS_ExmM_XKStandardPlan aa
     using (
        with t1 as ( select a.sn,a.exampapercode,b.sn as xksn from EAS_ExmM_SubjectPlan a inner join 
         EAS_ExmM_XKStandardPlan b on a.sn=B.SUBJECTPLAN_SN 
           where a.examplancode=v_ExamPlanSource.plancode and a.examcategorycode=v_ExamPlanSource.CateGoryCode and a.segmentcode=v_SegmentCode) --源
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
       
         
          dbms_output.put_line('EAS_ExmM_XKStandardPlanDetail 影响记录数：' || SQL%ROWCOUNT);
     
     
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

