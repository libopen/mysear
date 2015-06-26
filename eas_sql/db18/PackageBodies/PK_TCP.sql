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
   1.0        2015-04-15      libin       1. Created this package body.
******************************************************************************/
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
END PK_TCP;
/

