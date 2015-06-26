--
-- PK_TCP  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_TCP AS
/******************************************************************************
   NAME:       PK_TCP
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/03      libin       1. Created this package body.
******************************************************************************/
 -- 指导性专业规则启用条件判断
 PROCEDURE PR_TCP_GUIDANCEENABLE(TCPCODE IN varchar2,RETCODE OUT varchar2) IS
  returnCode varchar2(50) ;
   l_tcp_code  varchar2(20):='070301208030103';
  l_degreeCollegeid number :=0;
  l_degreeSemster  varchar2(20):='';
  l_spycode varchar2(20);
  l_rowcount number ;
  /* d e f 变量  l_s_标准  l_r_实际_*/
  l_d varchar2(2);
  l_e varchar2(2);
  l_f varchar2(2);
  /* g-1 g_2*/
  l_g1 number;
  l_g2 number;
  
  BEGIN
    /*  a_1 */
    l_tcp_code :=TCPCODE;
    execute immediate 'select nvl(degreecollegeid,0),degreesemester,spycode from EAS_TCP_GUIDANCE where TCPCODE='''|| l_tcp_code || ''''
    into l_degreeCollegeid,l_degreeSemster,l_spycode;
    dbms_output.put_line(l_degreeCollegeid || ' ' || l_degreeSemster || ' '||l_spycode );
    
    if l_degreeCollegeid>0 then 
    execute immediate 'select count(*) from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN  where b.Batchcode='''|| l_degreeSemster ||''' and b.collegeid='|| l_degreeCollegeid ||
    ' and b.spycode='''|| l_spycode || ''' and not exists( select * from EAS_TCP_ModuleCourses where  TCPCode='''|| l_tcp_code || ''' and courseid=a.courseid )'
 
    into l_rowcount;
    dbms_output.put_line(l_rowcount);
     if l_rowcount>0 then
       returnCode :=returnCode ||'a_1,';
     end if;
    /*  a_2 */
     
    execute immediate ' select count(*) from (' ||
                 ' select a.courseid,A.EXAMUNITTYPE  from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN ' ||
                 '   where b.Batchcode=''' || l_degreeSemster ||''' and b.collegeid= '||l_degreeCollegeid|| ' and b.spycode=''' ||l_spycode || ''') a ' || 
                 ' inner join (select a.courseid,a.examunittype from EAS_TCP_ModuleCourses a where a.tcpcode='''||l_tcp_code || ''' ) b ' ||
                 ' on a.courseid=b.courseid and A.EXAMUNITTYPE <>b.examunittype '
                 into l_rowcount;
      dbms_output.put_line(l_rowcount);
     if l_rowcount>0 then
       returnCode :=returnCode ||'a_2,';
     end if; 
     
     
        /*  a_3 不需要判断 */
     /*
    execute immediate ' ' ||
                 ' select count(*)  from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN ' ||
                 '   where b.Batchcode=''' || l_degreeSemster ||''' and b.collegeid= '||l_degreeCollegeid|| ' and b.spycode=''' ||l_spycode ||   
                 ''' and exists(select * from  EAS_TCP_MutexCourses where tcpcode='''||l_tcp_code || ''' ) ' 
                 
                 into l_rowcount;
      dbms_output.put_line(l_rowcount);
     if l_rowcount>0 then
       returnCode :=returnCode ||'a_4,';
     end if;
     */
            /*  a_4 */
     
    execute immediate ' ' ||
                 ' select count(*)  from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN ' ||
                 '   where b.Batchcode=''' || l_degreeSemster ||''' and b.collegeid= '||l_degreeCollegeid|| ' and b.spycode=''' ||l_spycode ||   
                 ''' and exists(select * from  EAS_TCP_SimilarCourses where courseid=a.courseid and   tcpcode='''||l_tcp_code || ''' ) ' 
                 
                 into l_rowcount;
      dbms_output.put_line(l_rowcount);
     if l_rowcount>0 then
       returnCode :=returnCode ||'a_3,';
     end if;
     end if;
            /* d e f */
     
    execute immediate ' select case when A.MINGRADCREDITS <= B.MODULETOTALCREDITS then '''' else ''d,'' end   d  ' ||
                 ' ,case when A.MINEXAMCREDITS <= B.TOTALCREDITS then '''' else ''e,'' end   e  ' ||
                 ' ,case when A.EXEMPTIONMAXCREDITS <= B.REQUIREDTOTALCREDITS then '''' else ''f,'' end   f ' ||
                 ' from EAS_TCP_guidance a inner join EAS_TCP_guidanceOnRule b on a.tcpcode=b.tcpcode where a.tcpcode=''' || l_tcp_code ||''''   
                 
                 into l_d,l_e,l_f;
      dbms_output.put_line(l_d || ' ' ||l_e );
    
       returnCode :=returnCode ||l_d || l_e || l_f ;
     
              /* g  */
        execute immediate ' select  ' ||
                 ' sum(case when A.MINEXAMCREDITS <= B.REQUIREDTOTALCREDITS  then 0 else 1 end)  a  ' ||
                 ' , sum(case when A.MINGRADCREDITS  <= B.TOTALCREDITS then 0 else 1 end)  b ' ||
                 ' from EAS_TCP_Module a inner join EAS_TCP_GuidanceOnModuleRule b on a.tcpcode=b.tcpcode and A.MODULECODE =B.MODULECODE  where a.tcpcode=''' || l_tcp_code ||''''   
                 into l_g1,l_g2;
      dbms_output.put_line(l_g1 || ' ' ||l_g2 );
   
       if l_g1>0 then 
           returnCode :=returnCode ||'g1,' ;
     end if;
     
     if l_g2>0 then 
           returnCode :=returnCode ||'g2,' ;
     end if;       
    
    if returnCode is NULL then
     RETCODE :='1';
    else
     RETCODE :=returnCode;
    end if ;
    dbms_output.put_line( 'returnCode' || returnCode );
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE := 'Err';
  END PR_TCP_GUIDANCEENABLE;
  
  -- 指导性专业规则启用条件批量判断
  FUNCTION  FN_TCP_GUIDANCEENABLE(TCPCODELIST in varchar2) RETURN str_split PIPELINED
  IS
  v_tcpCode varchar2(20);
  v_ReturnCode varchar2(100);
    
    CURSOR myCur is
    select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           dbms_output.put_line(v_tcpCode);
           PR_TCP_GUIDANCEENABLE(v_tcpCode,v_ReturnCode);
           PIPE ROW(v_tcpCode || '-'|| v_ReturnCode);
        END LOOP;
        RETURN;
        CLOSE myCur;
    END    ;
  
  PROCEDURE PR_TCP_IMPLENABLE(ORGCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2) IS
  returnCode varchar2(50) ;
   l_tcp_code  varchar2(20):='070301208030103';
  l_degreeCollegeid number :=0;
  l_degreeSemster  varchar2(20):='';
  l_spycode varchar2(20);
  l_rowcount number ;
  /* b 变量  */
  l_b varchar2(2);
  
  
  /* g-1 g_2*/
  l_g1 number;
  l_g2 number;
  
  BEGIN
    /*  a  */
    l_tcp_code :=TCPCODE;
    execute immediate 'select degreecollegeid,degreesemester,spycode from EAS_TCP_GUIDANCE where TCPCODE='''|| l_tcp_code || ''''
    into l_degreeCollegeid,l_degreeSemster,l_spycode;
    dbms_output.put_line(l_degreeCollegeid || ' ' || l_degreeSemster || ' '||l_spycode );
    if l_degreeCollegeid>0 then 
    execute immediate 'select count(*) from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN  where b.Batchcode='''|| l_degreeSemster ||''' and b.collegeid='|| l_degreeCollegeid ||
    ' and b.spycode='''|| l_spycode || ''' and not exists( select * from (select a.courseid,a.examunittype from EAS_TCP_ModuleCourses a  where a.CourseNature=''1'' and  a.TCPCode='''|| l_tcp_code || '''' ||
    ' union ' ||
    'select a.courseid,a.examunittype from EAS_TCP_ImplModuleCourse a where a.tcpcode='''||l_tcp_code || ''' and a.SegmentCode='''|| ORGCODE || ''') b ' ||
    'where a.courseid=b.courseid and A.EXAMUNITTYPE =b.examunittype)'
 
    into l_rowcount;
    dbms_output.put_line(l_rowcount);
     if l_rowcount>0 then
       returnCode :='a,';
     end if;
    
  end if ;
            /*b */
     
    execute immediate ' select case when A.MINGRADCREDITS <= B.MODULETOTALCREDITS then '''' else ''b,'' end a' ||
                 ' from EAS_TCP_Implementation a inner join EAS_TCP_ImplOnRule b on a.tcpcode=b.tcpcode and A.ORGCODE =B.SEGMENTCODE ' ||
                 ' where a.tcpcode=''' || l_tcp_code ||''' and A.ORGCODE ='''|| ORGCODE || ''''   
                 into l_b;
      dbms_output.put_line(l_b  );
    
       returnCode :=returnCode ||l_b ;
     
              /* g  */
        execute immediate ' select  ' ||
                 ' sum(case when A.MINEXAMCREDITS <= B.REQUIREDTOTALCREDITS  then 0 else 1 end)  a  ' ||
                 ' , sum(case when A.MINGRADCREDITS  <= B.ModuleTOTALCREDITS then 0 else 1 end)  b ' ||
                 ' from EAS_TCP_Module a inner join EAS_TCP_implOnModuleRule b on a.tcpcode=b.tcpcode and A.MODULECODE =B.MODULECODE '||
                 ' where a.tcpcode=''' || l_tcp_code ||''' and  B.SEGMENTCODE ='''||  ORGCODE || ''''    
                 into l_g1,l_g2;
      dbms_output.put_line(l_g1 || ' ' ||l_g2 );
   
       if l_g1>0 then 
           returnCode :=returnCode ||'g1,' ;
     end if;
     
     if l_g2>0 then 
           returnCode :=returnCode ||'g2,' ;
     end if;       
    if returnCode is NULL then
     RETCODE :='1';
    else
     RETCODE :=returnCode;
    end if ;
    
    dbms_output.put_line( 'returnCode' || returnCode );
  END PR_TCP_IMPLENABLE;
  
  
  FUNCTION  FN_TCP_IMPLENABLE(ORGCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED
  IS
  v_tcpCode varchar2(20);
  v_ReturnCode varchar2(100);
    
    CURSOR myCur is
    select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           dbms_output.put_line(v_tcpCode);
           PR_TCP_IMPLENABLE(ORGCODE,v_tcpCode,v_ReturnCode);
           PIPE ROW(v_tcpCode || '-'|| v_ReturnCode);
        END LOOP;
        RETURN;
        CLOSE myCur;
    END    ;
    
    
    /*   执行性专业规则启用条件 */
    
    PROCEDURE PR_TCP_EXECENABLE(ORGCODE IN varchar2, LEARNINGCENTERCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2) IS
  returnCode varchar2(50) ;
   l_tcp_code  varchar2(20);
  l_degreeCollegeid number :=0;
  l_degreeSemster  varchar2(20);
  l_spycode varchar2(20);
  l_rowcount number ;
  /* b 变量  */
  l_b varchar2(2);
  
  
  /* g-1 g_2*/
  l_g1 number;
  l_g2 number;
  
  BEGIN
    /*  a  */
    l_tcp_code := TCPCODE;
    execute immediate 'select degreecollegeid,degreesemester,spycode from EAS_TCP_GUIDANCE where TCPCODE='''|| l_tcp_code || ''''
    into l_degreeCollegeid,l_degreeSemster,l_spycode;
    dbms_output.put_line(l_degreeCollegeid || ' ' || l_degreeSemster || ' '||l_spycode );
    /*学位高校代码>0 表示有学位信息*/
    
    if l_degreeCollegeid>0 then 
    execute immediate 'select count(*) from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN  where b.Batchcode='''|| l_degreeSemster ||''' and b.collegeid='|| l_degreeCollegeid ||
    ' and b.spycode='''|| l_spycode || ''' and not exists( select * from (select a.courseid,a.examunittype from EAS_TCP_ModuleCourses a  where a.CourseNature=''1'' and  a.TCPCode='''|| l_tcp_code || '''' ||
    ' union ' ||
    'select a.courseid,a.examunittype from EAS_TCP_ImplModuleCourse a where a.tcpcode='''||l_tcp_code || ''' and a.SegmentCode='''|| ORGCODE || ''''||
    ' union ' ||
    'select a.courseid,a.examunittype from EAS_TCP_execModuleCourse a where a.tcpcode='''||l_tcp_code || ''' and a.learningcentercode='''|| LEARNINGCENTERCODE ||''') b ' ||
    'where a.courseid=b.courseid and A.EXAMUNITTYPE =b.examunittype)'
 
    into l_rowcount;
    dbms_output.put_line(l_rowcount);
     if l_rowcount>0 then
       returnCode :='a,';
     end if;
    
  end if ;
            /*b */
     
    execute immediate ' select case when A.MINGRADCREDITS <= B.MODULETOTALCREDITS then '''' else ''b,'' end a' ||
                 ' from EAS_TCP_Execution a inner join EAS_TCP_ExecOnRule b on a.tcpcode=b.tcpcode and A.LearningCenterCode =B.LearningCenterCode ' ||
                 ' where a.tcpcode=''' || l_tcp_code ||''' and A.LearningCenterCode ='''|| LEARNINGCENTERCODE || ''''   
                 into l_b;
      dbms_output.put_line(l_b  );
    
       returnCode :=returnCode ||l_b ;
     
              /* g  */
        execute immediate ' select  ' ||
                 ' sum(case when A.MINEXAMCREDITS <= B.REQUIREDTOTALCREDITS  then 0 else 1 end)  a  ' ||
                 ' , sum(case when A.MINGRADCREDITS  <= B.ModuleTOTALCREDITS then 0 else 1 end)  b ' ||
                 ' from EAS_TCP_Module a inner join EAS_TCP_ExecOnModuleRule b on a.tcpcode=b.tcpcode and A.MODULECODE =B.MODULECODE '||
                 ' where a.tcpcode=''' || l_tcp_code ||''' and  B.LearningCenterCode ='''||  LEARNINGCENTERCODE || ''''    
                 into l_g1,l_g2;
      dbms_output.put_line(l_g1 || ' ' ||l_g2 );
   
       if l_g1>0 then 
           returnCode :=returnCode ||'g1,' ;
     end if;
     
     if l_g2>0 then 
           returnCode :=returnCode ||'g2,' ;
     end if;       
    if returnCode is NULL then
     RETCODE :='1';
    else
     RETCODE :=returnCode;
    end if ;
     
    dbms_output.put_line( 'returnCode' || returnCode );
  END PR_TCP_EXECENABLE;
    
  /* 执行性专业规则启用条件批量查询*/
  FUNCTION  FN_TCP_EXECENABLE(ORGCODE IN varchar2,LEARNINGCENTERCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED
  IS
  v_tcpCode varchar2(20);
  v_ReturnCode varchar2(100);
    
    CURSOR myCur is
    select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           dbms_output.put_line(v_tcpCode);
           PR_TCP_EXECENABLE(ORGCODE,LEARNINGCENTERCODE,v_tcpCode,v_ReturnCode);
           PIPE ROW(v_tcpCode || '-'|| v_ReturnCode);
        END LOOP;
        RETURN;
        CLOSE myCur;
    END    ;
    
    
    PROCEDURE PR_TCP_ENABLEDGUIDANCE(TCPCODE in EAS_TCP_GUIDANCE.TCPCODE%type,ENABLEUSER in  EAS_TCP_GUIDANCE.EnableUser%type,RETCODE OUT varchar2) IS
    v_tcpCode EAS_TCP_GUIDANCE.TCPCODE%type := TCPCODE;
    returnCode varchar2(50) :='1' ;
    v_state    EAS_TCP_GUIDANCE.STATE %type;
    v_EnableUser EAS_TCP_GUIDANCE.EnableUser%type :=ENABLEUSER;
    -----add :20150210
     v_insertDate date;
    BEGIN
    select state into v_state from EAS_TCP_GUIDANCE where TCPCODE=v_tcpCode;
     dbms_output.put_line('指导性专业规则当前状态'||v_state);
    IF v_state ='0' THEN
      dbms_output.put_line('开始处理未启用'); 
   /*  复制实施性专业规则*/
   
     INSERT INTO EAS_TCP_Implementation  
     (   
      SN,ImpState,CreateTime
      ,BatchCode, TCPCode, MinGradCredits  ,SchoolSystem
      ,MinExamCredits,ExemptionMaxCredits,EducationType,DegreeCollegeID,DegreeSemester 
      ,OrgCode ,StudentType,ProfessionalLevel,SpyCode  
        
     ) 
     select sys_guid() SN,'0' as ImpState,sysdate as CreateTime
     ,B.BATCHCODE ,B.TCPCODE ,B.MINGRADCREDITS ,B.SCHOOLSYSTEM 
     ,B.MINEXAMCREDITS ,B.EXEMPTIONMAXCREDITS ,B.EDUCATIONTYPE ,B.DEGREECOLLEGEID ,B.DEGREESEMESTER 
     ,A.SEGMENTCODE ,A.STUDENTTYPE ,A.PROFESSIONALLEVEL ,A.SPYCODE 
      from EAS_Spy_OpenSpySegment a inner join EAS_TCP_GUIDANCE b on A.SPYCODE =B.SPYCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL 
      where A.OPENSTATE ='1' and B.TCPCODE =v_tcpCode
        and not exists(select * from EAS_TCP_Implementation where tcpcode=b.tcpcode and orgcode=A.SEGMENTCODE) 
       ;
   
      dbms_output.put_line('EAS_TCP_Implementation' ||  SQL%ROWCOUNT); 
   
    /*实施性专业规则启用规则 
    启用时
     指导性启用规则中总部考试总学分＝实施性启用规则总部考试总学分 ，满足专业规则中总部考试最低学分要求
     指导性启用规则中必修课总学分  ＝ 实施性启用规则模块总学分       
     */
    
    insert into EAS_TCP_ImplOnRule
        ( SN
        ,Batchcode,TCPCode
        ,ModuleTotalCredits,TotalCredits
        ,SegmentCode
        )
       select seq_TCP_ImplOnRule.nextval SN
     ,B.BATCHCODE ,B.TCPCODE  
     ,c.c21 ModuleTotalCredits ,c.c11 TotalCredits 
     ,A.SEGMENTCODE  
      from EAS_Spy_OpenSpySegment a 
      inner join EAS_TCP_GUIDANCE b on A.SPYCODE =B.SPYCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL
      left  join (
       select sum(A.CenterCompulsoryCourseCredit+SegmentCompulsoryCourseCredit) as c21,  tcpcode,sum(A.CenterCompulsoryCourseCredit) as c11 
            from EAS_TCP_GuidanceOnModuleRule A where tcpcode=v_tcpCode group by tcpcode) c  on B.TCPCODE =C.TCPCODE 
      
      where A.OPENSTATE ='1' and B.TCPCODE =v_tcpCode
           and  not exists(select * from  EAS_TCP_ImplOnRule where tcpcode=b.tcpcode and SegmentCode=A.SEGMENTCODE );
      
      dbms_output.put_line('EAS_TCP_ImplOnRule' ||  SQL%ROWCOUNT);
    
    /*实施笥专业规则启用模块规则
    实施性启用模块规则：总部考试总学分（RequiredtotalCredits)=指导性启用模块规则总部考试总学分（RequiredTotalCredits)
                        模块总学分     （ModuleTotalCredits) = 指导性启用模块规则（分部必修分部考试总学分+总部必修总部考试总学分）
                        分部必修课分部考试总学分（SCSegmentTotalCredits)＝指导性启用模块规则 分部必修分部考试总学分
                        分部必修课总考试考试总学分(SCCenterTotalCredits) = 指导性启用模块规则 总部必修总部考试总学分
    */
    
     insert into EAS_TCP_ImplOnModuleRule
    ( SN
    ,BatchCode,TCPCode
    ,SegmentCode
    ,ModuleCode,RequiredTotalCredits,ModuleTotalCredits,SCSegmentTotalCredits,SCCenterTotalCredits)
    
    select seq_TCP_ImplModuRule.nextVal SN
    ,B.BATCHCODE ,B.TCPCODE 
    ,A.SEGMENTCODE 
    ,C.MODULECODE,C.CENTERCOMPULSORYCOURSECREDIT ,C.CENTERCOMPULSORYCOURSECREDIT +C.SEGMENTCOMPULSORYCOURSECREDIT ,0 SEGMENTCOMPULSORYCOURSECREDIT , 0 CENTERCOMPULSORYCOURSECREDIT 
        from EAS_Spy_OpenSpySegment a 
      inner join EAS_TCP_GUIDANCE b on A.SPYCODE =B.SPYCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL
      inner join EAS_TCP_GuidanceOnModuleRule c on B.TCPCODE =C.TCPCODE 
      where A.OPENSTATE ='1' and B.TCPCODE =v_tcpCode
       and not exists(select * from EAS_TCP_ImplOnModuleRule where tcpcode=c.tcpcode and modulecode=c.modulecode and segmentcode=a.segmentcode);
           
     dbms_output.put_line('EAS_TCP_ImplOnModuleRule' ||  SQL%ROWCOUNT); 
 
  /* 更新指导性专业规则启用状态  */
       UPDATE EAS_TCP_Guidance SET  
          State ='1',  
          EnableUser = v_EnableUser,  
          EnableTime = sysdate  
      WHERE TCPCode =v_tcpCode;

      dbms_output.put_line('EAS_TCP_Guidance' ||  SQL%ROWCOUNT || 'ENABLEUSER'||v_EnableUser);
      
      
       --------增加学位课程-----
      v_insertDate:=sysdate;
      insert into EAS_tcp_implmodulecourse
      (sn                 ,batchcode     ,tcpcode ,segmentcode ,modulecode     ,courseid,coursenature
      ,modifiedcoursenature,examunittype,credit,hour,isdegreecourse
      ,isExtendedcourse,issimilari,createtime)
      
       select  sys_guid(), B.BATCHCODE ,B.TCPCODE,C.SEGMENTCODE ,A.MODULECODE ,A.COURSEID ,A.COURSENATURE 
       ,A.COURSENATURE  ,A.EXAMUNITTYPE ,A.Credit,A.HOUR ,'1' 
       ,A.ISEXTENDEDCOURSE ,A.ISSIMILAR ,v_insertDate  from eas_tcp_modulecourses a inner join EAS_TCP_GUIDANCE b on a.tcpcode=b.tcpcode 
       inner join EAS_Spy_OpenSpySegment c on B.SPYCODE =C.SPYCODE and B.STUDENTTYPE =C.STUDENTTYPE and B.PROFESSIONALLEVEL =C.PROFESSIONALLEVEL  
       where  
         C.OPENSTATE ='1' and  a.coursenature<>1 and 
        b.tcpcode=v_tcpCode
        and exists(select * from EAS_TCP_DegreeCurriculums where collegeid=B.DEGREECOLLEGEID and batchcode=B.DegreeSemester and courseid=a.courseid)
        and not exists(select * from EAS_tcp_implmodulecourse where segmentcode=c.segmentcode and tcpcode=a.tcpcode and courseid=a.courseid) ;
       dbms_output.put_line('insert EAS_tcp_implmodulecourse' ||  SQL%ROWCOUNT);
       
        merge into EAS_TCP_ImplOnRule aa 
       using(select segmentcode,tcpcode,sum(credit) total ,sum(case when EXAMUNITTYPE='1' then credit else 0 end) examtotal 
       from EAS_tcp_implmodulecourse where tcpcode=v_tcpCode and createtime=v_insertDate group by segmentcode,tcpcode) bb
       on (aa.segmentcode =bb.segmentcode and aa.tcpcode=bb.tcpcode)
       when matched then 
       update  set ModuleTotalCredits =moduletotalcredits+bb.total
                                     ,totalcredits =totalcredits+ bb.examtotal ;  
      
       dbms_output.put_line('update EAS_tcp_implmodulecourse' ||  SQL%ROWCOUNT);
       
        merge into EAS_TCP_ImplOnModuleRule aa 
       using(select segmentcode,tcpcode,modulecode,sum(credit) total ,sum(case when EXAMUNITTYPE='1' then credit else 0 end) examtotal
       ,sum(case when coursenature='2' and EXAMUNITTYPE='2' then credit else 0 end) sexamtotal
       ,sum(case when coursenature='2' and EXAMUNITTYPE='1' then credit else 0 end) cexamtotal 
       from EAS_tcp_implmodulecourse where tcpcode=v_tcpCode and createtime=v_insertDate group by segmentcode,tcpcode,modulecode) bb
       on (aa.segmentcode =bb.segmentcode and aa.tcpcode=bb.tcpcode and aa.modulecode=bb.modulecode)
       when matched then 
       update  set RequiredTotalCredits =RequiredTotalCredits+bb.examtotal
                                     ,Moduletotalcredits =Moduletotalcredits+ bb.total
                                     ,SCsegmenttotalcredits= SCsegmenttotalcredits+sexamtotal
                                     ,SCCentertotalCredits  =SCCentertotalCredits+cexamtotal;
       dbms_output.put_line('update EAS_TCP_ImplOnModuleRule' ||  SQL%ROWCOUNT);
      
      
      END IF;
        commit;
      Exception
       WHEN Others THEN
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
       rollback;
       returnCode :='-0'; /* 返回未成功标志*/
    END PR_TCP_ENABLEDGUIDANCE;


/*   批量处理指导性专业规则启用 */
    PROCEDURE PR_TCP_BATCHENABLEDGUIDANCE(TCPCODELIST in varchar2,ENABLEUSER in  EAS_TCP_GUIDANCE.EnableUser%type,RETCODE OUT varchar2) IS
      v_tcpCode varchar2(20);
      v_ReturnCode varchar2(100);
     CURSOR myCur is
     select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           
           PR_TCP_ENABLEDGUIDANCE(v_tcpCode,ENABLEUSER,v_ReturnCode);
           if v_ReturnCode ='0' then
            RETCODE := RETCODE || v_tcpCode || ',';
           end if ;
           
        END LOOP;
        CLOSE myCur;
    
    
    END PR_TCP_BATCHENABLEDGUIDANCE;
    
 
   -- -- 单独删除指导性专业规则
    PROCEDURE PR_TCP_DELETEGUIDANCETCP( i_TCPCode in EAS_TCP_GUIDANCE.TCPCODE%type ,RETCODE OUT varchar2) IS
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
     RETCODE := '1';

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
         commit;

    end if;
    
--   tmpVar := 0;
   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
     WHEN OTHERS THEN
       RETCODE:='0';
      DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
      rollback;
       
--       -- Consider logging the error and then re-raise
--       RAISE;
     END PR_TCP_DELETEGUIDANCETCP;


 PROCEDURE PR_TCP_BATCHDELETEGUIDANCETCP(TCPCODELIST in varchar2,RETCODE OUT varchar2) IS
      v_tcpCode varchar2(20);
      v_ReturnCode varchar2(100);
     CURSOR myCur is
     select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           
           PR_TCP_DELETEGUIDANCETCP(v_tcpCode,v_ReturnCode);
           if v_ReturnCode ='0' then
            RETCODE := RETCODE || v_tcpCode || ',';
           end if ;
           
        END LOOP;
        CLOSE myCur;
    
    
    END PR_TCP_BATCHDELETEGUIDANCETCP;
    
    
    -- 启用一个单独的实施性专业规则
    PROCEDURE PR_TCP_ENABLEDIMPL(ORGCODE IN varchar2,TCPCODE in EAS_TCP_GUIDANCE.TCPCODE%type,IMPLEMENTERUSER in  EAS_TCP_IMPLEMENTATION.Implementer%type,RETCODE OUT varchar2) IS
     returnCode varchar2(50):='1' ;
    l_tcpCode EAS_TCP_IMPLEMENTATION.TCPCODE%type :=TCPCODE;--专业规则
    l_batchcode EAS_TCP_IMPLEMENTATION.BATCHCODE %type;
    l_OrgCode   EAS_TCP_IMPLEMENTATION.ORGCODE %type :=ORGCODE;
    l_EnableUser EAS_TCP_IMPLEMENTATION.IMPLEMENTER  %type;
    l_state    EAS_TCP_IMPLEMENTATION.IMPSTATE %type;
    BEGIN
    select Impstate into l_state from EAS_TCP_IMPLEMENTATION where TCPCODE=l_tcpCode and OrgCode=l_OrgCode;
    dbms_output.put_line(l_tcpCode || ' 状态：' ||l_state);
    IF l_state ='0' THEN
      dbms_output.put_line('开始处理未启用'); 
    /* 执行规则B */
       
       INSERT INTO EAS_TCP_SegmentCourses(SN,OrgCode,CourseID,CourseState,CreateTime)
       select seq_TCP_segmCour.nextval,l_OrgCode ,a.courseid,1,sysdate from
        (select courseid from  EAS_TCP_modulecourses a 
        where not   exists(select * from EAS_TCP_SegmentCourses b where a.courseid=b.courseid  and B.ORGCODE =l_OrgCode)
        and a.tcpcode=l_tcpCode --and a.coursenature='1'
        union
        select courseid from  EAS_TCP_implmodulecourse a 
        where not   exists(select * from EAS_TCP_SegmentCourses b where a.courseid=b.courseid  and a.SegmentCode =b.Orgcode )
        and a.tcpcode=l_tcpCode  and A.SEGMENTCODE =l_OrgCode
        union
        select courseid from  EAS_TCP_ConversionCourse a 
        where not   exists(select * from EAS_TCP_SegmentCourses b where a.courseid=b.courseid  and B.ORGCODE =l_OrgCode)
        and a.tcpcode=l_tcpCode) a ;
        dbms_output.put_line('EAS_TCP_SegmentCourses' ||  SQL%ROWCOUNT);
        
         /* 执行规则D */
        insert into Eas_tcp_execution(
                 BATCHCODE,SEGMENTCODE,TCPCODE
                ,MINGRADCREDITS,MINEXAMCREDITS,EXEMPTIONMAXCREDITS
                ,EDUCATIONTYPE,STUDENTTYPE,PROFESSIONALLEVEL,SPYCODE
                ,SCHOOLSYSTEM,DEGREECOLLEGEID,degreeSemester
                ,learningcentercode
                ,SN,ExcState,CreateTime)
           select  A.BATCHCODE ,A.ORGCODE ,A.TCPCODE 
           ,A.MINGRADCREDITS ,A.MINEXAMCREDITS ,A.EXEMPTIONMAXCREDITS  
           ,A.EDUCATIONTYPE ,A.STUDENTTYPE ,A.PROFESSIONALLEVEL ,A.SPYCODE 
           ,A.SCHOOLSYSTEM ,A.DEGREECOLLEGEID ,A.DEGREESEMESTER 
           ,B.LEARNINGCENTERORGCODE 
           ,sys_guid() as SN,'0' as  ExcState ,sysdate as  CreateTime
           from EAS_TCP_IMPLEMENTATION a 
           inner join EAS_SPY_OpenSpyLearningCenter b on A.ORGCODE =B.SEGMENTORGCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL 
           and A.SPYCODE =B.SPYCODE and B.OPENSTATE ='1'
           where a.tcpcode=l_tcpCode and orgcode=l_OrgCode
           and not exists(select * from Eas_tcp_execution where tcpcode=l_tcpCode and LEARNINGCENTERCODE=B.LEARNINGCENTERORGCODE);
           dbms_output.put_line('Eas_tcp_execution' ||  SQL%ROWCOUNT);  
         
        
           
        
           
        /* /* 执行规则e : EAS_TCP_ExecModuleCourse */
               -------
      insert into EAS_TCP_ExecModuleCourse(sn,batchcode,tcpcode,segmentcode,learningcentercode,modulecode,courseid,coursenature,examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,createtime)     
      with t1 as ( select a.tcpcode,b.learningcenterOrgcode  as  learningcentercode,A.ORGCODE as segmentcode  from EAS_TCP_IMPLEMENTATION a inner join EAS_SPY_OpenSpyLearningCenter b on 
                A.ORGCODE =B.SEGMENTORGCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL and A.SPYCODE =B.SPYCODE 
                where B.OPENSTATE ='1' and A.TCPCODE =l_tcpCode and A.ORGCODE =l_OrgCode )
       ,t2 as (select sys_guid() sn, A.BATCHCODE ,A.TCPCODE ,A.SEGMENTCODE ,t1.learningcentercode,A.MODULECODE ,A.COURSEID ,A.COURSENATURE ,A.EXAMUNITTYPE ,A.CREDIT ,A.HOUR,C.OPENEDSEMESTER as suggestopensemester,C.OPENEDSEMESTER as planopensemester  ,a.ISDEGREECOURSE,A.ISSIMILARI,sysdate as createtime    
                   from EAS_TCP_implModuleCourse a inner join t1 on a.tcpcode=t1.tcpcode and A.SEGMENTCODE =t1.segmentcode
                   inner join eas_tcp_modulecourses c on A.TCPCODE =C.TCPCODE and A.COURSEID =C.COURSEID and A.MODULECODE =C.MODULECODE 
                   where  A.COURSENATURE ='3' and  (A.ISEXECUTIVECOURSE =1 or A.ISDEGREECOURSE =1))
            select * from t2 
            where not exists(select sn,batchcode,tcpcode,segmentcode,learningcentercode,modulecode,courseid,coursenature,examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,createtime
             from EAS_TCP_ExecModuleCourse where learningcentercode=t2.learningcentercode and tcpcode=t2.tcpcode and courseid=t2.courseid);
        
          dbms_output.put_line('EAS_TCP_ExecModuleCourse' ||  SQL%ROWCOUNT); 
      
                     /* EAS_TCP_ExecOnRule */
            --模块总学分11. 总部必修+ 12 分部必修（分部必修总部考试+分部必修分部考试）+13 分部选修的执行课
         --总部考试  21 总部必修总部考试+22分部必修总部考试+23选修总部考试
         --避免出现null+12+3=null情况,对sum后的结果使用nvl(,0) 
            insert into EAS_TCP_ExecOnRule(
              BatchCode,SegmentCode,TCPCode
              ,LearningCenterCode
              ,ModuleTotalCredits,TotalCredits
              ,SN)
             select A.BATCHCODE ,A.ORGCODE ,A.TCPCODE 
              ,B.LEARNINGCENTERORGCODE
              ,nvl(c1.c11,0)+nvl(c2.c12,0)+nvl(c3.c13,0) ,nvl(c1.c21,0)+nvl(c2.c22,0)+nvl(c3.c23,0)
              ,seq_TCP_ExecOnRule.nextval
               from EAS_TCP_IMPLEMENTATION a 
               inner join EAS_SPY_OpenSpyLearningCenter b on A.ORGCODE =B.SEGMENTORGCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL 
               and A.SPYCODE =B.SPYCODE and B.OPENSTATE ='1'
               left join  -- 指导性必修
               (
                select   tcpcode,sum(a.CenterCompulsoryCourseCredit) as c11 ,sum(CenterCompulsoryCourseCredit) as c21
            from EAS_TCP_GuidanceOnModuleRule A where tcpcode=l_tcpCode  group by tcpcode) c1 
            on a.tcpcode=c1.tcpcode 
                left join (
                select   tcpcode,sum(a.SCSegmentTotalCredits+a.SCCenterTotalCredits) as c12 ,sum(SCCenterTotalCredits) as c22
            from EAS_TCP_implOnModuleRule A where tcpcode=l_tcpCode and A.SEGMENTCODE =l_OrgCode  group by tcpcode) c2
            on a.tcpcode=c2.tcpcode 
               left join   -- 实施性执行
               (select tcpcode
            ,sum(a.credit)  as c13 
            ,sum(case when  examunittype='1' then a.credit else 0 end) as c23
            from EAS_TCP_implModuleCourse a where tcpcode=l_tcpCode and A.SEGMENTCODE =l_OrgCode  and (A.ISEXECUTIVECOURSE ='1' or A.ISDEGREECOURSE ='1') and A.COURSENATURE ='3' group by tcpcode) c3
            on a.tcpcode=c3.tcpcode
            
            where a.tcpcode=l_tcpCode and orgcode=l_OrgCode
            and not exists(select * from EAS_TCP_ExecOnRule where tcpcode=A.TCPCODE and learningcentercode=B.LEARNINGCENTERORGCODE );
             
            dbms_output.put_line('Eas_tcp_execOnRule' ||  SQL%ROWCOUNT);
                    
               /*EAS_TCP_ExecOnModuleRule*/
            ---- 总部考试总学分＝ 指导性模块总部必修总部考试 s11 + 实施性模块分部必修总部考试s12+ 分部选修总部考试的执行课 s13 
         ----模块总学分     =   指导性模块总部必修 s21 + 实施性模块分部必修s22+ 分部选修执行课 s23
         --避免出现null+12+3=null情况,对sum后的结果使用nvl(,0) 
            insert into EAS_TCP_ExecOnModuleRule
             (BatchCode,SegmentCode,TCPCode
              ,LearningCenterCode,moduleCode
             , RequiredTotalCredits,ModuleTotalCredits
              ,SN
              )
         with t1 as (select   tcpcode,modulecode,CenterCompulsoryCourseCredit as TotalCredit ,CenterCompulsoryCourseCredit as TotalExamCredit
                from EAS_TCP_GuidanceOnModuleRule A where tcpcode=l_tcpCode )
       , t2 as (   select   tcpcode,modulecode,a.SCSegmentTotalCredits+a.SCCenterTotalCredits as TotalCredit ,SCCenterTotalCredits as TotalExamCredit
            from EAS_TCP_implOnModuleRule A where tcpcode=l_tcpCode and A.SEGMENTCODE =l_OrgCode   )
        ,t3 as ( select a.LearningCenterCode,a.tcpcode,modulecode
            ,sum(a.credit)  as TotalCredit 
            ,sum(case when  examunittype='1' then a.credit else 0 end) as TotalExamCredit
            
            from EAS_TCP_ExecModuleCourse a where tcpcode=l_tcpCode and A.SEGMENTCODE =l_OrgCode group by a.LearningCenterCode,a.tcpcode,modulecode  )
        ,t4 as ( select A.BATCHCODE ,A.ORGCODE ,A.TCPCODE ,B.LEARNINGCENTERORGCODE
                 from EAS_TCP_IMPLEMENTATION a 
               inner join EAS_SPY_OpenSpyLearningCenter b on A.ORGCODE =B.SEGMENTORGCODE and A.STUDENTTYPE =B.STUDENTTYPE and A.PROFESSIONALLEVEL =B.PROFESSIONALLEVEL 
               and A.SPYCODE =B.SPYCODE where  B.OPENSTATE ='1' and a.tcpcode=l_tcpCode and a.ORGCODE=l_OrgCode) 
       select t4.batchcode,t4.orgcode,t4.tcpcode
       ,t4.LEARNINGCENTERORGCODE,t1.modulecode
       ,nvl(t1.TotalExamCredit,0)+nvl(t2.TotalExamCredit,0)+nvl(t3.TotalExamCredit,0) as RequiredTotalCredits
       ,nvl(t1.totalcredit,0)+nvl(t2.totalcredit,0)+nvl(t3.totalCredit,0) as ModuleTotalCredits
       ,seq_TCP_execOnModuRule.nextval
       from t4 left join t1 on t4.tcpcode=t1.tcpcode   left join t2 on t1.tcpcode=t2.tcpcode and t1.modulecode=t2.modulecode      
       left join t3 on t1.tcpcode=t3.tcpcode and t1.modulecode=t3.modulecode and t4.LearningCenterorgCode=t3.LearningCenterCode
       where not exists(select * from EAS_TCP_ExecOnModuleRule where tcpcode=t4.TCPCODE and modulecode=t1.MODULECODE and learningcentercode=t4.LEARNINGCENTERORGCODE );
            
            dbms_output.put_line('EAS_TCP_ExecOnModuleRule' ||  SQL%ROWCOUNT);
            
            /* 更新实施专业规则启用状态  */
       UPDATE EAS_TCP_IMPLEMENTATION SET  
          ImpState ='1',  
          Implementer = l_EnableUser,  
          ImpTime = sysdate  
      WHERE TCPCode =l_tcpCode and OrgCode=l_OrgCode;

      dbms_output.put_line('EAS_TCP_IMPLEMENTATION' ||  SQL%ROWCOUNT || 'Implementer'||l_EnableUser);
      
      END IF;
        commit;
      Exception
       WHEN Others THEN
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
       rollback;
       returnCode :='-0'; /* 返回未成功标志*/
            
   
    END PR_TCP_ENABLEDIMPL;
    
    
    
    
/*   批量处理实施性专业规则启用 */
    PROCEDURE PR_TCP_BATCHENABLEDIMPL(ORGCODE IN varchar2,TCPCODELIST in varchar2,IMPLEMENTERUSER in  EAS_TCP_IMPLEMENTATION.Implementer%type,RETCODE OUT varchar2) IS
      l_OrgCode EAS_TCP_IMPLEMENTATION.ORGCODE %type :=ORGCODE;
      l_tcpCode EAS_TCP_IMPLEMENTATION.TCPCODE%type;
      l_ReturnCode varchar2(100);
     CURSOR myCur is
     select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO l_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           
           PR_TCP_ENABLEDIMPL(l_OrgCode,l_tcpCode,IMPLEMENTERUSER,l_ReturnCode);
           if l_ReturnCode ='0' then
            RETCODE := RETCODE || l_tcpCode || ',';
           end if ;
           
        END LOOP;
        CLOSE myCur;
    
    
    END PR_TCP_BATCHENABLEDIMPL;
    
    
    
     ---延用实施性专业规则
     ---延用实施性专业规则
    PROCEDURE PR_TCP_PUTOFFIMPL(ORGCODE IN VARCHAR2,TCPCODE IN EAS_TCP_GUIDANCE.TCPCODE%TYPE ,RETCODE OUT varchar2) IS
    l_CurTcpCode EAS_TCP_IMPLEMENTATION.TCPCODE%type :=TCPCODE;--专业规则
    l_CurBatchCode eas_tcp_recruitbatch.BATCHCODE %type;
    l_PreBatchCode eas_tcp_recruitbatch.BATCHCODE %type;
    l_PreTcpCode EAS_TCP_IMPLEMENTATION.TCPCODE %type;
    l_OrgCode    EAS_TCP_IMPLEMENTATION.ORGCODE %type :=ORGCODE;
    l_state    EAS_TCP_IMPLEMENTATION.IMPSTATE %type;
   
    
    BEGIN
     RETCODE :='1';
      select Impstate,batchcode into l_state,l_CurBatchCode from EAS_TCP_IMPLEMENTATION where TCPCODE=l_CurTcpCode and OrgCode=l_OrgCode;
   --取前一年度学期
      select batchcode into l_PreBatchCode from eas_tcp_recruitbatch where to_date(batchcode,'yyyymm')<to_date(to_char(l_CurBatchCode),'yyyymm') and rownum<2 order by batchcode desc;
   
       select tcpcode into l_PreTcpCode  from EAS_TCP_IMPLEMENTATION a where exists  
      (select * from EAS_TCP_Guidance  where EDUCATIONTYPE =a.EDUCATIONTYPE and PROFESSIONALLEVEL =a.PROFESSIONALLEVEL and SPYCODE =a.SPYCODE  and TCPCODE =l_CurTcpCode)
       and A.BATCHCODE =l_PreBatchCode and a.orgcode=l_OrgCode;
       ----debug
      dbms_output.put_line(l_CurTcpCode || ' 状态：' ||l_state||' 上一年度'||l_PreBatchCode || ' l_PreTcpCode:' || l_PreTcpCode);
   
     ----- 增加课程EAS_TCP_ImpModuleCourse  
        insert into EAS_TCP_ImplModuleCourse( SN,BatchCode,tcpcode,createtime,ExtendedSource
                                             ,segmentcode,modulecode,courseid,coursenature
                                             ,modifiedcoursenature,examunittype,modifiedexamunittype
                                             ,credit,hour,isDegreeCourse,IsExecutiveCourse,isExtendedCourse
                                             ,isSimilari)

         select                         sys_guid() as Sn, l_CurBatchCode,l_CurTcpCode,sysdate as createtime,l_PreBatchCode
                                               ,A.SEGMENTCODE,a.modulecode, A.COURSEID,a.coursenature
                                               ,a.modifiedcoursenature,a.examunittype,a.modifiedexamunittype
                                               ,A.CREDIT ,A.HOUR ,A.ISDEGREECOURSE ,A.ISEXECUTIVECOURSE ,A.ISEXTENDEDCOURSE 
                                       ,A.ISSIMILARI  
         from EAS_TCP_ImplModuleCourse a
        where tcpcode=l_PreTcpCode and segmentcode=l_OrgCode 
        and exists (select 1 from EAS_TCP_ModuleCourses  b where b.tcpcode=l_CurTcpCode and b.coursenature='3' and b.courseid=a.courseid and a.modulecode=b.modulecode)
        and not exists(select 1 from EAS_TCP_ImplModuleCourse c where C.TCPCODE =l_CurTcpCode and A.COURSEID =c.courseid and a.segmentcode=c.segmentcode);
         dbms_output.put_line(' EAS_TCP_ImplModuleCourse-' ||  SQL%ROWCOUNT);

        delete eas_tcp_implonrule where tcpcode=l_CurTcpCode and  SEGMENTCODE =l_OrgCode;
         dbms_output.put_line('delete  eas_tcp_implonrule-' ||  SQL%ROWCOUNT);
         
        delete EAS_TCP_IMPLONMODULERULE  where tcpcode=l_CurTcpCode and  SEGMENTCODE =l_OrgCode;
         dbms_output.put_line('delete EAS_TCP_IMPLONMODULERULE-' ||  SQL%ROWCOUNT);
        
        insert into EAS_TCP_ImplOnRule(SN,Batchcode,segmentcode,tcpcode,moduletotalcredits,totalcredits)
        select seq_tcp_implOnRule.nextval,batchcode,segmentcode,tcpcode,s1,s2 from 
        (select  BatchCode ,SegmentCode ,TCPCode ,SUM(Credit ) s1,SUM(case when examunittype=1 then Credit else 0 end) s2 
        from (
           select BatchCode , l_OrgCode SegmentCode ,TCPCode ,ModuleCode ,CourseID ,CourseNature ,ExamUnitType,Credit    from
           EAS_TCP_ModuleCourses  where CourseNature ='1' and TCPCODE=l_CurTcpCode
         union all
         select b.BatchCode , b.SegmentCode ,b.TCPCode ,b.ModuleCode ,b.CourseID ,b.CourseNature,b.ExamUnitType ,b.Credit   
         from EAS_TCP_ImplModuleCourse b where B.SEGMENTCODE =l_OrgCode and B.TCPCODE =l_CurTcpCode ) t
         group by batchcode,segmentcode,tcpcode) k;
         dbms_output.put_line('EAS_TCP_ImplOnRule-' ||  SQL%ROWCOUNT);
                
        insert into EAS_TCP_ImplOnModuleRule(SN,Batchcode,segmentcode,tcpcode,modulecode,requiredTotalCredits,moduleTotalCredits,SCSegmentTotalCredits,SCCenterTotalCredits)
        select seq_TCP_implModuRule.nextval,batchcode,segmentcode,tcpcode,modulecode,s0,s1,s2,s3 from
        (select  BatchCode ,SegmentCode ,TCPCode ,a.modulecode,SUM(case when examunittype=1 then Credit else 0 end) s0,SUM(Credit ) s1 ,SUM(case when CourseNature=2 and examunittype=2 then Credit else 0 end) s2
          ,SUM(case when CourseNature=2 and examunittype=1 then Credit else 0 end) s3
           from
         (
         select b.BatchCode ,l_OrgCode SegmentCode ,b.TCPCode ,b.ModuleCode ,b.CourseID ,b.CourseNature ,b.ExamUnitType,b.Credit    from
          EAS_TCP_ModuleCourses b where b.CourseNature ='1' and TCPCODE=l_CurTcpCode
         union all
         select b.BatchCode , b.SegmentCode ,b.TCPCode ,b.ModuleCode ,b.CourseID ,b.CourseNature,b.ExamUnitType ,b.Credit   from EAS_TCP_ImplModuleCourse b 
         where B.SEGMENTCODE =l_OrgCode and B.TCPCODE =l_CurTcpCode
         
         )  a
         group by batchcode,segmentcode,tcpcode,ModuleCode ) k;
         dbms_output.put_line('EAS_TCP_ImplOnModuleRule-' ||  SQL%ROWCOUNT);
     
         commit;

  
          EXCEPTION 
          
           WHEN NO_DATA_FOUND THEN
              DBMS_OUTPUT.PUT_LINE('无记录');
              rollback;
          RETCODE :='0';
    END PR_TCP_PUTOFFIMPL;
    
    
    PROCEDURE PR_TCP_BATCHPUTOFFIMPL(ORGCODE IN varchar2,TCPCODELIST in varchar2,RETCODE OUT varchar2) IS
      l_OrgCode EAS_TCP_IMPLEMENTATION.ORGCODE %type :=ORGCODE;
      l_tcpCode EAS_TCP_IMPLEMENTATION.TCPCODE%type;
      l_ReturnCode varchar2(100);
     CURSOR myCur is
     select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO l_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           
           PR_TCP_PUTOFFIMPL(l_OrgCode,l_tcpCode,l_ReturnCode);
           if l_ReturnCode ='0' then
            RETCODE := RETCODE || l_tcpCode || ',';
           end if ;
           
        END LOOP;
        CLOSE myCur;
    
    END PR_TCP_BATCHPUTOFFIMPL;
    
    
    
    PROCEDURE PR_TCP_PUBLISHIMPL(iORGCODE IN varchar2,iBATCHCODE in varchar2,RETCODE OUT varchar2) IS
    
    
    BEGIN
        RETCODE :='1';
        insert into temp_tcplist(tcpcode,orgcode)
        select A.TCPCODE ,B.LEARNINGCENTERCODE from eas_tcp_implementation a inner join eas_tcp_execrulecontrol b on A.ORGCODE =B.SEGMENTCODE 
        inner join  eas_spy_openspylearningcenter c on b.learningcentercode=C.LEARNINGCENTERORGCODE and A.STUDENTTYPE =C.STUDENTTYPE and A.PROFESSIONALLEVEL =C.PROFESSIONALLEVEL 
        and A.SPYCODE =c.spycode and C.OPENSTATE ='1'
        where A.BATCHCODE =iBATCHCODE and A.ORGCODE =iORGCODE and a.impstate='1' and b.isBeControl=1;
    
        if SQL%ROWCOUNT=0 then
         dbms_output.put_line( '不执行下发： 可以下发的规则数：' ||SQL%ROWCOUNT);
        else 
        
 ---- 增加课程EAS_TCP_execModuleCourse
          insert into EAS_TCP_ExecModuleCourse(
                 BatchCode,tcpcode,segmentcode
                 ,learningcentercode
                 ,modulecode,courseid,coursenature,examunittype
                 ,credit,hour,isdegreecourse,issimilar
                 ,planopensemester
                 ,sn,createtime)
                 
            select iBatchCode ,c.TCPCODE ,iOrgCode 
               ,c.orgcode 
               ,B.MODULECODE ,B.COURSEID ,B.COURSENATURE ,B.EXAMUNITTYPE 
               ,B.CREDIT ,B.HOUR ,B.ISDEGREECOURSE ,B.ISSIMILARI
               ,A.OPENEDSEMESTER /* 学期*/ 
               ,sys_guid , sysdate
            from 
               EAS_tcp_implmodulecourse b inner join eas_tcp_modulecourses a on A.TCPCODE =B.TCPCODE  and A.MODULECODE =B.MODULECODE and A.COURSEID =B.COURSEID 
                inner join temp_tcplist c on B.TCPCODE =C.TCPCODE  
                 left join EAS_TCP_ExecModuleCourse d on D.LEARNINGCENTERCODE  =C.orgcode and b.tcpcode=d.TCPCODE 
                  and b.modulecode=d.MODULECODE and b.courseid=d.COURSEID and d.SN is null
            where  B.COURSENATURE ='3' and  B.SEGMENTCODE = iORGCODE  ;

           ------- EAS_TCP_ExeconRule
            update EAS_TCP_ExeconRule A 
            set (moduletotalcredits,totalcredits) =( select moduletotalcredits, totalcredits 
            from  EAS_TCP_IMpLONRULE c  where  A.TCPCODE =c.tcpcode and C.SEGMENTCODE =iORGCODE
             ) 
             where exists (select 1 from temp_tcplist b where A.TCPCODE =B.TCPCODE and A.LEARNINGCENTERCODE =B.ORGCODE );
            
            dbms_output.put_line('累加学分EAS_TCP_ExeconRule' ||  SQL%ROWCOUNT);
            
            -----EAS_TCP_ExecOnModuleRule
            update EAS_TCP_ExecOnModuleRule A 
            set (moduletotalcredits,Requiredtotalcredits) =( select ModuleTotalCredits,RequiredTotalCredits
            from EAS_TCP_ImplOnModuleRule B where A.MODULECODE =b.ModuleCode and A.TCPCODE =b.tcpcode and B.segmentcode =iORGCODE)
             where exists (select 1 from temp_tcplist b where  A.TCPCODE =B.TCPCODE and A.LEARNINGCENTERCODE =B.ORGCODE);
          dbms_output.put_line('累加学分EAS_TCP_ExecOnModuleRule' ||  SQL%ROWCOUNT);

          
        
        end if ;
         commit;
       EXCEPTION 
        WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
         rollback;
         RETCODE :='0'; /* 返回未成功标志*/
    END PR_TCP_PUBLISHIMPL;
    
    
    FUNCTION FN_TCP_GETEXECRULEONINIT(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN TYP_IMPLRULE
    IS
     l_typ_implRule TYP_IMPLRULE;
     l_ModuleCreditOfGuid EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type:=0; --指导必修
     l_RequiredCreditOfGuid EAS_TCP_GUIDANCEONRULE.REQUIREDTOTALCREDITS %type:=0;--指导必修总部考试
     l_ModuleCreditOfImpl EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type:=0;    --实施必修
     l_RequiredCreditOfImpl EAS_TCP_GUIDANCEONRULE.REQUIREDTOTALCREDITS %type:=0;--实施必修总部考试
     l_ExecCreditOfImpl EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type:=0;    --实施执行
     l_RequiredExecCreditOfImpl EAS_TCP_GUIDANCEONRULE.REQUIREDTOTALCREDITS %type:=0;--实施执行总部考试
     l_count1 number :=0;
     l_count2 number :=0;
     l_count3 number :=0;
     
    BEGIN
     
     select count(*) into l_count1 from EAS_TCP_GUIDANCEONMODULERULE A where A.TCPCODE =iTCPCODE;
     select count(*) into l_count2 from EAS_TCP_implOnmodulerule A where A.TCPCODE =iTCPCODE and A.SEGMENTCODE =iORGCODE;
     select count(*) into l_count3 from EAS_TCP_implModulecourse A where A.COURSENATURE ='3' and A.ISEXECUTIVECOURSE ='1' and A.TCPCODE =iTCPCODE and A.SEGMENTCODE =iORGCODE;
     DBMS_OUTPUT.PUT_LINE(l_count1||'-'|| l_count2 ||'-'||l_count3 );
     if l_count1>0 then
     select sum(A.CENTERCOMPULSORYCOURSECREDIT +A.SEGMENTCOMPULSORYCOURSECREDIT),sum(A.CENTERCOMPULSORYCOURSECREDIT) 
       into l_ModuleCreditOfGuid,l_RequiredCreditOfGuid  
     from EAS_TCP_GUIDANCEONMODULERULE A where A.TCPCODE =iTCPCODE group by A.TCPCODE; 
     
     DBMS_OUTPUT.PUT_LINE(l_ModuleCreditOfGuid || '-'||l_RequiredCreditOfGuid);
    end if;
    
     if l_count2>0 then
         select sum(A.SCCENTERTOTALCREDITS +A.SCSEGMENTTOTALCREDITS ),sum(A.SCCENTERTOTALCREDITS )
       into l_ModuleCreditOfImpl,l_RequiredCreditOfImpl
       from EAS_TCP_implOnmodulerule a 
     where A.TCPCODE =iTCPCODE and A.SEGMENTCODE =iORGCODE
     group by A.TCPCODE ;
      DBMS_OUTPUT.PUT_LINE(l_ModuleCreditOfImpl || '-'||l_RequiredCreditOfImpl);
     end if;
     
     if l_count3>0 then
     select sum(A.CREDIT ),sum(case when A.EXAMUNITTYPE ='1' then A.CREDIT else 0 end) 
     into l_ExecCreditOfImpl,l_RequiredExecCreditOfImpl
     from EAS_TCP_implModulecourse a 
     where A.COURSENATURE ='3' and A.ISEXECUTIVECOURSE ='1' and A.TCPCODE =iTCPCODE and A.SEGMENTCODE =iORGCODE
     group by A.TCPCODE ;
      DBMS_OUTPUT.PUT_LINE(l_ExecCreditOfImpl || '-'||l_RequiredExecCreditOfImpl);
     end if;
      
    
     l_typ_implRule := new TYP_IMPLRULE(iTCPCODE,l_ModuleCreditOfGuid+l_ModuleCreditOfImpl+l_ExecCreditOfImpl,l_RequiredCreditOfGuid+l_RequiredCreditOfImpl+l_RequiredExecCreditOfImpl);
    
    return l_typ_implRule;
     
     EXCEPTION
      WHEN Others THEN
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     
    END;
    
    -- 计算分部执行性专业规则模块规则初始化
    FUNCTION FN_TCP_GETEXECMODULERULEONINIT(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN COL_MODULERULE 
    IS
    l_col_ModuleRule COL_MODULERULE := COL_MODULERULE();
    cursor cur_module is select a.modulecode,A.MINEXAMCREDITS ,A.MINGRADCREDITS  from eas_tcp_module a where A.TCPCODE =iTCPCODE;
    cur_module_info cur_module%rowtype; -- 定义游标变量
    l_rowCount number;
    l_CreditOfModuleByGUID EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type;
    l_CreditOfRequiredByGUID EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type;
    l_CreditOfModuleByIMPL EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type;
    l_CreditOfRequiredByIMPL EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type;
    l_CreditOfModuleByIMPLEXEC EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type;
    l_CreditOfRequiredByIMPLEXEC EAS_TCP_GUIDANCEONRULE.MODULETOTALCREDITS %type;
    
    BEGIN
      open cur_module;
      loop 
        Fetch cur_module into cur_module_info;
        Exit when cur_module%notfound;
           ----- 处理每个模块内的总分
           ----1.指导性启用模块规则
           select count(*) into l_rowCount from  EAS_TCP_GuidanceOnModuleRule a where A.TCPCODE =iTCPCODE and A.MODULECODE =cur_module_info.modulecode;
           if l_rowCount>0 then
             select (A.CENTERCOMPULSORYCOURSECREDIT +A.SEGMENTCOMPULSORYCOURSECREDIT ),A.CENTERCOMPULSORYCOURSECREDIT into l_CreditOfModuleByGUID,l_CreditOfRequiredByGUID   from EAS_TCP_GuidanceOnModuleRule a where A.TCPCODE =iTCPCODE and A.MODULECODE =cur_module_info.modulecode;
           end if ;
        
            ----2.实施性启用模块规则
           select count(*) into l_rowCount from  EAS_TCP_IMplOnModuleRule a where a.segmentcode=iORGCODE and  A.TCPCODE =iTCPCODE and A.MODULECODE =cur_module_info.modulecode ;
           if l_rowCount>0 then
             select A.SCCENTERTOTALCREDITS+ A.SCCENTERTOTALCREDITS ,A.SCCENTERTOTALCREDITS into l_CreditOfModuleByIMPL,l_CreditOfRequiredByIMPL   from  EAS_TCP_IMplOnModuleRule a where a.segmentcode=iORGCODE and  A.TCPCODE =iTCPCODE and A.MODULECODE =cur_module_info.modulecode ;
           end if ;  
           
             ----3.实施性模块执行课
           select count(*) into l_rowCount from  EAS_TCP_IMplModuleCourse a where a.segmentcode=iORGCODE and  A.TCPCODE =iTCPCODE and A.MODULECODE =cur_module_info.modulecode ;
           if l_rowCount>0 then
             select sum(case when A.ISEXECUTIVECOURSE ='1' then A.CREDIT else 0 end) ,sum(case when A.ISEXECUTIVECOURSE ='1' and A.EXAMUNITTYPE ='1' then A.CREDIT else 0 end) into l_CreditOfModuleByIMPLEXEC,l_CreditOfRequiredByIMPLEXEC   from  EAS_TCP_IMplModuleCourse a where a.segmentcode=iORGCODE and  A.TCPCODE =iTCPCODE and A.MODULECODE =cur_module_info.modulecode ;
           end if ;  
   
             
             
             
           l_col_ModuleRule.extend();
           l_col_ModuleRule(l_col_ModuleRule.count):=TYP_ModuleRule(cur_module_info.modulecode,l_CreditOfModuleByGUID+l_CreditOfModuleByIMPL+l_CreditOfModuleByIMPLEXEC,l_CreditOfRequiredByGUID+l_CreditOfRequiredByIMPL+l_CreditOfRequiredByIMPLEXEC);
      end loop ;
       return l_col_ModuleRule;
      Exception
       when others then
          close cur_module;
      if cur_module%isopen then
        close cur_module;
      end if ;
    
    END;
    
    --执行性专业规则--启用 add liufengshuan modify:libin 20150408
PROCEDURE PR_TCP_ExecutionEnable
(

i_TCPCode in varchar2,--专业规则编码
i_OperatorName in varchar2,--操作人
i_LearningCenterCode in varchar2,--学习中学编码
returnCode out varchar2
)
 IS

 v_batchcode EAS_TCP_Execution.Batchcode%type;--批次
 v_segmentcode EAS_TCP_Execution.segmentcode%type;--分部
 v_ExcState EAS_TCP_Execution.ExcState%Type;
 
BEGIN
   
   returnCode :='1';
   
    --1.更具tcpcode,lea rningcertercode 获取执行性专业规则信息

    select segmentcode,batchcode,ExcState into v_segmentcode,v_batchcode,v_ExcState from EAS_TCP_Execution
    WHERE tcpcode=i_TCPCode and learningcentercode=i_LearningCenterCode;
    
   dbms_output.put_line(i_TCPCode||','||i_LearningCenterCode ||'查出结果为:分部=' ||v_segmentcode || ',批次='||v_batchcode );
   
   if v_ExcState='0' then
   --2.将课程插入到学习中心课程总表中   
       merge into EAS_TCP_LearCentCourse a
       using (
         with t1 as (
             select i_LearningCenterCode LearningCenterCode, courseid from table(PK_TCP.FN_TCP_GetExecModuleCourses(i_TCPCode,v_segmentcode,i_LearningCenterCode))
             union 
             select i_LearningCenterCode LearningCenterCode ,courseid from  EAS_TCP_ConversionCourse a where a.tcpcode=i_TCPCode)
         select * from t1) b
         on  (a.learningcentercode=b.learningcentercode and a.courseid=b.courseid)
          when NOT MATCHED THEN
         insert (SN,SegOrgCode,LearningCenterCode,CourseID,CourseState,CreateTime)
         values(seq_TCP_LearCentCour.nextval,v_segmentcode,b.learningcentercode,b.courseid,1 ,sysdate);
      
         dbms_output.put_line('EAS_TCP_LearCentCourse' ||  SQL%ROWCOUNT);
       
   
   /*
   --修改执行专业规则的状态为启用
   */
       UPDATE EAS_TCP_Execution SET  ExcState=1, Executor=i_OperatorName, ExecuteTime=sysdate 
       WHERE tcpcode=i_TCPCode and learningcentercode=i_LearningCenterCode;
       dbms_output.put_line('EAS_TCP_Execution' ||  SQL%ROWCOUNT || 'Executor'||i_OperatorName);
    
    end if;
    
   commit;
   
   EXCEPTION
     WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
            rollback;
       returnCode :='-0'; /* 返回未成功标志*/
       
       
END PR_TCP_ExecutionEnable;

    --执行性专业规则--批量启用 add liufengshuan (专业规则编码,操作人,学习中学编码,out 返回没有启用成功的tcpcode)
    PROCEDURE PR_TCP_BatchExecutionEnable( i_TCPCodeList in varchar2,i_OperatorName in varchar2,i_LearningCenterCode in varchar2,returnCode out varchar2)
     IS 
    
     v_tcpCode varchar2(20);
     v_ReturnCode varchar2(100);    
     CURSOR myCur is select COLUMN_VALUE from table(splitstr(i_TCPCodeList,','));
     
     BEGIN
     
     --打开游标
       OPEN myCur;
       
       LOOP
       
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
        
           /* --调用单个执行性专业规则-启用的执行存储过程 do */
           
           PR_TCP_ExecutionEnable(v_tcpCode, i_OperatorName, i_LearningCenterCode,v_ReturnCode);
           /*查看返回值*/
           if v_ReturnCode ='0' then
            returnCode := returnCode || v_tcpCode || ',';
           end if ;
           
        END LOOP;
        
        --returnCode:='000000000000000';
        
        --关闭游标
        CLOSE myCur;
       
    END PR_TCP_BatchExecutionEnable;
    
    --更具年度学期,学生类型,专业层次,专业编码获取专业规则编码 liufengshuan
    Function FN_TCP_GetNewTCPCode(i_batchcode varchar2,i_studentype varchar2,i_professionallevel varchar2,i_spycode varchar2) RETURN varchar2
    IS
        v_result varchar2(40):='';
        
        BEGIN
           if i_batchcode is not null then
              v_result:= substr(i_batchcode,-4)||i_studentype||i_professionallevel||i_spycode;
           end if;
           
        return v_result;
    
    END FN_TCP_GetNewTCPCode;
    
    --指导性专业规则管理--复制专业规则--年度学期
   PROCEDURE Pr_TCP_CopyGuidanceTCP(i_BatchCode in EAS_TCP_GUIDANCE.BatchCode%type,i_MAINTAINER IN varchar2,RETCODE out varchar2 )
   IS
     v_iCurBatchCode EAS_TCP_GUIDANCE.BatchCode%type:=i_BatchCode;
    v_iOperater     EAS_TCP_GUIDANCE.Creator %type :=i_MAINTAINER;
-----------------------------------------------    
   v_prevBatchCode EAS_TCP_GUIDANCE.BatchCode%type;--目标学期的上一年度学期
   v_Continue         varchar2(1000) :='OK';
   
   
   BEGIN

    --1.目标学期的上一年度学期
        select BatchCode into v_prevBatchCode from EAS_TCP_RECRUITBATCH Batch
        where Batch.BATCHCODE<v_iCurBatchCode  and rownum<2
        order by Batch.BATCHCODE desc;
        
        dbms_output.put_line(v_iCurBatchCode||'查出结果为:年度学期=' ||v_iCurBatchCode||'-'||v_prevBatchCode );

       if v_prevBatchCode is not null and length(v_prevBatchCode)>0 then
       
        
         --1. 复制到临时表
         insert into TMP_TCP_Guidance (batchcode,tcpcode,PreBatchCode,PreTcpcode)
         select v_iCurBatchCode ,PK_TCP.FN_TCP_GetNewTCPCode(v_iCurBatchCode, g.studenttype, g.professionallevel,g.spycode),batchcode,tcpcode
         from EAS_TCP_Guidance g where g.batchcode=v_prevBatchCode;
         dbms_output.put_line('TMP_TCP_Guidance' ||  SQL%ROWCOUNT);
         
         
         
         
         ---2. 复制 EAS_TCP_Guidance
            insert into EAS_TCP_Guidance
            (
                   TCPCode,BatchCode,TCPName,EducationType,StudentType,ProfessionalLevel
                  ,SpyCode,MinGradCredits,MinExamCredits,ExemptionMaxCredits,SchoolSystem
                  ,DegreeCollegeID,DegreeSemester,Remark,State,CopySourceCode,Creator,CreateTime
                  --,EnableUser,EnableTime
            )
            select    
               b.tcpcode,
               b.BatchCode,
                (select RECRUITBATCHName from EAS_TCP_RECRUITBATCH where batchcode=v_iCurBatchCode)||
                (select dicname  from EAS_Dic_StudentType where diccode=g.studenttype )||
                (select dicname from EAS_Dic_ProfessionalLevel where diccode=g.professionallevel)||
                (select spyname from EAS_Spy_BasicInfo where spycode=g.spycode) tcpnamenew
                ,g.EducationType,g.StudentType,g.ProfessionalLevel,g.SpyCode
                ,g.MinGradCredits,g.MinExamCredits,g.ExemptionMaxCredits,g.SchoolSystem
                ,g.DegreeCollegeID,g.DegreeSemester,g.Remark
                ,0 State
                ,v_prevBatchCode CopySourceCode
                ,v_iOperater
                ,sysdate CreateTime

            from EAS_TCP_Guidance  g inner join TMP_TCP_Guidance b on g.batchcode=b.prebatchcode and g.tcpcode=b.pretcpcode
            and not exists(
                select 1 from EAS_TCP_Guidance where batchcode=b.batchcode and tcpcode=b.tcpcode 
            );
            
              dbms_output.put_line('EAS_TCP_Guidance' ||  SQL%ROWCOUNT);
  
            
        --3.复制EAS_TCP_GuidanceOnRule
            insert into EAS_TCP_GuidanceOnRule
             ( SN,BatchCode,TCPCode,TotalCredits,ModuleTotalCredits,RequiredTotalCredits)
             select  seq_TCP_GuidOnRule.nextval SN, 
               b.BatchCode,
                b.tcpcode, 
                etgr.TotalCredits,
                etgr.ModuleTotalCredits,
                etgr.RequiredTotalCredits
             from EAS_TCP_GuidanceOnRule etgr
             inner join EAS_TCP_Guidance etg on etgr.tcpcode=etg.tcpcode  
             inner join TMP_TCP_Guidance b on etg.batchcode=b.prebatchcode and etg.tcpcode=b.preTcpcode
              where 
            not exists(select * from EAS_TCP_GuidanceOnRule where batchcode=b.batchcode and tcpcode=b.tcpcode); 
                       
             dbms_output.put_line('EAS_TCP_GuidanceOnRule' ||  SQL%ROWCOUNT);
                
        ---4. 复制EAS_TCP_Module
            insert into EAS_TCP_Module
             ( SN,BatchCode,TCPCode,ModuleCode,MinGradCredits,MinExamCredits,CreateTime )
              select
                sys_guid() SN,
                --目标学期
                etg.BatchCode,
                etg.tcpcode, 
                --etm.tcpcode,
                etm.ModuleCode,
                etm.MinGradCredits,
                etm.MinExamCredits,
                sysdate CreateTime
                
             from EAS_TCP_Module etm
            inner join TMP_TCP_Guidance etg on etm.batchcode=etg.prebatchcode and etm.tcpcode=etg.pretcpcode 
                    --目标学期的上一个学期
            where 
         not exists(
                select 1 from EAS_TCP_Module where batchcode=etg.batchcode and tcpcode=etg.tcpcode  );
  
             
                dbms_output.put_line('EAS_TCP_Module' ||  SQL%ROWCOUNT);

        --5. EAS_TCP_ModuleCourses
            insert into EAS_TCP_ModuleCourses
             ( SN,ModuleCode,BatchCode,TCPCode,CourseID,CourseName,CourseNature,Credit,OrgCode,OpenedSemester,ExamUnitType,IsExtendedCourse,IsDegreeCourse,IsSimilar,CreateTime )
               select
                sys_guid() SN,
                etmc.ModuleCode,
                --目标学期
                etg.BatchCode,
                --etmc.BatchCode,
               etg.tcpcode,
                etmc.CourseID,
                etmc.CourseName,
                etmc.CourseNature,
                etmc.Credit,
                etmc.OrgCode,
                etmc.OpenedSemester,
                etmc.ExamUnitType,
                etmc.IsExtendedCourse,
                etmc.IsDegreeCourse,
                etmc.IsSimilar,
                sysdate CreateTime
                
             from EAS_TCP_ModuleCourses etmc
            inner join TMP_TCP_Guidance etg on etmc.tcpcode=etg.pretcpcode
            --目标学期的上一个学期
            where not exists(
                select 1 from EAS_TCP_ModuleCourses where batchcode=etg.batchcode and tcpcode=etg.tcpcode and courseid=etmc.courseid
            );
                   dbms_output.put_line('EAS_TCP_ModuleCourses' ||  SQL%ROWCOUNT);
            
            
          --6. 复制 EAS_TCP_GuidanceOnModuleRule
            insert into EAS_TCP_GuidanceOnModuleRule
             ( OnRuleID,BatchCode,TCPCode,ModuleCode,TotalCredits,RequiredTotalCredits,CenterCompulsoryCourseCredit,SegmentCompulsoryCourseCredit )
               select
               seq_TCP_GuidModuRule.nextval OnRuleID,
                --目标学期
                etg.BatchCode,
                etg.TCPCode,
                etgm.ModuleCode,
                etgm.TotalCredits,
                etgm.RequiredTotalCredits,
                etgm.CenterCompulsoryCourseCredit,
                etgm.SegmentCompulsoryCourseCredit
                
             from EAS_TCP_GuidanceOnModuleRule etgm
            inner  join TMP_TCP_Guidance etg on etgm.tcpcode=etg.pretcpcode
                    --目标学期的上一个学期
            where not exists(
                select 1 from EAS_TCP_GuidanceOnModuleRule where batchcode=etg.BatchCode and tcpcode=etg.tcpcode 
            );
                    
                dbms_output.put_line('EAS_TCP_GuidanceOnModuleRule' ||  SQL%ROWCOUNT);


        --7.相似课 EAS_TCP_SimilarCourses
            insert into EAS_TCP_SimilarCourses
             ( SN,BatchCode,TCPCode,ModuleCode,CourseID,SimilarGroup,CreateTime )
           select
                seq_TCP_SimilarCourses.nextval SN,
                --目标学期
                etg.BatchCode,
                etg.TCPCode,
                etsc.ModuleCode,
                etsc.CourseID,
                etsc.SimilarGroup,
                sysdate CreateTime
                
             from EAS_TCP_SimilarCourses etsc
            inner join TMP_TCP_Guidance etg on etsc.tcpcode=etg.pretcpcode
            --目标学期的上一个学期
            where  not exists(
                    select 1 from EAS_TCP_SimilarCourses where batchcode=etg.BatchCode and tcpcode=etg.tcpcode
                );
                
            dbms_output.put_line('EAS_TCP_SimilarCourses' ||  SQL%ROWCOUNT);   
        
         --8.补修课   
           insert into EAS_TCP_ConversionCourse
             ( SN,BatchCode,TCPCode,CourseID,SuggestOpenSemester,ExamunitType,CreateTime )
                           select
                sys_guid() SN,
                --目标学期
                etg.BatchCode,
                etg.TCPCode,
                etcc.CourseID,
                etcc.SuggestOpenSemester,
                etcc.ExamunitType,
                sysdate CreateTime
             from EAS_TCP_ConversionCourse etcc
            inner join TMP_TCP_Guidance etg on etcc.tcpcode=etg.pretcpcode
            --目标学期的上一个学期
            where  not exists(
                    select 1 from EAS_TCP_ConversionCourse where batchcode=etg.BatchCode and tcpcode=etg.tcpcode
                );
        
        dbms_output.put_line('EAS_TCP_ConversionCourse' ||  SQL%ROWCOUNT);
        
        end if;
         RETCODE :=v_Continue;
        dbms_output.put_line( 'RETCODE' || RETCODE );
    commit;
         
      EXCEPTION

         WHEN OTHERS THEN
         v_Continue:=SQLERRM;
          RETCODE :=v_Continue;
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||v_Continue);
         rollback;


    END Pr_TCP_CopyGuidanceTCP;
    
 
   ---执行性专业规则--延用课程
    PROCEDURE PR_TCP_ExecDeferCourse(i_TCPCode IN EAS_TCP_Execution.TCPCODE%TYPE ,i_LearningCenterCode in EAS_TCP_Execution.LearningCenterCode%TYPE,RETCODE OUT varchar2)  
    IS
    
     v_batchcode EAS_TCP_Execution.Batchcode%type;--批次
     v_segmentcode EAS_TCP_Execution.segmentcode%type;--分部
     v_ExcState EAS_TCP_Execution.ExcState%Type;
     v_professionallevel EAS_TCP_Execution.Professionallevel%Type;--专业层次
     v_studenttype EAS_TCP_Execution.studenttype%Type;--学生类型
     v_spycode EAS_TCP_Execution.spycode%type;--专业编码
     v_prevBatchCode EAS_TCP_RECRUITBATCH.BATCHCODE%type;--目标学期的上一年度学期
     v_prevTcpCode EAS_TCP_Execution.TCPCode%Type;---历史专业规则
    
    begin
    
        --1.根据tcpcode,learningcertercode 获取执行性专业规则信息

    select segmentcode,batchcode,ExcState,studenttype,professionallevel,spycode into v_segmentcode,v_batchcode,v_ExcState,v_studenttype,v_professionallevel,v_spycode from EAS_TCP_Execution
    where tcpcode=i_TCPCode and learningcentercode=i_LearningCenterCode;
    
    dbms_output.put_line(i_TCPCode||','||i_LearningCenterCode ||'查出结果为:分部=' ||v_segmentcode || ',批次='||v_batchcode );
    
    --未启用进行设置延用课程
    
     if v_ExcState='0' then
    
        --1.上一年度学期及专业规则
        select batchcode,tcpcode into v_prevBatchCode,v_prevTcpCode from EAS_TCP_Execution 
        where studenttype=v_studenttype and professionallevel=v_professionallevel and learningcentercode=i_LearningCenterCode and spycode=v_spycode
        and batchcode<v_batchcode and rownum<2  order by batchcode desc;
        
        dbms_output.put_line(v_professionallevel||','||v_studenttype ||',' ||v_spycode || ','||'历史学期:'||v_prevBatchCode||',历史专业规则:'||v_prevTcpCode );
        
        if v_prevBatchCode is not null and length(v_prevBatchCode)>0 and v_prevTcpCode is not null and length(v_prevTcpCode)>0 then
      
            --2  将历史学期中的课程加入到新年度学期的执行性专业规则模块课程中 
            insert into EAS_TCP_ExecModuleCourse
            (
                SN,Batchcode,TcpCode,Segmentcode,learningcentercode,modulecode,courseId,coursenature,Examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,CreateTime
            )
            select 
                sys_guid() SN,v_batchcode Batchcode,i_TCPCode TcpCode,Segmentcode,learningcentercode,modulecode,courseId,coursenature,
                Examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,sysdate CreateTime
            from EAS_TCP_ExecModuleCourse a
                --历史批次,专业规则
            where batchcode=v_prevBatchCode and tcpcode=v_prevTcpCode and a.learningcentercode=i_LearningCenterCode
                and exists(  select 1 from EAS_TCP_ImplModuleCourse where coursenature=3 and  batchcode=v_batchcode  and segmentcode=v_segmentcode and courseId=a.courseId) 
                and not exists(select 1 from EAS_TCP_ExecModuleCourse c where C.TCPCODE =i_TCPCode and A.COURSEID =c.courseid and a.segmentcode=c.segmentcode 
                   and C.LEARNINGCENTERCODE=a.learningcentercode);
            
            dbms_output.put_line('EAS_TCP_ExecModuleCourse' ||  SQL%ROWCOUNT);  
        
          --3.累计学分
              
            update EAS_TCP_ExecOnRule a 
            set (moduletotalcredits,totalcredits) =( 
                select sum(credit)+moduletotalcredits, sum(case when examunittype='1' then credit else 0 end)+totalcredits 
                from EAS_TCP_ExecModuleCourse  b 
                where b.tcpcode=i_TCPCode and b.learningcentercode=i_LearningCenterCode and  A.TCPCODE =b.tcpcode  
                group by b.learningcentercode,b.tcpcode 
            )  
            where A.TCPCODE =i_TCPCode and A.learningcentercode =i_LearningCenterCode;
            dbms_output.put_line('EAS_TCP_ExecOnRule' ||  SQL%ROWCOUNT);
          
          
            update EAS_TCP_ExecOnModuleRule a 
            set (ModuleTotalCredits,RequiredTotalCredits) =( 
                select nvl(sum(credit),0)+ moduletotalcredits, 
                 sum(case when examunittype='1' then credit else 0 end)+ RequiredTotalCredits
                from EAS_TCP_ExecModuleCourse  b 
                where b.tcpcode=i_TCPCode and b.learningcentercode=i_LearningCenterCode and  A.TCPCODE =b.tcpcode and a.modulecode=b.modulecode  
                group by b.learningcentercode,b.tcpcode,b.modulecode 
            )  
            where A.TCPCODE =i_TCPCode and A.learningcentercode =i_LearningCenterCode;
            
            dbms_output.put_line('EAS_TCP_ExecOnModuleRule' ||  SQL%ROWCOUNT);
          
           RETCODE:='1';
          
        end if;

     end if;
   
    commit; 
    
   
    --
    EXCEPTION

         WHEN OTHERS THEN
         
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
         RETCODE:='0';
            rollback;
    
    end PR_TCP_ExecDeferCourse;
    
    
     
        ---执行性专业规则--批量延用课程
    PROCEDURE PR_TCP_BatchExecDeferCourse(i_TCPCodeList IN varchar2 ,i_LearningCenterCode in EAS_TCP_Execution.LearningCenterCode%TYPE,RETCODE OUT varchar2)
    IS
     v_tcpCode varchar2(20);
     v_ReturnCode varchar2(100);    
     CURSOR myCur is select COLUMN_VALUE from table(splitstr(i_TCPCodeList,','));
     
     BEGIN
     
     --打开游标
       OPEN myCur;
       
       LOOP
       
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
        
           /* --调用单个执行性专业规则-启用的执行存储过程 do */
           
           PR_TCP_ExecDeferCourse(v_tcpCode,i_LearningCenterCode,v_ReturnCode);
           /*查看返回值*/
           if v_ReturnCode ='0' then
            RETCODE := RETCODE || v_tcpCode || ',';
           end if ;
           
        END LOOP;
        
        --关闭游标
        CLOSE myCur;
    
    
    END PR_TCP_BatchExecDeferCourse;

    


    --学习中心-学期开设课程管理-- 复制学期开设课程功能 add by liufengshuan
    PROCEDURE PR_TCP_CopyLCenterSemeCourse(i_LearingCenterCode in EAS_TCP_LearCentSemeCour.LearningCenterCode%Type,i_frombatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,i_targetBatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,returnCode out varchar2)
    IS
    Begin
        
    DBMS_OUTPUT.PUT_LINE('学习中心:'||i_LearingCenterCode||'源年度学期:'||i_frombatchcode||'目标年度学期:'||i_targetBatchcode);
    
    if length(i_LearingCenterCode)>0 and length(i_frombatchcode)>0 and length(i_targetBatchcode)>0 then
        
        Insert into EAS_TCP_LearCentSemeCour
        ( SN,BatchCode,OrgCode,LearningCenterCode,CourseId,Semester,IsExistTCP,CreateTime ) 
        select seq_TCP_LearCentSemeCour.NextVal SN,i_targetBatchcode BatchCode,d.orgCode,d.learningCenterCode,d.CourseID,d.Semester,
        (case d.isexisttcp when 0 then 
                (select case when count(*)>0 then 1 else 0 end from 
                --V_TCP_IMPLCOURSE v
                (
                   SELECT eti.BatchCode,eti.TCPCode,eti.OrgCode,etmc.CourseID,1 AS IsExistTCP,etmc.OpenedSemester,eti.ImpState
                     FROM EAS_TCP_ModuleCourses etmc
                     INNER JOIN EAS_TCP_Implementation eti ON eti.TCPCode = etmc.TCPCode  WHERE etmc.CourseNature = 1
                   UNION
                   SELECT eti.BatchCode,eti.TCPCode,eti.OrgCode,etic.CourseID,1 AS IsExistTCP,etmc.OpenedSemester,eti.ImpState
                     FROM EAS_TCP_ImplModuleCourse etic
                     LEFT JOIN EAS_TCP_Implementation eti  ON etic.TCPCode = eti.TCPCode AND etic.SegmentCode = eti.OrgCode
                     LEFT JOIN EAS_TCP_ModuleCourses etmc  ON etic.CourseID = etmc.CourseID AND etic.TCPCode = etmc.TCPCode AND etic.ModuleCode = etmc.ModuleCode
                   UNION
                   SELECT eti.BatchCode, eti.TCPCode,eti.OrgCode,etcc.CourseID,0 AS IsExistTCP,etcc.SuggestOpenSemester OpenedSemester,eti.ImpState
                     FROM EAS_TCP_Implementation eti
                     INNER JOIN EAS_TCP_ConversionCourse etcc ON eti.TCPCode = etcc.TCPCode
                ) v
                    where 1=1 AND v.OrgCode = d.orgCode  AND v.CourseID =d.courseID  
                 and v.batchcode>=i_frombatchcode 
                 and v.batchcode<=i_targetBatchcode
                ) 
          else d.isexisttcp end
        ) isExistTCP1,
        sysdate CreateTime
        from (

            --第一部分
          SELECT a.BatchCode,a.OrgCode ,a.learningCenterCode,a.CourseID,Semester,IsExistTcp 
          FROM EAS_TCP_LearCentSemeCour a 
            left join  EAS_TCP_SegmentCourses etsc on a.orgcode=etsc.orgcode and a.courseID=etsc.courseID
            WHERE etsc.coursestate=1  AND a.learningcentercode=i_LearingCenterCode  AND a.batchcode=i_frombatchcode--源年度学期
           
          union
           --- 第二部分互斥源数据
          select c.BatchCode,c.OrgCode ,c.learningCenterCode,ecmc.NewCourseCode CourseID,Semester,IsExistTcp from (
                --1.-停用,必修课或省必修
                SELECT   b.BatchCode,b.OrgCode ,b.learningCenterCode,b.CourseID,Semester,IsExistTcp 
                FROM EAS_TCP_LearCentSemeCour b 
                    inner join  EAS_TCP_SegmentCourses etsc on b.orgcode=etsc.orgcode and b.courseID=etsc.courseID
                    inner join EAS_TCP_ModuleCourses etmc on b.orgcode=etmc.orgcode and b.courseid=etmc.courseid and b.batchcode=etmc.batchcode
                    WHERE etsc.coursestate=0 and (etmc.courseNature=1 or etmc.coursenature=2)  --停用,必修课或省必修
                    AND b.learningcentercode=i_LearingCenterCode  AND b.batchcode=i_frombatchcode--源年度学期 
             ) c
            left join EAS_Course_MutexCourses ecmc on c.CourseID=ecmc.oldCourseCode    
        ) d
        --目标年度学期下不存在则加入
        where not exists(
            select * from EAS_TCP_LearCentSemeCour f where  f.BatchCode=i_targetBatchcode 
            and F.learningCenterCode=d.learningCenterCode and f.CourseId=d.CourseId 
        );
        
        dbms_output.put_line('EAS_TCP_LearCentSemeCour' ||  SQL%ROWCOUNT);
        
        returnCode:='1';
    
    end if;
    
    commit;
        --
    EXCEPTION

         WHEN OTHERS THEN
         
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
         returnCode:='0';
            rollback;
    
    
    END PR_TCP_CopyLCenterSemeCourse;
    
    --学习中心-学期开设课程管理-- 按学期开设课程功能 add by liufengshuan
    PROCEDURE PR_TCP_LCenterAddSemeCourse(i_LearingCenterCode in EAS_TCP_LearCentSemeCour.LearningCenterCode%Type,i_frombatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,returnCode out varchar2)
    IS
    v_segmentcode  EAS_ORG_BASICINFO.ORGANIZATIONCODE %type;
    Begin
    
    if length(i_LearingCenterCode)>0 and length(i_frombatchcode)>0 then
    
       v_segmentcode := substr(i_LearingCenterCode,1,3);
       merge into EAS_TCP_LearCentSemeCour aa
       using (with t0 as (select batchcode from  EAS_TCP_RECRUITBATCH 
            where BATCHCODE<=i_frombatchcode 
            and rownum<=8
            order by BATCHCODE desc )
            ,t01 as (select tcpcode from EAS_TCP_Execution where exists(select * from t0 where batchcode= EAS_TCP_Execution.batchcode))
      -- select * from t01                   
         ,t1 as (
            select distinct m.CourseID,m.OpenedSemester Semester from EAS_TCP_ModuleCourses m
            where courseNature=1 and exists(select * from t01 where tcpcode=m.tcpcode) )
       ,t2 as(     
            select distinct et.CourseID,ETM.OPENEDSEMESTER Semester from EAS_TCP_ImplModuleCourse et
            inner join EAS_TCP_ModuleCourses etm on ET.TCPCODE=etm.TcpCode and et.courseid=etm.courseid
            where et.CourseNature=2  and et.segmentcode=v_segmentcode and exists(select * from t01 where tcpcode=et.tcpcode))
       ,t3 as (            
            select distinct CourseID,SuggestOpenSemester Semester from EAS_TCP_ExecModuleCourse 
            where CourseNature=3 and learningcentercode=i_LearingCenterCode and exists(select * from t01 where tcpcode=EAS_TCP_ExecModuleCourse.tcpcode))
        ,t4 as ( select * from t1
                 union 
                 select * from t2
                 union 
                 select * from t3)
         select i_frombatchcode as batchcode,v_segmentcode segmentcode,i_LearingCenterCode learningcentercode,courseid,Semester,'1' IsExistTCP ,sysdate CreateTime from t4 
         where exists(select * from EAS_TCP_LearCentCourse 
         where courseid=t4.courseid and learningcentercode=i_LearingCenterCode and CourseState='1' ) ) bb
         on (aa.batchcode=bb.batchcode and aa.learningcentercode=bb.learningcentercode and aa.courseid=bb.courseid)
          WHEN NOT MATCHED THEN
           insert ( 
                 SN                                 ,BatchCode    ,OrgCode      ,LearningCenterCode   ,CourseId   ,Semester,IsExistTCP,CreateTime)
           values(seq_TCP_LearCentSemeCour.nextval, bb.batchcode,bb.segmentcode,bb.learningcentercode,bb.courseid,bb.Semester,bb.IsExistTCP,bb.CreateTime);
           
           
          
    
     dbms_output.put_line('PR_TCP_LCenterAddSemeCourse:EAS_TCP_LearCentSemeCour' ||  SQL%ROWCOUNT);
    
    returnCode:='1';
    
    end if;
    
    commit;
    
        EXCEPTION

         WHEN OTHERS THEN
         
         DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
         returnCode:='0';
            rollback;
    
    
    END PR_TCP_LCenterAddSemeCourse;
    
    
    --分部--:分部学期开设课程管理-- 复制学期开设课程 复制选中年度学期分部课程到指定的学期
    PROCEDURE Pr_TCP_CopySegmSemeOpenCourse(i_orgCode in varchar,i_frombatchcode in varchar,i_targetBatchcode in varchar,returnCode out varchar2)
    IS
    
    v_iSegmentCode     EAS_ORG_BASICINFO.ORGANIZATIONCODE%type  :=i_orgCode ;
    v_iSourceBatchCode EAS_TCP_SEGMSEMECOURSES.YEARTERM%type   :=i_frombatchcode;
    v_iTargetBatchCode EAS_TCP_SEGMSEMECOURSES.YEARTERM%type   :=i_targetBatchcode;
    v_iOperater         EAS_EXMM_SUBJECTPLAN.MAINTAINER %type :='libin';
 

 BEGIN
 
           --step 1: 正常的启用的
     INSERT INTO EAS_TCP_SegmSemeCourses 
         (SN          ,YearTerm,OrgCode,CourseID,Semester,IsExistTCP,CreateTime)
         
     with t1 as (select v_iTargetBatchCode yearterm,v_iSegmentCode orgcode, a.courseid,Semester from EAS_TCP_SegmentCourses a inner join EAS_TCP_SegmSemeCourses b 
     on A.COURSEID =B.COURSEID and A.ORGCODE =B.ORGCODE 
     where B.YEARTERM =v_iSourceBatchCode and A.COURSESTATE ='1' and a.orgcode=v_iSegmentCode)
     --------
     select sys_guid(), yearterm,orgcode,courseid,semester,0         ,sysdate from t1 
     where  not exists(select * from EAS_TCP_SegmSemeCourses where yearterm=t1.yearterm and orgcode=t1.orgcode and courseid=t1.courseid);
     
      dbms_output.put_line('step1:EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
    
     --select * from EAS_TCP_SegmSemeCourses where yearterm='v_iTargetBatchCode' and orgcode=v_iSegmentCode
      
     
            --step 1: 正常的启用的
     INSERT INTO EAS_TCP_SegmSemeCourses 
         (SN,YearTerm,OrgCode,CourseID,Semester,IsExistTCP,CreateTime)
     with t2 as (select a.courseid,Semester from EAS_TCP_SegmentCourses a inner join EAS_TCP_SegmSemeCourses b 
     on A.COURSEID =B.COURSEID and A.ORGCODE =B.ORGCODE 
     where B.YEARTERM =v_iSourceBatchCode and A.COURSESTATE ='0' and a.orgcode=v_iSegmentCode)
     ,t3 as (select v_iTargetBatchCode yearterm,v_iSegmentCode orgcode, a.tcpcode,t2.semester from EAS_TCP_ModuleCourses a inner join EAS_TCP_MutexCourses b on a.tcpcode=b.tcpcode and a.courseid=b.courseid
     inner join t2 on a.courseid=t2.courseid
     where a.coursenature='1' )  
     ----------------
     select sys_guid(), t3.yearterm,t3.orgcode,b.courseid,t3.semester,0,sysdate from t3 inner join EAS_TCP_MutexCourses b on t3.tcpcode=b.tcpcode 
     where not exists(select * from t2 where courseid=b.courseid ) 
     and not exists(select * from EAS_TCP_SegmSemeCourses where yearterm=t3.yearterm and orgcode=t3.orgcode and courseid=b.courseid);
      dbms_output.put_line('step2:EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
     ---------------------------------------
      INSERT INTO EAS_TCP_SegmSemeCourses 
         (SN,YearTerm,OrgCode,CourseID,Semester,IsExistTCP,CreateTime)
     with t2 as (select a.courseid,Semester from EAS_TCP_SegmentCourses a inner join EAS_TCP_SegmSemeCourses b 
     on A.COURSEID =B.COURSEID and A.ORGCODE =B.ORGCODE 
     where B.YEARTERM =v_iSourceBatchCode and A.COURSESTATE ='0' and a.orgcode=v_iSegmentCode)
     ,t4 as (select v_iTargetBatchCode yearterm,v_iSegmentCode orgcode,a.tcpcode,t2.semester from EAS_TCP_ImplModuleCourse a inner join EAS_TCP_MutexCourses b on a.tcpcode=b.tcpcode and a.courseid=b.courseid
     inner join t2 on a.courseid=t2.courseid
     where a.coursenature='2' and A.SEGMENTCODE =v_iSegmentCode )
     -----------------
     select sys_guid(), t4.yearterm,t4.orgcode,b.courseid,t4.semester,0,sysdate from t4 inner join EAS_TCP_MutexCourses b on t4.tcpcode=b.tcpcode 
     where not exists(select * from t2 where courseid=b.courseid ) 
     and not exists(select * from EAS_TCP_SegmSemeCourses where yearterm=t4.yearterm and orgcode=t4.orgcode and courseid=b.courseid);
      dbms_output.put_line('step2:EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
       ----- step 4: update isexistTCP
       
    update EAS_TCP_SegmSemeCourses set IsExistTCP=1
    where exists(select * from   EAS_TCP_ModuleCourses where batchcode=v_iTargetBatchCode and coursenature='1' and courseid=EAS_TCP_SegmSemeCourses.courseid)
      or 
    exists(select * from EAS_TCP_ImplModuleCourse where batchcode=v_iTargetBatchCode and segmentcode=v_iSegmentCode and courseid=EAS_TCP_SegmSemeCourses.courseid)
    and yearterm=v_iTargetBatchCode and orgcode=v_iSegmentCode;
       
      dbms_output.put_line('step4:update EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
    returnCode:='0';
     commit;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     returnCode:='1';
       rollback;
    
 END Pr_TCP_CopySegmSemeOpenCourse;
    
    
     --分部---分部学期开设课程管理----按学期开设
    PROCEDURE Pr_TCP_AddSegmSemeCoursByTerm(i_orgCode in varchar,i_yearTerm in varchar,returnCode out varchar2)
    IS
     
    v_iSegmentCode     EAS_ORG_BASICINFO.ORGANIZATIONCODE%type  :=i_orgCode ;
    v_iTargetBatchCode EAS_TCP_SEGMSEMECOURSES.YEARTERM%type   :=i_yearTerm;

    Begin
    
    
  
           --step 1:add 总部必修课且未停用的
           
      --     select * from eas_tcp_recruitbatch where rownum<9 order by batchcode desc 
           
           ---前8学期，有专业规则设置的课程
          INSERT INTO EAS_TCP_SegmSemeCourses 
         (SN          ,YearTerm,OrgCode,CourseID,IsExistTCP,CreateTime)
       with t1 as (select * from eas_tcp_recruitbatch a  where rownum<9 order by batchcode desc)
       ,tcp as (select tcpcode,orgcode from EAS_TCP_Implementation a inner join t1 on a.batchcode=t1.batchcode where a.orgcode=v_iSegmentCode)
       ,t2 as (select courseid from EAS_TCP_ModuleCourses a1 inner join tcp  on a1.tcpcode=tcp.tcpcode where a1.coursenature='1' 
          and exists(select * from EAS_TCP_SegmentCourses where courseid= a1.courseid and coursestate='1')
       union 
       select courseid from EAS_TCP_ImplModuleCourse a2 inner join tcp  on a2.tcpcode=tcp.tcpcode and A2.SEGMENTCODE =tcp.orgcode 
         and exists(select * from EAS_TCP_SegmentCourses where courseid= a2.courseid and coursestate='1')
       )
       ,t3 as (select distinct v_iTargetBatchCode yearterm,v_iSegmentCode orgcode,courseid from t2 )
       select sys_guid(), yearterm,orgcode,courseid,'1',sysdate from t3 where not exists(select * from EAS_TCP_SegmSemeCourses where yearterm=t3.yearterm and orgcode=t3.orgcode and courseid=t3.courseid);
         dbms_output.put_line('step1:EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
    
         -----前8学期，停用的有专业规则设置的课程
            INSERT INTO EAS_TCP_SegmSemeCourses 
         (SN          ,YearTerm,OrgCode,CourseID,IsExistTCP,CreateTime)  
        with t1 as (select * from eas_tcp_recruitbatch where rownum<9 order by batchcode desc) 
       ,tcp as (select a.tcpcode,a.orgcode from EAS_TCP_Implementation a inner join t1 on a.batchcode=t1.batchcode where a.orgcode=v_iSegmentCode)
       ,t2 as (select a1.tcpcode,a1.courseid from EAS_TCP_ModuleCourses a1 inner join tcp  on a1.tcpcode=tcp.tcpcode where a1.coursenature='1' 
       and exists(select * from EAS_TCP_SegmentCourses where courseid= a1.courseid and coursestate='0')
       union 
       select a2.tcpcode,a2.courseid from EAS_TCP_ImplModuleCourse a2 inner join tcp  on a2.tcpcode=tcp.tcpcode and a2.segmentcode=tcp.orgcode 
       and exists(select * from EAS_TCP_SegmentCourses where courseid= a2.courseid and coursestate='0'))
       ,t3 as (select distinct tcpcode ,courseid from t2)
       ,t4 as (select mutexGroup from EAS_TCP_MutexCourses a where exists(select * from t3 where tcpcode=a.tcpcode and courseid=a.courseid))
       ,t5 as (select distinct v_iTargetBatchCode yearterm,v_iSegmentCode orgcode,courseid from EAS_TCP_MutexCourses  where 
                 exists(select * from t4 where mutexgroup=EAS_TCP_MutexCourses.mutexgroup) 
                 and not exists(select * from t3 where courseid=EAS_TCP_MutexCourses.courseid)
              )
       select  sys_guid(), yearterm,orgcode,courseid,'1',sysdate from t5  where not exists(select * from EAS_TCP_SegmSemeCourses where yearterm=t5.yearterm and orgcode=t5.orgcode and courseid=t5.courseid); 
           dbms_output.put_line('step2:EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
         
                 
       -----补修课程处理
           INSERT INTO EAS_TCP_SegmSemeCourses 
         (SN          ,YearTerm,OrgCode,CourseID,IsExistTCP,CreateTime)  
        with t1 as (select * from eas_tcp_recruitbatch where rownum<9 order by batchcode desc) 
        ,tcp as (select a.tcpcode,a.orgcode from EAS_TCP_Implementation a inner join t1 on a.batchcode=t1.batchcode where a.orgcode=v_iSegmentCode)
       ,t2 as (select  distinct v_iTargetBatchCode yearterm,v_iSegmentCode orgcode,a1.courseid from EAS_TCP_ConversionCourse a1 inner join tcp on a1.tcpcode=tcp.tcpcode )
        select  sys_guid(), yearterm,orgcode,courseid,'1',sysdate from t2  where not exists(select * from EAS_TCP_SegmSemeCourses where yearterm=t2.yearterm and orgcode=t2.orgcode and courseid=t2.courseid); 
        dbms_output.put_line('step3:EAS_TCP_SegmSemeCourses' ||  SQL%ROWCOUNT);
    
       
  returnCode:='1';
    commit;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     returnCode:='0';
        rollback;
    
    END Pr_TCP_AddSegmSemeCoursByTerm;
   
    
----返回执行规则规则模块课程
      FUNCTION FN_TCP_GETEXECMODULECOURSE(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iLEARNINGCENTERCODE in EAS_TCP_EXECUTION.LEARNINGCENTERCODE%type , iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN COL_EXECMODULECOURSE
     IS
     l_col_ExecModuleCourse COL_EXECMODULECOURSE := COL_EXECMODULECOURSE();
     cursor cur_GuidModuleCourse is  SELECT A.MODULECODE ,A.COURSEID ,A.CREDIT ,A.OPENEDSEMESTER , B.STATE,A.EXAMUNITTYPE FROM EAS_TCP_ModuleCourses a inner join EAS_Course_basicinfo b on a.courseid=b.courseid where a.CourseNature = 1 and A.TCPCODE =iTCPCODE;
     cur_GuidmoduleCourse_info cur_GuidModuleCourse%rowtype; -- 定义游标变量
     cursor cur_ImplModuleCourse is  SELECT A.MODULECODE ,A.COURSEID ,A.CREDIT ,c.OPENEDSEMESTER , B.STATE,A.EXAMUNITTYPE  
        FROM EAS_TCP_ImplModuleCourse a inner join EAS_Course_basicinfo b on a.courseid=b.courseid 
        inner join EAS_TCP_ModuleCourses c on a.modulecode=c.modulecode and a.courseid=c.courseid and a.tcpcode=c.tcpcode
        where a.CourseNature = 2 and A.TCPCODE =iTCPCODE and a.segmentcode=iORGCODE;
     cur_ImplModuleCourse_info cur_ImplModuleCourse%rowtype; -- 定义游标变量
     
     cursor cur_ExecModuleCourse is SELECT A.MODULECODE ,A.COURSEID ,A.CREDIT ,c.OPENEDSEMESTER , B.STATE,A.EXAMUNITTYPE,a.coursenature    
        FROM EAS_TCP_ExecModuleCourse a inner join EAS_Course_basicinfo b on a.courseid=b.courseid 
        inner join EAS_TCP_ModuleCourses c on a.modulecode=c.modulecode and a.courseid=c.courseid and a.tcpcode=c.tcpcode
        where A.TCPCODE =iTCPCODE and A.LEARNINGCENTERCODE =iLEARNINGCENTERCODE; 

     cur_ExecModuleCourse_info cur_ExecModuleCourse%rowtype; -- 定义游标变量
      
     
    BEGIN
      open cur_GuidModuleCourse;
      loop 
        Fetch cur_GuidmoduleCourse into cur_GuidmoduleCourse_info;
        Exit when cur_GuidModuleCourse%notfound;
        l_col_ExecModuleCourse.extend();
        l_col_ExecModuleCourse(l_col_ExecModuleCourse.count):=TYP_EXECMODULECOURSE(cur_GuidmoduleCourse_info.courseid,cur_GuidmoduleCourse_info.modulecode,cur_GuidmoduleCourse_info.credit,cur_GuidmoduleCourse_info.state,cur_GuidmoduleCourse_info.OPENEDSEMESTER,1,cur_GuidmoduleCourse_info.EXAMUNITTYPE);
       end loop;
        open cur_ImplModuleCourse;
       loop
        Fetch cur_ImplModuleCourse into cur_ImplModuleCourse_info;
        Exit when cur_ImplModuleCourse%notfound;
          l_col_ExecModuleCourse.extend();
        l_col_ExecModuleCourse(l_col_ExecModuleCourse.count):=TYP_EXECMODULECOURSE(cur_ImplModuleCourse_info.courseid,cur_ImplModuleCourse_info.modulecode,cur_ImplModuleCourse_info.credit,cur_ImplModuleCourse_info.state,cur_ImplModuleCourse_info.OPENEDSEMESTER,2,cur_ImplModuleCourse_info.EXAMUNITTYPE);
      
       end loop; 
       
              open cur_ExecModuleCourse;
       loop
        Fetch cur_ExecModuleCourse into cur_ExecModuleCourse_info;
        Exit when cur_ExecModuleCourse%notfound;
          l_col_ExecModuleCourse.extend();
        l_col_ExecModuleCourse(l_col_ExecModuleCourse.count):=TYP_EXECMODULECOURSE(cur_ExecModuleCourse_info.courseid,cur_ExecModuleCourse_info.modulecode,cur_ExecModuleCourse_info.credit,cur_ExecModuleCourse_info.state,cur_ExecModuleCourse_info.OPENEDSEMESTER,cur_ExecModuleCourse_info.coursenature,cur_ExecModuleCourse_info.EXAMUNITTYPE);
      
       end loop; 
      
        return l_col_ExecModuleCourse;
       Exception
       when others then
          close cur_GuidModuleCourse;
          close cur_ImplModuleCourse;
          close cur_ExecModuleCourse;
      if cur_GuidModuleCourse%isopen then
        close cur_GuidModuleCourse;
      end if ; 
      
      if cur_ImplModuleCourse%isopen then
        close cur_ImplModuleCourse;
      end if ;
      if cur_ExecModuleCourse%isopen then
        close cur_ExecModuleCourse;
      end if ;
      END;
      
      ----------返回分部实施性专业规则课程（指导性必修+实施性所有课程）
  Function FN_TCP_GetImplModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses
  IS
    v_TcpModuleCourses TcpModuleCourses :=TcpModuleCourses();
  BEGIN
     for v_r in ( 
     with t1 as (select batchcode, tcpcode,modulecode,courseid ,coursenature,credit,Openedsemester as semester,examunittype,IsDegreeCourse from eas_tcp_modulecourses a  where
     tcpcode=i_TcpCode )
     ,t2 as (    select batchcode, tcpcode,modulecode,courseid ,coursenature,credit ,examunittype,IsExecutiveCourse from eas_tcp_implmodulecourse a  where
     tcpcode=i_TcpCode   and segmentcode=i_SegmentCode )
     select batchcode, tcpcode,modulecode,courseid,coursenature,credit,semester,examunittype,IsDegreeCourse,0 as IsExecutiveCourse from t1 where coursenature='1'
     union
     select t2.batchcode, t2.tcpcode,t2.modulecode,t2.courseid,t2.coursenature,t2.credit,t1.semester ,t2.examunittype,t1.IsDegreeCourse,t2.IsExecutiveCourse from t2 inner join t1 on t2.courseid=t1.courseid 
     
   )
      loop
       
        v_TcpModuleCourses.extend();
        v_TcpModuleCourses(v_TcpModuleCourses.count):=TcpCourse(v_r.batchcode,v_r.tcpcode,v_r.modulecode,v_r.courseid,v_r.credit,v_r.Coursenature,v_r.semester,v_r.examunittype,v_r.IsDegreeCourse,v_r.IsExecutiveCourse);
     end loop;


   return v_TcpModuleCourses;
  
  END;
         ----返回学习中心执行性专业规则课程（指导性必修+实施性必修+执行性）  
   Function FN_TCP_GetExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2,i_LearnCode varchar2) return TcpModuleCourses
  IS
    v_TcpModuleCourses TcpModuleCourses :=TcpModuleCourses();
  BEGIN
     for v_r in ( 
     with t1 as (select batchcode, tcpcode,modulecode,courseid ,coursenature,credit,Openedsemester as semester,examunittype,IsDegreeCourse from eas_tcp_modulecourses a  where
             tcpcode=i_TcpCode )
            ,t2 as (select batchcode, tcpcode,modulecode,courseid ,coursenature,credit,examunittype,IsExecutiveCourse,IsDegreeCourse from eas_tcp_implmodulecourse a  where
                   tcpcode=i_TcpCode   and segmentcode=i_SegmentCode )
              select batchcode, tcpcode,modulecode,courseid,coursenature,credit,semester,examunittype,IsDegreeCourse,0 as IsExecutiveCourse from t1 where coursenature='1'
                 union
                select t2.batchcode, t2.tcpcode,t2.modulecode,t2.courseid,t2.coursenature,t2.credit,t1.semester ,t2.examunittype,t1.IsDegreeCourse,t2.IsExecutiveCourse from t2 inner join t1 on t2.courseid=t1.courseid 
                     where t2.coursenature='2'
                union 
               select t3.batchcode, t3.tcpcode,t3.modulecode,t3.courseid,t3.coursenature,t3.credit,t3.SuggestOpenSemester as semester,t3.examunittype,t2.IsDegreeCourse,t2.IsExecutiveCourse from eas_tcp_execmodulecourse t3 inner join t2 on t3.courseid=t2.courseid
                where t3.tcpcode=i_TcpCode
               and t3.learningcentercode=i_LearnCode

         )
      loop
       
        v_TcpModuleCourses.extend();
        v_TcpModuleCourses(v_TcpModuleCourses.count):=TcpCourse(v_r.batchcode,v_r.tcpcode,v_r.modulecode,v_r.courseid,v_r.credit,v_r.Coursenature,v_r.semester,v_r.examunittype,v_r.IsDegreeCourse,v_r.IsExecutiveCourse);
     end loop;


   return v_TcpModuleCourses;
  
  END;
  

         ----返回执行性专业规则模板课程（指导性必修+实施性必修+执行性模板）  
   Function FN_TCP_GetMExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses
  IS
    v_TcpModuleCourses TcpModuleCourses :=TcpModuleCourses();
  BEGIN
     for v_r in ( 
     with t1 as (select batchcode,tcpcode,modulecode,courseid ,coursenature,credit,Openedsemester as semester,examunittype,IsDegreeCourse from eas_tcp_modulecourses a  where
             tcpcode=i_TcpCode )
            ,t2 as (select batchcode, tcpcode,modulecode,courseid ,coursenature,credit,examunittype,IsExecutiveCourse,IsDegreeCourse from eas_tcp_implmodulecourse a  where
                   tcpcode=i_TcpCode   and segmentcode=i_SegmentCode )
              select batchcode,tcpcode,modulecode,courseid,coursenature,credit,semester,examunittype,IsDegreeCourse,0 as IsExecutiveCourse from t1 where coursenature='1'
                 union
                select t2.batchcode,t2.tcpcode,t2.modulecode,t2.courseid,t2.coursenature,t2.credit,t1.semester ,t2.examunittype,t1.IsDegreeCourse,t2.IsExecutiveCourse from t2 inner join t1 on t2.courseid=t1.courseid 
                     where t2.coursenature='2'
                union 
               select t3.batchcode, t3.tcpcode,t3.modulecode,t3.courseid,t3.coursenature,t3.credit,t3.SuggestOpenSemester as semester,t3.examunittype ,t2.IsDegreeCourse,t2.IsExecutiveCourse from eas_tcp_mexecmodulecourse  t3 inner join t2 on t3.courseid=t2.courseid 
               where t3.tcpcode=i_TcpCode
               and t3.segmentcode=i_SegmentCode

         )
      loop
       
        v_TcpModuleCourses.extend();
        v_TcpModuleCourses(v_TcpModuleCourses.count):=TcpCourse(v_r.batchcode,v_r.tcpcode,v_r.modulecode,v_r.courseid,v_r.credit,v_r.Coursenature,v_r.semester,v_r.examunittype,v_r.IsDegreeCourse,v_r.IsExecutiveCourse);
     end loop;


   return v_TcpModuleCourses;
  
  END;  
  
      /*   执行性专业规则启用条件 */
    
    PROCEDURE PR_TCP_MEXECENABLE(ORGCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2 ) IS
  returnCode varchar2(100); 
   v_Temp varchar2(100);
   v_tcp_code  EAS_TCP_EXECUTION.TCPCODE %type :=TCPCODE ;
   v_SegmentCode   EAS_TCP_EXECUTION.SEGMENTCODE %type :=ORGCODE;
   
  /* b 变量  */
  v_rowcount number ;
  v_c1 number :=0;
  v_c2 number :=0;
  v_c3 number :=0;
  
  
  /* g-1 g_2*/
  v_g1 number;
  v_g2 number;
  
  BEGIN
   RETCODE:='1';
    /*  a  */
   
  
    /*学位高校代码>0 表示有学位信息*/
    
   
    with t1 as (select degreecollegeid ,degreesemester,spycode  from EAS_TCP_GUIDANCE where TCPCODE=v_tcp_code)
     ,t2 as (
      select  A.EXAMUNITTYPE ,a.courseid from EAS_TCP_DegreeCurriculums a inner join EAS_TCP_DegreeRule b on  A.DEGREERULEID=B.SN 
      where exists(select * from t1 where  B.BATCHCODE =t1.degreesemester and B.COLLEGEID =t1.degreecollegeid and B.SPYCODE =t1.spycode) 
       and not exists( select * from table(PK_tcp.FN_TCP_GetMExecModuleCourses(v_tcp_code,v_SegmentCode)) where courseid=a.courseid and examunittype=A.EXAMUNITTYPE ))
       --select * from t2;
       select count(*) into v_rowcount from t2 where exists(select * from t1 where degreecollegeid>0);
       
       --select * from table(PK_tcp.FN_TCP_GetImplModuleCourses('090301202010102','120')) where courseid in ('01750','50134')
    dbms_output.put_line(v_rowcount);
     if v_rowcount>0 then
        returnCode :='a,';
      dbms_output.put_line('a');
      goto IsContinue;
     end if;

 
            /*b */
            
           select case when A.MINGRADCREDITS <= B.MODULETOTALCREDITS then '' else 'b' end into v_Temp
                  from EAS_TCP_MExecution a inner join EAS_TCP_MExecOnRule b on a.tcpcode=b.tcpcode and A.SegmentCode =B.SegmentCode 
                  where a.tcpcode=v_tcp_code and A.SegmentCode =v_SegmentCode;   
                 
        dbms_output.put_line(v_Temp  );
     if v_Temp='b' then
       returnCode := v_Temp ;
       goto IsContinue;
     end if ;  
     
              /* g  */
       select  
                  sum(case when A.MINEXAMCREDITS <= B.REQUIREDTOTALCREDITS  then 0 else 1 end)  a  
                  , sum(case when A.MINGRADCREDITS  <= B.ModuleTOTALCREDITS then 0 else 1 end)  b  into v_g1,v_g2
                  from EAS_TCP_Module a inner join EAS_TCP_MExecOnModuleRule b on a.tcpcode=b.tcpcode and A.MODULECODE =B.MODULECODE 
                  where a.tcpcode=v_tcp_code and  B.SegmentCode =v_SegmentCode  ;   
               
      dbms_output.put_line(v_g1 || ' ' ||v_g1 );
   
       if v_g1>0 then 
           returnCode := 'g_1' ;
           goto IsContinue;
     end if;
     
     if v_g2>0 then 
           returnCode := 'g_2' ;
           goto IsContinue;
     end if;       
     
    dbms_output.put_line( 'returnCode' || returnCode ); 
    <<IsContinue>>  
    RETCODE := returnCode;
    
  END PR_TCP_MEXECENABLE;
    
  
  /* 执行性专业规则模板启用条件批量查询*/
  FUNCTION  FN_TCP_MEXECENABLE(ORGCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED
  IS
  v_tcpCode varchar2(20);
  v_ReturnCode varchar2(100);
    
    CURSOR myCur is
    select COLUMN_VALUE from table(splitstr(TCPCODELIST,','));
    
    BEGIN
       OPEN myCur;
       LOOP
        FETCH myCur INTO v_tcpCode;
        
        EXIT WHEN myCur%NOTFOUND;
           /* -- do */
           dbms_output.put_line(v_tcpCode);
           PR_TCP_MEXECENABLE(ORGCODE,v_tcpCode,v_ReturnCode);
           PIPE ROW(v_tcpCode || '-'|| v_ReturnCode);
        END LOOP;
        RETURN;
        CLOSE myCur;
    END    ;
    
    
    
    PROCEDURE PR_TCP_ADDMEXECE(ORGCODE IN varchar2, TCPCODE IN varchar2,RETCODE OUT varchar2 ) IS
     v_tcpCode EAS_TCP_IMPLEMENTATION.TCPCODE%type :=TCPCODE;--专业规则
     v_OrgCode   EAS_TCP_IMPLEMENTATION.ORGCODE %type :=ORGCODE;
     v_state    EAS_TCP_IMPLEMENTATION.IMPSTATE %type;
     v_sn number;
       /* 判断已经启用的是否可以再次启用*/
BEGIN

      RETCODE :='OK';
      select Impstate into v_state from EAS_TCP_IMPLEMENTATION where TCPCODE=v_tcpCode and OrgCode=v_OrgCode;
      dbms_output.put_line(v_tcpCode || ' 状态：' ||v_state);
   IF v_state ='1' THEN
      dbms_output.put_line('开始处理未启用'); 
   
       
        v_sn :=seq_tcp_MExec.nextval;
        
       /*Eas_tcp_Mexecution */
        merge into Eas_tcp_Mexecution ta
        using EAS_TCP_IMPLEMENTATION tb on (ta.TCPCODE =tb.TCPCODE and ta.SEGMENTCODE =tb.orgcode )
        when NOT MATCHED THEN
           insert  (
                     BATCHCODE,SEGMENTCODE,TCPCODE
                    ,MINGRADCREDITS,MINEXAMCREDITS,EXEMPTIONMAXCREDITS
                    ,EDUCATIONTYPE,STUDENTTYPE,PROFESSIONALLEVEL,SPYCODE
                    ,SCHOOLSYSTEM,DEGREECOLLEGEID,degreeSemester
                    ,SN,CreateTime,ispub)
           values(  tb.BATCHCODE ,tb.ORGCODE ,tb.TCPCODE 
           ,tb.MINGRADCREDITS ,tb.MINEXAMCREDITS ,tb.EXEMPTIONMAXCREDITS  
           ,tb.EDUCATIONTYPE ,tb.STUDENTTYPE ,tb.PROFESSIONALLEVEL ,tb.SPYCODE 
           ,tb.SCHOOLSYSTEM ,tb.DEGREECOLLEGEID ,tb.DEGREESEMESTER 
           , v_sn ,sysdate,0)
           where tb.TCPCODE =v_tcpCode and tb.orgcode =v_OrgCode;
           dbms_output.put_line('insert Eas_tcp_Mexecution' ||  SQL%ROWCOUNT); 
           ----------------------加课程
          merge into EAS_TCP_MExecModuleCourse a
         using  (
            with t1 as (select * from table(PK_tcp.FN_TCP_GetImplModuleCourses(v_tcpCode,v_OrgCode)) 
                     where coursenature='3' and (isdegreecourse=1 or IsExecutiveCourse=1) )
           select v_sn as sn, a1.Batchcode,b1.TcpCode,v_OrgCode Segmentcode,b1.modulecode,b1.courseId,b1.coursenature,b1.Examunittype,b1.credit,a1.hour,a1.openedSemester suggestopensemester
          ,a1.openedSemester planopensemester,a1.isdegreecourse,a1.issimilar from t1 b1 
         inner join eas_tcp_modulecourses a1 on a1.tcpcode=b1.tcpcode and a1.courseid=b1.courseid 
           )   b 
         on (A.sn =b.sn and A.COURSEID =B.COURSEID ) 
         when NOT MATCHED THEN
         insert (
                SN,Batchcode,TcpCode,Segmentcode,modulecode,courseId,coursenature,Examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,CreateTime
            )
          values(b.sn,b.Batchcode,b.TcpCode,b.Segmentcode,b.modulecode,b.courseId,b.coursenature,b.Examunittype,b.credit,b.hour,b.suggestopensemester,b.planopensemester,b.isdegreecourse,b.issimilar,sysdate);
        dbms_output.put_line('EAS_TCP_MExecModuleCourse' ||  SQL%ROWCOUNT);
        
    /* EAS_TCP_MExecOnRule */
    --模块总学分11. 总部必修+ 12 分部必修（分部必修总部考试+分部必修分部考试）+13 分部选修的执行课
    --总部考试  21 总部必修总部考试+22分部必修总部考试+23选修总部考试
    
        merge into EAS_TCP_MExecOnRule ta
      using (
      with t1 as (select  batchcode, tcpcode, sum(credit) c1,sum(case when  examunittype='1' then credit else 0 end) c2 
      from  table(PK_tcp.FN_TCP_GetMExecModuleCourses(v_tcpCode,v_OrgCode))
      group by  batchcode, tcpcode)
       select v_sn sn,t1.batchcode,t1.TCPCODE ,v_OrgCode segmentcode, t1.c1,t1.c2 from t1 
     ) tb 
      on (ta.sn=tb.sn)
       when NOT MATCHED THEN
       insert (sn      ,batchcode   ,segmentcode   ,tcpcode   ,moduletotalcredits,totalcredits)
       values (tb.sn   ,tb.batchcode,tb.segmentcode,tb.tcpcode,tb.c1             ,tb.c2);
           
        dbms_output.put_line('insert EAS_TCP_MExecOnRule' ||  SQL%ROWCOUNT);
        
    
     
    /*EAS_TCP_MExecOnModuleRule*/
    ---- 总部考试总学分＝ 指导性模块总部必修总部考试 s11 + 实施性模块分部必修总部考试s12+ 分部选修总部考试的执行课 s13 
 ----模块总学分     =   指导性模块总部必修 s21 + 实施性模块分部必修s22+ 分部选修执行课 s23
      merge into EAS_TCP_MExecOnModuleRule ta
         using (
       with t1 as (select batchcode, tcpcode, modulecode
   ,sum(case when examunittype='1' then credit else 0 end ) as requiredTC
   ,sum(credit  ) as ModuleTotalCredits 
   from  table(PK_tcp.FN_TCP_GetMExecModuleCourses(v_tcpCode,v_OrgCode))
   group by batchcode, tcpcode,modulecode)
    ,t2 as(select batchcode, tcpcode,modulecode from eas_tcp_module where tcpcode=v_tcpCode) 
    select v_sn sn,t2.batchcode,t2.TCPCODE ,v_OrgCode segmentcode,t2.modulecode, nvl(t1.requiredTC,0) requiredTC,nvl(t1.ModuleTotalCredits,0) ModuleTotalCredits from t2 left join t1
    on t2.tcpcode=t1.tcpcode and t2.modulecode=t1.modulecode 
      ) tb 
      on (ta.sn=tb.sn and ta.modulecode=tb.modulecode)
       when NOT MATCHED THEN
       insert (sn      ,batchcode,segmentcode,tcpcode,modulecode,RequiredTotalCredits,ModuleTotalCredits)
       values (tb.sn,tb.batchcode,tb.segmentcode,tb.tcpcode,tb.modulecode,tb.requiredTC,tb.ModuleTotalCredits);
   
         
        dbms_output.put_line('insert EAS_TCP_MExecOnModuleRule' ||  SQL%ROWCOUNT);
        
        
 
    else 
      RETCODE:='批次未下发';
      rollback;
    
    END IF;
    if RETCODE='OK' then
        commit;
    end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
  
END PR_TCP_ADDMEXECE;


   
    PROCEDURE PR_TCP_PUBMEXECE(i_Maintainer IN varchar2,i_ORGCODE IN varchar2, i_TCPCODE IN varchar2,RETCODE OUT varchar2 ) IS
    v_iOperater EAS_TCP_EXECUTION.EXECUTOR   %type :=i_Maintainer;  --操作人 
    v_tcp_code  EAS_TCP_EXECUTION.TCPCODE %type         :=i_TCPCODE ;
    v_SegmentCode   EAS_TCP_EXECUTION.SEGMENTCODE %type :=i_ORGCODE;
    v_Sn number;
    v_retcode varchar2(100);
       /* 判断已经启用的是否可以再次启用*/
BEGIN

      RETCODE :='OK';
      select sn into v_sn from EAS_TCP_MExecution where tcpcode=v_tcp_code and segmentcode=v_SegmentCode;
      delete EAS_TCP_MExecByLearn where sn=v_sn; 
     dbms_output.put_line('delete EAS_TCP_MExecByLearn' ||  SQL%ROWCOUNT);
  ---1 删除不可管理的且有数据的
  
  
   ----isbecontrol=1 且可同步的
    merge into   EAS_TCP_MExecByLearn  a
    using (with 
     t1 as (select courseid,isdegreecourse,isexecutivecourse from table(PK_TCP.FN_TCP_GetImplModuleCourses(v_tcp_code,v_SegmentCode)) 
     where coursenature='3' and  (isdegreecourse=1 or IsExecutiveCourse=1))
    ,t2 as (select learningcentercode,courseid from EAS_TCP_ExecModuleCourse a 
    where tcpcode=v_tcp_code  and segmentcode=v_SegmentCode and not exists (select * from t1 where courseid=a.courseid))
    ,t3 as (select learningcentercode from EAS_TCP_Execution where tcpcode=v_tcp_code  and segmentcode=v_SegmentCode and excState='0')
    select v_sn as sn, v_SegmentCode as segmentcode ,learningcentercode,1 as isbecontrol from EAS_TCP_ExecRuleControl a 
    where isbecontrol=1 and exists(select * from t3 where learningcentercode = A.LEARNINGCENTERCODE )
    and not exists(select * from t2 where learningcentercode=a.learningcentercode)) b
     on (a.sn=b.sn and a.learningcentercode=b.learningcentercode)
           when NOT MATCHED THEN
           insert (
             sn ,segmentcode,learningcentercode,isbecontrol,createdate)
           values(b.sn,b.segmentcode,b.learningcentercode,b.isbecontrol,sysdate);
           
       dbms_output.put_line('insert  isbecontrol=1 EAS_TCP_MExecByLearn' ||  SQL%ROWCOUNT); 
      
    
  ----isbecontrol=1 且可同步的
  merge into   EAS_TCP_MExecByLearn  a
  using( with 
         t3 as (select learningcentercode from EAS_TCP_Execution where tcpcode=v_tcp_code  and segmentcode=v_SegmentCode and excState='0')
    select v_sn as sn, v_SegmentCode as segmentcode ,learningcentercode,0 as isbecontrol from EAS_TCP_ExecRuleControl a 
    where isbecontrol=0 and exists(select * from t3 where learningcentercode = A.LEARNINGCENTERCODE )
    ) b
   on (a.sn=b.sn and a.learningcentercode=b.learningcentercode)
           when NOT MATCHED THEN
           insert (
             sn ,segmentcode,learningcentercode,isbecontrol,createdate)
           values(b.sn,b.segmentcode,b.learningcentercode,b.isbecontrol,sysdate);
           
       dbms_output.put_line('insert  isbecontrol=0 EAS_TCP_MExecByLearn' ||  SQL%ROWCOUNT); 
 
  
  
      delete EAS_TCP_ExecModuleCourse where tcpcode=v_tcp_code 
      and exists(select * from EAS_TCP_MExecByLearn where learningcentercode=EAS_TCP_EXECMODULECOURSE.LEARNINGCENTERCODE and sn=v_sn );
  
          dbms_output.put_line('delete  EAS_TCP_ExecModuleCourse' ||  SQL%ROWCOUNT);
  
            -----1 选择要下发的学习中心 2.已经有记录的 3.不受控的
      -- select A.BATCHCODE ,A.TCPCODE ,A.SEGMENTCODE ,B.LEARNINGCENTERCODE ,A.MODULECODE ,A.COURSEID ,A.COURSENATURE ,A.CREDIT ,A.HOUR ,A.SUGGESTOPENSEMESTER ,A.PLANOPENSEMESTER ,A.ISDEGREECOURSE ,A.ISSIMILAR  from EAS_TCP_MExecModuleCourse a inner join EAS_TCP_MExecByLearn b on a.sn=B.SN where sn=v_sn 
         merge into EAS_TCP_ExecModuleCourse a
         using (select A.BATCHCODE ,A.TCPCODE ,A.SEGMENTCODE ,B.LEARNINGCENTERCODE ,A.MODULECODE ,A.COURSEID ,A.COURSENATURE ,a.examunittype,A.CREDIT ,A.HOUR 
                   ,A.SUGGESTOPENSEMESTER ,A.PLANOPENSEMESTER ,A.ISDEGREECOURSE ,A.ISSIMILAR  
                   from EAS_TCP_MExecModuleCourse a inner join EAS_TCP_MExecByLearn b on a.sn=B.SN where a.sn=v_sn) b 
         on (A.TCPCODE =B.TCPCODE and A.LEARNINGCENTERCODE  =B.LEARNINGCENTERCODE and A.COURSEID =B.COURSEID) 
         when NOT MATCHED THEN
         insert (
                SN,Batchcode,TcpCode,Segmentcode,learningcentercode,modulecode,courseId,coursenature,Examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,CreateTime
            )
          values(sys_guid(),b.Batchcode,b.TcpCode,b.Segmentcode,b.learningcentercode,b.modulecode,b.courseId,b.coursenature,b.Examunittype,b.credit,b.hour,b.suggestopensemester,b.planopensemester,b.isdegreecourse,b.issimilar,sysdate);
          dbms_output.put_line(' insert EAS_TCP_ExecModuleCourse' ||  SQL%ROWCOUNT);
          
          ----------算分
         
       merge into EAS_TCP_ExecOnRule ta
       using (
        with t1 as ( select  * from EAS_TCP_MExecOnRule where sn=v_sn)
       ,t2 as (select learningcentercode from  EAS_TCP_MExecByLearn where sn=v_sn)
       select t1.tcpcode ,t1.moduletotalcredits,t1.totalcredits,t2.learningcentercode from t1 cross join t2
          ) tb 
      on (ta.tcpcode=tb.tcpcode and ta.learningcentercode=tb.learningcentercode)
       when  MATCHED THEN
       update set TotalCredits = tb.totalCredits,moduleTotalCredits = tb.moduletotalCredits;
       dbms_output.put_line('update EAS_TCP_ExecOnRule' ||  SQL%ROWCOUNT);

       merge into EAS_TCP_ExecOnModuleRule ta
       using (
       with t1 as ( select * from EAS_TCP_MExecOnModuleRule where sn=v_sn)
            ,t2 as (select learningcentercode from  EAS_TCP_MExecByLearn where sn=v_Sn)
       select t1.tcpcode ,t1.modulecode,t1.moduletotalcredits,t1.requiredtotalcredits,t2.learningcentercode from t1 cross join t2
        ) tb 
        on (ta.tcpcode=tb.tcpcode and ta.learningcentercode=tb.learningcentercode and ta.modulecode=tb.modulecode)
        when  MATCHED THEN
        update set requiredTotalCredits = tb.requiredtotalcredits,moduleTotalCredits = tb.moduletotalCredits;
        
      
      dbms_output.put_line('update EAS_TCP_ExecOnModuleRule' ||  SQL%ROWCOUNT);
       -------启用执行性规则
     for v_r in (select b.tcpcode,a.learningcentercode from EAS_TCP_MExecByLearn a inner join EAS_TCP_MExecution b on a.sn=b.sn where a.sn=v_sn and isbecontrol<>1)
      loop
        dbms_output.put_line( 'EAS_TCP_ExecOnModuleRule' || v_r.tcpcode);
         PK_TCP.PR_TCP_ExecutionEnable(v_r.tcpcode, v_iOperater, v_r.learningcentercode, v_retcode);
      end loop;
      
       update EAS_TCP_MExecution set ispub=1 ,pubtime=sysdate,publisher=v_iOperater where sn=v_sn;
        dbms_output.put_line('update EAS_TCP_MExecution' ||  SQL%ROWCOUNT);
       
    if RETCODE='OK' then
        commit;
    end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
  
END PR_TCP_PUBMEXECE;

 --继承执行性模板
  PROCEDURE PR_TCP_INHERITMEXECE_1(i_SourceSN IN NUMBER,i_ORGCODE IN varchar2, i_TCPCODE IN varchar2,RETCODE OUT varchar2) IS
  v_SourceSN EAS_TCP_MEXECUTION.SN %type ;
  v_tcpCode EAS_TCP_IMPLEMENTATION.BATCHCODE %type:=i_TCPCODE;
  v_OrgCode   EAS_TCP_IMPLEMENTATION.ORGCODE %type :=i_ORGCODE;
  v_sn number;
  v_RetCode varchar2(100);
 BEGIN
       RETCODE :='OK';
       PK_TCP.PR_TCP_ADDMEXECE(v_OrgCode,v_tcpCode,v_RetCode );
       if v_RetCode='OK' then
         select sn into v_sn from Eas_tcp_Mexecution where tcpcode=v_tcpCode and segmentcode=v_OrgCode;
         
          ---同步课程
      merge into EAS_TCP_MExecModuleCourse a
         using  (  with t1 as (select * from table(PK_tcp.FN_TCP_GetImplModuleCourses(v_tcpCode,v_OrgCode)) 
                     where coursenature='3')
                   ,t2 as ( select courseid from EAS_TCP_MExecModuleCourse where sn=v_SourceSN) 
           select v_sn as sn, a1.Batchcode,b1.TcpCode,v_OrgCode Segmentcode,b1.modulecode,b1.courseId,b1.coursenature,b1.Examunittype,b1.credit,a1.hour,a1.openedSemester suggestopensemester
          ,a1.openedSemester planopensemester,a1.isdegreecourse,a1.issimilar from t1 b1 
         inner join eas_tcp_modulecourses a1 on a1.tcpcode=b1.tcpcode and a1.courseid=b1.courseid 
         where exists(select * from t2 where courseid=b1.courseid)
           )   b 
         on (A.sn =B.sn and A.COURSEID =B.COURSEID ) 
         when NOT MATCHED THEN
         insert (
                SN,Batchcode,TcpCode,Segmentcode,modulecode,courseId,coursenature,Examunittype,credit,hour,suggestopensemester,planopensemester,isdegreecourse,issimilar,CreateTime
            )
          values(b.sn,b.Batchcode,b.TcpCode,b.Segmentcode,b.modulecode,b.courseId,b.coursenature,b.Examunittype,b.credit,b.hour,b.suggestopensemester,b.planopensemester,b.isdegreecourse,b.issimilar,sysdate);
         dbms_output.put_line('insert EAS_TCP_MExecModuleCourse' ||  SQL%ROWCOUNT);
       
       ------更新学分
      merge into EAS_TCP_MExecOnRule ta
      using (
      with t1 as (select  batchcode, tcpcode, sum(credit) c1,sum(case when  examunittype='1' then credit else 0 end) c2 
      from  table(PK_tcp.FN_TCP_GetMExecModuleCourses(v_tcpCode,v_OrgCode))
      group by  batchcode, tcpcode)
       select v_sn sn,t1.batchcode,t1.TCPCODE ,v_OrgCode segmentcode, t1.c1,t1.c2 from t1 
     ) tb 
      on (ta.sn=tb.sn)
       when NOT MATCHED THEN
       insert (sn      ,batchcode   ,segmentcode   ,tcpcode   ,moduletotalcredits,totalcredits)
       values (tb.sn   ,tb.batchcode,tb.segmentcode,tb.tcpcode,tb.c1             ,tb.c2)
       when MATCHED THEN
           update 
           set moduletotalcredits=tb.c1,totalcredits=tb.c2;     
        dbms_output.put_line('insert EAS_TCP_MExecOnRule' ||  SQL%ROWCOUNT);
  
       merge into EAS_TCP_MExecOnModuleRule ta
         using (
                with t1 as (select batchcode, tcpcode, modulecode
           ,sum(case when examunittype='1' then credit else 0 end ) as requiredTC
           ,sum(credit  ) as ModuleTotalCredits 
           from  table(PK_tcp.FN_TCP_GetMExecModuleCourses(v_tcpCode,v_OrgCode))
           group by  batchcode, tcpcode,modulecode)
            select v_sn sn,t1.batchcode,t1.TCPCODE ,v_OrgCode segmentcode,t1.modulecode, t1.requiredTC,t1.ModuleTotalCredits from t1 
         ) tb 
      on (ta.sn=tb.sn and ta.modulecode=tb.modulecode)
       when NOT MATCHED THEN
       insert (sn      ,batchcode,segmentcode,tcpcode,modulecode,RequiredTotalCredits,ModuleTotalCredits)
       values (tb.sn,tb.batchcode,tb.segmentcode,tb.tcpcode,tb.modulecode,tb.requiredTC,tb.ModuleTotalCredits)
       when MATCHED THEN
           update 
           set RequiredTotalCredits=tb.requiredTC,ModuleTotalCredits=tb.ModuleTotalCredits; 
               
       
        dbms_output.put_line('insert EAS_TCP_MExecOnModuleRule' ||  SQL%ROWCOUNT);
        

       
       else
        RETCODE := v_RetCode;
       end if;
        
      
      
      
    <<IsContinue>>   
       if RETCODE='OK' then
        commit;
       else 
        rollback;
       end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
  
END PR_TCP_INHERITMEXECE_1;


PROCEDURE PR_TCP_INHERITMEXECE(i_SourceBatchCode IN varchar2,i_TargetBatchCode IN varchar2,i_ORGCODE IN varchar2, i_Profession IN varchar2, i_SpyCode IN varchar2,RETCODE OUT varchar2) IS
v_SourceBatchCode EAS_TCP_GUIDANCE.BATCHCODE %type :=i_SourceBatchCode;
v_TargetBatchCode EAS_TCP_GUIDANCE.BATCHCODE %type :=i_TargetBatchCode;
v_OrgCode   EAS_ORG_BASICINFO.ORGANIZATIONCODE %type := i_ORGCODE;
v_Profession EAS_TCP_GUIDANCE.PROFESSIONALLEVEL %type :=i_Profession;
v_SpyCode EAS_TCP_GUIDANCE.SPYCODE %type := i_SpyCode;

v_SourceSN number;
v_TargetTCPCode EAS_TCP_GUIDANCE.TCPCODE %type;
v_count number;

BEGIN
   RETCODE:='OK';
   
  select count(*) into v_count from Eas_tcp_Mexecution a where  segmentcode=v_OrgCode and 
  exists(select * from eas_tcp_guidance where tcpcode=a.tcpcode and batchcode=v_SourceBatchCode and  professionallevel=v_Profession and spycode=v_SpyCode);
  ----get v_SourceSN
  if v_count=1 then
   select sn into v_SourceSN from Eas_tcp_Mexecution a where  segmentcode=v_OrgCode and 
    exists(select * from eas_tcp_guidance where tcpcode=a.tcpcode and batchcode=v_SourceBatchCode and  professionallevel=v_Profession and spycode=v_SpyCode);
  else
     RETCODE:='a';
    goto IsContinue;
  end if;

     ----get v_TargetTCPCode
 select count(*) into v_count from EAS_TCP_IMPLEMENTATION a where OrgCode=v_OrgCode
 and exists(select * from eas_tcp_guidance where tcpcode=a.tcpcode and batchcode=v_TargetBatchCode and  professionallevel=v_Profession and spycode='');

  if v_count=1 then
   select tcpcode into v_TargetTCPCode from EAS_TCP_IMPLEMENTATION a where OrgCode=v_OrgCode  
   and exists(select * from eas_tcp_guidance where tcpcode=a.tcpcode and batchcode=v_TargetBatchCode and  professionallevel=v_Profession and spycode=v_SpyCode);
   
   ----执行继承
   PR_TCP_INHERITMEXECE_1(v_SourceSN ,v_OrgCode , v_TargetTCPCode ,RETCODE) ;
   
  else
     RETCODE:='b';
    goto IsContinue;
  end if;
  
  
    <<IsContinue>>   
       if RETCODE='OK' then
        commit;
       else 
        rollback;
       end if;
    
    EXCEPTION

     WHEN OTHERS THEN
         
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     RETCODE:='EXCEPTION';
     rollback;
END PR_TCP_INHERITMEXECE;
 
END PK_TCP;
/

