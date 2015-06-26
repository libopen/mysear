--
-- PR_TCP_EXECUTIONENABLE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_ExecutionEnable
(
--i_ExecSN in varchar2,--执行性专业规则ID
i_TCPCode in varchar2,--专业规则编码
i_OperatorName in varchar2,--操作人
i_LearningCenterCode in varchar2,--学习中学编码
returnCode out varchar2
)
 IS

 v_batchcode EAS_TCP_Execution.Batchcode%type;--批次
 v_segmentcode EAS_TCP_Execution.segmentcode%type;--分部
 v_ExcState EAS_TCP_Execution.ExcState%Type;
 
/*****************************************************************************
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/7/4   liufengshuan       1. Created this procedure.

   NOTES:执行性专业规则--启用

   Automatically available Auto Replace Keywords:
      Object Name:     执行性专业规则--启用

******************************************************************************/
BEGIN
   
   returnCode :='1';
   
    --1.更具tcpcode,learningcertercode 获取执行性专业规则信息

    select segmentcode,batchcode,ExcState into v_segmentcode,v_batchcode,v_ExcState from EAS_TCP_Execution
    WHERE tcpcode=i_TCPCode and learningcentercode=i_LearningCenterCode;
    
   dbms_output.put_line(i_TCPCode||','||i_LearningCenterCode ||'查出结果为:分部=' ||v_segmentcode || ',批次='||v_batchcode );
   
   if v_ExcState='0' then
   --2.将课程插入到学习中心课程总表中   
   insert into EAS_TCP_LearCentCourse(SN,SegOrgCode,LearningCenterCode,CourseID,CourseState,CreateTime)
   select seq_TCP_LearCentCour.nextval SN,v_segmentcode SegOrgCode,i_LearningCenterCode LearningCenterCode,l.courseId,1 CourseState,sysdate from
   (
        select courseid from  EAS_TCP_modulecourses a 
           where a.coursenature='1'  and a.tcpcode=i_TCPCode
           and not exists(select * from EAS_TCP_LearCentCourse b where a.courseid=b.courseid and B.segorgcode =v_segmentcode and b.learningcentercode=i_LearningCenterCode )
        union
        select courseid from  EAS_TCP_implmodulecourse a 
            where coursenature=2 and a.tcpcode=i_TCPCode  and A.SegmentCode =v_segmentcode
            and not exists(select * from EAS_TCP_LearCentCourse b where a.courseid=b.courseid  and a.SegmentCode =b.SegOrgcode and b.learningcentercode=i_LearningCenterCode )
        union 
        select courseid from EAS_TCP_ExecModuleCourse c
            where c.tcpcode=i_TCPCode and c.segmentcode=v_segmentcode  and c.learningcentercode=i_LearningCenterCode
            and not exists(select * from EAS_TCP_LearCentCourse b where c.courseid=b.courseid  and c.SegmentCode =b.SegOrgcode and c.learningcentercode=B.LEARNINGCENTERCODE )
        union
        select courseid from  EAS_TCP_ConversionCourse a 
                where a.tcpcode=i_TCPCode
                and not exists(select * from EAS_TCP_LearCentCourse b where a.courseid=b.courseid  and b.SegOrgcode =v_segmentcode and b.learningcentercode=i_LearningCenterCode )
    ) l;
    
     dbms_output.put_line('EAS_TCP_LearCentCourse' ||  SQL%ROWCOUNT);
       
   
   /*
   --修改执行专业规则的状态为启用
   */
       UPDATE EAS_TCP_Execution SET  ExcState=1, Executor=i_OperatorName, ExecuteTime=sysdate WHERE tcpcode=i_TCPCode and learningcentercode=i_LearningCenterCode;
    dbms_output.put_line('EAS_TCP_Execution' ||  SQL%ROWCOUNT || 'Executor'||i_OperatorName);
    
    end if;
   commit;
   
   EXCEPTION
     WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
            rollback;
       returnCode :='-0'; /* 返回未成功标志*/
       
       
END PR_TCP_ExecutionEnable;
/

