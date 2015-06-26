--
-- Create Schema Script 
--   Database Version          : 11.2.0.3.0 
--   Database Compatible Level : 11.2.0.3.0 
--   Script Compatible Level   : 11.2.0.3.0 
--   Toad Version              : 12.1.0.22 
--   DB Connect String         : ORCL18 
--   Schema                    : OUCHNSYS 
--   Script Created by         : OUCHNSYS 
--   Script Created at         : 2015/06/26 17:12:24 
--   Physical Location         :  
--   Notes                     :  
--

-- Object Counts: 
--   Functions: 17      Lines of Code: 539 
--   Packages: 14       Lines of Code: 386 
--   Package Bodies: 13 Lines of Code: 5154 
--   Procedures: 31     Lines of Code: 2309 
--   Types: 19 
--   Type Bodies: 2 


-- "Set define off" turns off substitution variables. 
Set define off; 

--
-- ARREXAMDATE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."ARREXAMDATE"                                                                                  
AS VARRAY (100) OF DATE
/

--
-- EXAMPLAN  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."EXAMPLAN"                                                                                   AS OBJECT
(
/*
 ERROR CODE
 1.纸考计划在纸考计划表中不存在
 2.
*/
  PlanMakeOrgCode VARCHAR2(20),  --step:1
  PlanMakeOrgType VARCHAR2(3),   --step:1
  PlanUseOrgCode VARCHAR2(20),   --step:2
  PlanUseOrgType VARCHAR2(255),  --step:2
  IsInPlanPub NUMBER,  ---有否纸考计划下发表中记录
  IsApply   NUMBER,    --是否下发 step:13
  ExamSessionUnitMode NUMBER,      --step:3
  ExamType varchar2(10),          --step:1
  PlanCode      varchar2(20),     --step:1
  CateGoryCode  varchar2(20),     --step:4
  CateGoryOrgCode varchar2(20),   --step:4
  CateGoryOrgType varchar2(3),    --step:4
  IsInDetailPub   number, --有否计划考试时间表记录
  ErrorCode       number
  ,CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2 ,i_ExamCategorySN number) return self as result
   ,CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2 ) return self as result
  
)
/

--
-- EXAMTIME  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."EXAMTIME"                                                                                   AS OBJECT
(
  PARTSNUM NUMBER,    ---考几场
  NEWBEGINDATE DATE,       --新考试开始日期
  NEWENDDATE DATE,         --新考试结束日期
  EXISTBEGINDATE DATE,     --存在的考试开始日期
  EXISTENDDATE DATE,       --存在的考试结束日期
  BeginNumber  number,     --总部起始时间单元号
  SegmentBeginNumber number ,--分部起始单元号
  member function GetExamDateList(i_Operate IN number) return arrExamDate  --i_Operate 1 只使用新时间段 2 使用扩展时间段
);
/

--
-- MROW_STUDENTELC  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."MROW_STUDENTELC"                                                                                   AS OBJECT
(
  StudentCode VARCHAR2(255),
  CourseID    VARCHAR2(10)
  
)
/

--
-- MROW_STUDENTELC2  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."MROW_STUDENTELC2"                                                                                   AS OBJECT
(
                       batchcode varchar2(6),
                       studentcode varchar2(20),
                       fullname    varchar2(20),
                       professionallevel varchar(20),
                       spyname           varchar2(30),
                       learnname         varchar2(50),
                       CourseID    VARCHAR2(10)
  
)
/

--
-- MTB_STUDENTELC  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."MTB_STUDENTELC"                                                                                  
AS TABLE OF MROW_STUDENTELC2
/

--
-- MYVARCHAR2  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."MYVARCHAR2"                                                                          AS TABLE OF varchar2(100)
/

--
-- R_PAPERLIST  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."R_PAPERLIST"                                                                                   AS OBJECT
(
  SN NUMBER,
  ExamCategoryCode VARCHAR2(20),
  ExamPaperCode VARCHAR2(20),
  AllowMakeExamSession number,
  AllowMakePaper number
  
)
/

--
-- R_SIGNSTATICS  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."R_SIGNSTATICS"                                                                                   AS OBJECT
(
  ExamPlanCode VARCHAR2(20),
  ExamCategoryCode VARCHAR2(20),
  ExamPaperCode VARCHAR2(20),
  SignCnt NUMBER,
  ConfirmCnt NUMBER
)
/

--
-- SIGNSTATICS_TAB  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."SIGNSTATICS_TAB"                                                                                  
AS TABLE OF R_SIGNSTATICS
/

--
-- STR_SPLIT  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."STR_SPLIT"                                                                                  
AS TABLE OF VARCHAR2(4000)
/

--
-- TCPCOURSE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS.TCPCOURSE AS OBJECT
(
  BATCHCODE VARCHAR2(50),
  TCPCODE VARCHAR2(50),
  MODULECODE VARCHAR2(50),
  COURSEID VARCHAR2(50),
  CREDIT NUMBER(7,2),
  COURSENATURE VARCHAR2(2),
  SEMESTER NUMBER(2),
  EXAMUNITTYPE VARCHAR2(10),
  IsDegreeCourse number,
  IsExecutiveCourse number
  
)
/

--
-- TCPMODULECOURSES  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS.TCPMODULECOURSES
AS TABLE OF TCPCOURSE
/

--
-- TYP_EXECMODULECOURSE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."TYP_EXECMODULECOURSE"                                                                                   AS OBJECT 
(
  COURSEID VARCHAR2(10),
  MODULECODE VARCHAR2(10),
  CREDIT NUMBER(7,2),
  COURSESTATE NUMBER(1),
  OPENEDSEMESTER NUMBER(2),
  COURSENATURE NUMBER(1),
  EXAMUNITTYPE NUMBER(1)
  
)
/

--
-- TYP_IMPLRULE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."TYP_IMPLRULE"                                                                                   AS OBJECT
(
  TCPCode VARCHAR2(15),
  ModuleTotalCredits NUMBER(7,2),
  CenterExamTotalCredits NUMBER(7,2)
)
/

--
-- TYP_MODULERULE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."TYP_MODULERULE"                                                                                   AS OBJECT
(
  MODULECODE VARCHAR2(2),
  ModuleTotalCredit NUMBER(7,2),
  CenterExamTotalCredit NUMBER(7,2)
)
/

--
-- T_PAPERLIST  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."T_PAPERLIST"                                                                                  
AS TABLE OF R_PAPERLIST
/

--
-- EXAMPLAN  (Type Body) 
--
CREATE OR REPLACE TYPE BODY OUCHNSYS.ExamPlan is 
 CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2,i_ExamCategorySN number)
 return self as result is
 begin
    ---1.构造 plancode,PlanMakeOrgCode,PlanMakeOrgType,IsApply,ExamType
    select  A.EXAMPLANCODE ,A.CREATEORGCODE,B.ORGANIZATIONTYPE,A.ISAPPLY,A.ExamType  into self.PlanCode,self.PlanMakeOrgCode,self.PlanMakeOrgType,self.isapply,self.examtype
    from eas_exmm_definition a inner join eas_org_basicinfo b on A.CREATEORGCODE =B.ORGANIZATIONCODE  where sn=i_ExamPlanSN;
    ---2.-PlanUseOrgCode,PlanUseOrgType
    select A.ORGANIZATIONCODE ,A.ORGANIZATIONTYPE into self.PlanUseOrgCode,self.PlanUseOrgType  from eas_org_basicinfo a where A.ORGANIZATIONCODE =i_PlanUseOrgCode;
    ---3.-isapply
    if self.PlanUseOrgType=2 then
     select a.ispublish,A.EXAMSESSIONUNITMODE  into self.isapply,self.ExamSessionUnitMode from EAS_ExmM_PaperExamPlanPub  a where a.sn= i_ExamPlanSN and A.SEGMENTCODE =i_PlanUseOrgCode;
     
    end if;
    ---4-CateGoryCode,CateGoryOrgCode,CateGoryOrgType
    select a.examcategorycode,B.ORGANIZATIONCODE  ,B.ORGANIZATIONTYPE into self.CateGoryCode,self.CateGoryOrgCode,self.CateGoryOrgType  from eas_exmm_examcategory a 
    inner join  eas_org_basicinfo b on A.segmentcode =B.ORGANIZATIONCODE  where sn=i_ExamCategorySN;
    ---- 判断时间单元编排方式
    
   return ;
 end ;
 
 CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2)
 return self as result is
 begin
    ---1.构造 plancode,PlanMakeOrgCode,PlanMakeOrgType,IsApply,ExamType
    select  A.EXAMPLANCODE ,A.CREATEORGCODE,B.ORGANIZATIONTYPE,A.ISAPPLY,A.ExamType  into self.PlanCode,self.PlanMakeOrgCode,self.PlanMakeOrgType,self.isapply,self.examtype
    from eas_exmm_definition a inner join eas_org_basicinfo b on A.CREATEORGCODE =B.ORGANIZATIONCODE  where sn=i_ExamPlanSN;
    ---2.-PlanUseOrgCode,PlanUseOrgType
    select A.ORGANIZATIONCODE ,A.ORGANIZATIONTYPE into self.PlanUseOrgCode,self.PlanUseOrgType  from eas_org_basicinfo a where A.ORGANIZATIONCODE =i_PlanUseOrgCode;
    ---3.-isapply
    if self.PlanUseOrgType=2 then
     select a.ispublish,A.EXAMSESSIONUNITMODE  into self.isapply,self.ExamSessionUnitMode from EAS_ExmM_PaperExamPlanPub  a where a.sn= i_ExamPlanSN and A.SEGMENTCODE =i_PlanUseOrgCode;
     
    end if;
    
   return ;
 end ;
 --- end Head
 END;
/

--
-- EXAMTIME  (Type Body) 
--
CREATE OR REPLACE TYPE BODY OUCHNSYS.EXAMTIME AS 
member function GetExamDatelist(i_Operate IN number) return arrExamDate as
 vExamDate_array arrExamDate := arrExamDate();
 v_count number;
 BEGIN
  vExamDate_array.Delete;
   if i_Operate=1 then -- 初始化
          dbms_output.put_line('初始化开始');
             for i in 1..NEWENDDATE-NEWBEGINDATE+1
             loop
              vExamDate_array.extend;
               vExamDate_array(i):= NEWBEGINDATE+i-1;
             end loop;
     else    --增加初始化v_iOperateType=2
          dbms_output.put_line('增量初始化开始');
               ----判断 延长的时间不能在原时间范围内
              if (NEWBEGINDATE>EXISTBEGINDATE and NEWBEGINDATE<EXISTENDDATE) or (NEWENDDATE>EXISTBEGINDATE and NEWENDDATE<EXISTENDDATE ) then
                 
                  dbms_output.put_line('错误设置：新开始时间在原时间范围内，或新结束时间在原时间范围内。新时间：'||NEWBEGINDATE||'~~'||NEWENDDATE||'~原时间~'||EXISTBEGINDATE||'~~'||EXISTENDDATE);
              else   -- 设置新时间段考试时间
                 if NEWBEGINDATE>EXISTENDDATE or NEWENDDATE<EXISTBEGINDATE then
                      for i in 1..NEWENDDATE-NEWBEGINDATE+1
                      loop
                       vExamDate_array.extend;
                         vExamDate_array(i):=NEWBEGINDATE+i-1;
                      end loop;
                   
                else
                 if NEWBEGINDATE<EXISTBEGINDATE then  ---新开始时间在原开始时间之前
                     for i in 1..EXISTBEGINDATE-NEWBEGINDATE --时间向前延长
                     loop
                      vExamDate_array.extend;
                      vExamDate_array(i):=NEWBEGINDATE+i-1;
                     end loop;
                 end if ;
                 v_count := vExamDate_array.count; -- 前一段开数
                 if NEWENDDATE>EXISTENDDATE then           --时间后延
                    for j in 1..NEWENDDATE-EXISTENDDATE        --时间延后
                     loop
                      vExamDate_array.extend;
                      vExamDate_array(v_count+j):=EXISTENDDATE+j;
                      end loop;
                  end if;
                end if;
              end if;
     
     end if;
     
    return vExamDate_array;

END ;
End;
/

--
-- PAGER  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.Pager
is
type curs is ref cursor;
procedure Pagination
(
inPageSize in integer, --每页记录数
inPageIndex in integer, --当前页数
inTableName in varchar2, --表名
inOutField in varchar2,--输出字段
inOrderField in varchar2,--排序字段
inIsOrderBy in varchar2,--排序类别，输入' desc' 或者' asc'
inWhere in varchar2,--查询条件
outRecordCount out int, --总记录数
outPageCount out int,
outCursor out curs --游标变量
);
end;
/

--
-- PAGINGPACKAGE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.pagingPackage as  
    type paging_cursor is ref cursor;  
    end pagingPackage;
/

--
-- PDTYPES  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PDTypes
as
    TYPE ref_cursor IS REF CURSOR;
end;
-- Integrity package declaration
create or replace package IntegrityPackage AS
 procedure InitNestLevel;
 function GetNestLevel return number;
 procedure NextNestLevel;
 procedure PreviousNestLevel;
 end IntegrityPackage;
/

--
-- PKG_SELECT_COURSE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PKG_SELECT_COURSE AS
/******************************************************************************
   NAME:       PKG_SELECT_COURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16      libin       1. Created this package.
******************************************************************************/

TYPE T_CURSOR is ref cursor;
PROCEDURE GETALLCOURSE
(cur_name out T_CURSOR);


END PKG_SELECT_COURSE;
/

--
-- PK_EXMM_SESSIONUNIT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_ExmM_SessionUnit AS
/******************************************************************************
   NAME:       PK_ExmM_SessionUnit
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/9/23      Administrator       1. Created this package.
******************************************************************************/

  PROCEDURE UpdateSessionUnitInSubjectPlan(InXml IN varchar2,OutCount out int);

END PK_ExmM_SessionUnit;
/

--
-- PK_EXPT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXPT AS
/******************************************************************************
   NAME:       PK_EXPT
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-06-17      libin       1. Created this package.
******************************************************************************/
---- i_XMLSTR 导入数据XML格式  i_impFile 导入文件名,i_Maintainer 维护人 RETCODE 返回值正常返回（成功条数，失败条数） ，异常返回－1
   ---***XML***---
   --格式 <t>
  --<r><A>学号</A><B>姓名</B><C>学习中心代码</C><D>科目代码</D><E>错误信息</E></r>
  --</t>
  PROCEDURE PR_EXPT_IMPORTREPORT(i_XMLSTR VARCHAR2,i_impFile VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);

END PK_EXPT;
/

--
-- PK_GRAD_AUDIT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_Grad_Audit AS
/******************************************************************************
   NAME:       PK_Grad_Audit
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/4/21      Administrator       1. Created this package.
******************************************************************************/

--更新毕业管理_学生毕业审核表中的申请时预审核状态
PROCEDURE PR_Grad_UpdateGradCondition(
    isGradPass int,
    isDegreePass int,
    inStudentCode varchar2,
    outCount out int
   );

--初审名单审核
PROCEDURE Pr_Grad_TrailListProcess(
    InSegmentCode varchar2,
    OutCount out int
    );
--单个学生初审
PROCEDURE PR_Grad_TrailListWithAStudent(
    InStudentCode varchar2,
    OutCount out int
    );
END PK_Grad_Audit;
/

--
-- PK_SIGN  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_SIGN AS
/******************************************************************************
   NAME:       PK_SIGN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/11/20      libin       1. Created this package.
******************************************************************************/

 Type SignStatics_Type IS Record
(
  ExamPlanCode VARCHAR2(20),
  ExamCategoryCode VARCHAR2(20),
  ExamPaperCode VARCHAR2(20),
  SignCnt NUMBER,
  ConfirmCnt NUMBER
);

type t_SignStatics is table of SignStatics_Type ;

Function Get_SignStaticsAll(i_ExamplanCode in varchar2) return  SignStatics_tab;
END PK_SIGN;
/

--
-- PK_STUDENTCOURSE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_STUDENTCOURSE AS
/******************************************************************************
   NAME:       PK_STUDENTCOURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/19      libin       1. Created this package.
******************************************************************************/

  FUNCTION FN_GETSTUDENTCOURSEINDBBASE(in_XML_ELC IN CLOB) RETURN MTB_StudentElc;
  

END PK_STUDENTCOURSE;
/

--
-- PK_SYSMESSAGE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_SysMessage AS
/******************************************************************************
   NAME:       PK_SysMessage
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/6/8      Administrator       1. Created this package.
******************************************************************************/

--记录系统消息
  Procedure Pr_RecordSysMessage(
    vMsgScope varchar2,
    vMsgContent varchar2,
    vMsgSource varchar2
  );
END PK_SysMessage;
/

--
-- PK_TRACKERSYSMESSAGE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_TrackerSysMessage AS
/******************************************************************************
   NAME:       PK_SysMessage
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/5/11      Administrator       1. Created this package.
******************************************************************************/

  procedure InsertTrackerMessage(msgScope varchar2,msgContent varchar2,msgSource varchar2);

END PK_TrackerSysMessage;
/

--
-- TYPES  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.types AS
/******************************************************************************
   NAME:       types
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16      libin       1. Created this package.
******************************************************************************/
type cursorType is ref cursor;

END types;
/

--
-- INTEGRITYPACKAGE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.IntegrityPackage AS
 NestLevel number;
-- Procedure to initialize the trigger nest level
 procedure InitNestLevel is
 begin
 NestLevel := 0;
 end;
-- Function to return the trigger nest level
 function GetNestLevel return number is
 begin
 if NestLevel is null then
     NestLevel := 0;
 end if;
 return(NestLevel);
 end;
-- Procedure to increase the trigger nest level
 procedure NextNestLevel is
 begin
 if NestLevel is null then
     NestLevel := 0;
 end if;
 NestLevel := NestLevel + 1;
 end;
-- Procedure to decrease the trigger nest level
 procedure PreviousNestLevel is
 begin
 NestLevel := NestLevel - 1;
 end;
 end IntegrityPackage;
/

--
-- PAGER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.Pager
is
procedure Pagination
(
inPageSize in integer, --每页记录数
inPageIndex in integer, --当前页数
inTableName in varchar2, --表名
inOutField in varchar2,--输出字段
inOrderField in varchar2,--排序字段
inIsOrderBy in varchar2,--排序类别，输入' desc' 或者' asc'
inWhere in varchar2,--查询条件
outRecordCount out int, --总记录数
outPageCount out int,
outCursor out curs --游标变量
)
is
v_sql varchar2(3000); --总的sql 语句
v_sql_count varchar2(3000); --总记录的sql 语句
v_sql_order varchar2(2000); --排序的sql 语句
v_outField varchar2(3000); --总的sql 语句
v_count int; -- --总记录数
v_endrownum int; --结束行
v_startrownum int; --开始行
begin
if inOrderField!='NO' then
v_sql_order :=' ORDER BY '|| inOrderField ||' '||inIsOrderBy;
else
v_sql_order :='';
end if;
if inWhere is not null then
v_sql_count:='SELECT COUNT(ROWNUM) FROM '||inTableName||' where '||inWhere;
else
v_sql_count:='SELECT COUNT(ROWNUM) FROM '||inTableName;
end if;

if inOutField is  null then
v_outField := inTableName||'.*';
else
v_outField :=inOutField;
end if;

execute immediate v_sql_count into v_count;
outRecordCount := v_count;
if mod(v_count,inPageSize)=0 then
outPageCount:= v_count/inPageSize;
else
outPageCount:= v_count/inPageSize+1;
end if;
v_startrownum:= 1+(inPageIndex-1)*inPageSize;
v_endrownum:= inPageIndex*inPageSize;

if inWhere is not null then
v_sql := 'SELECT * FROM (SELECT '||v_outField||', row_number() over ('||v_sql_order||')
num FROM '||inTableName||' WHERE '|| inWhere||'
) WHERE num between '||to_char(v_startrownum)||' and '||to_char(v_endrownum)||'';

else

v_sql := 'SELECT * FROM (SELECT '||v_outField||', row_number() over ('||v_sql_order||')
num FROM '||inTableName||'
) WHERE num between '||to_char(v_startrownum)||' and '||to_char(v_endrownum)||'';

end if;
dbms_output.put_line(v_sql);
open outCursor for v_sql;
end;
end;
/

--
-- PKG_SELECT_COURSE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PKG_SELECT_COURSE AS
/******************************************************************************
   NAME:       PKG_SELECT_COURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16      libin       1. Created this package.
******************************************************************************/
PROCEDURE GETALLCOURSE
(cur_name out T_CURSOR)
IS
BEGIN
  open cur_name FOR
   select * from eas_dic_subject;
   END GETALLCOURSE;

END PKG_SELECT_COURSE;
/

--
-- PK_EXMM_SCORE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_ExMM_Score AS

    --插入形考成绩-当前使用
    procedure InsertXKScoreAndDetail
    (
        InSN in int,
        InXKP_SN int,
        InScore in varchar2,
        InScoreCode in varchar2,
        InEntryStaff in varchar2,
        InItemXml IN varchar2,
        OutCount out int
    )
    is
    --定义xml解析
    xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
    doc xmldom.DOMDocument;
    --节点
    pNodes xmldom.DOMNODELIST;
    --临时节点
    tempNode XMLDOM.DOMNODE;
    --子节点
    chilNodes xmldom.DOMNodeList;
    --总数
    pCount        number;
    
    xkScoreSN int;--形考成绩序列号
    
    x_SN int;
    x_ItemCode varchar(3);
    x_ItemScale varchar2(10);
    x_Score  VARCHAR2(5) ;
    x_ScoreCode varchar(10);
    
    itemCount int;--小项的数量
    begin
       --首先更新形考成绩
       update EAS_ExmM_XKScore set XKP_SN = InXKP_SN,Score = InScore,ScoreCode = InScoreCode,EntryStaff = InEntryStaff,InputType='1',EntryDate=sysdate where SN = InSN;
       --存储小项成绩
       --开起解析
       XMLPARSER.PARSECLOB(xmlPar,InItemXml);
       doc:=XMLPARSER.GETDOCUMENT(xmlPar);
       --释放
       XMLPARSER.FREEPARSER(xmlPar);
       --获取节点
       pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
       --获取总数
       pCount := XMLDOM.GETLENGTH(pNodes);
       outCount :=0;
       delete from EAS_ExmM_XKScoreDetail where SN = InSN;--清除之前的数据
       
       FOR i in 0..pCount-1 
       LOOP
        tempNode := XMLDOM.ITEM(pNodes,i);
        chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
        
        x_SN := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
        x_ItemCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
        x_ItemScale := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
        x_Score := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
        x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
       
        insert into EAS_ExmM_XKScoreDetail(SN,ItemCode,ItemScale,Score,ScoreCode)values
        (InSN,x_ItemCode,x_ItemScale,x_Score,x_ScoreCode);
        
        END LOOP;
        outCount:=outCount+1;
        COMMIT;
    end InsertXKScoreAndDetail;

    --录入考试成绩
    procedure Pro_Exam_RecordExamScore
    (
        InStrXml varchar2,--写入的xml
        InEntryOrgType int,--录入单位类型
        InEntryOrgCode varchar2,--录入单位编码
        InScoreType int,--成绩类型1客观成绩2主观成绩
        InEntryStaff varchar2,--操作员
        OutCount out int
    )
    IS
    --定义xml解析
    xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
    doc xmldom.DOMDocument;
    --节点
    pNodes xmldom.DOMNODELIST;
    --临时节点
    tempNode XMLDOM.DOMNODE;
    --子节点
    chilNodes xmldom.DOMNodeList;
    --总数
    pCount        number;

    --插入参数
    x_SN int;
    x_Score int;
    x_ScoreCode varchar(20);
    x_RecordType int;
BEGIN
   
   --开起解析
   XMLPARSER.PARSECLOB(xmlPar,InStrXml);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   outCount :=0;
   
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
     
    x_SN := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_Score := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_ScoreCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_RecordType :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    
    --一录客观成绩
    if x_RecordType =1 and InScoreType=1 then
            update EAS_ExmM_PaperScore set PaperScore = x_Score,PaperScoreCode = x_ScoreCode,EntryOrgType = InEntryOrgType,EntryOrgCode = InEntryOrgCode,ObjScore1 = x_Score,ObjScoreCode1 = x_ScoreCode,
            ObjEntryStaff1 = InEntryStaff,ObjEntryDate1 = sysdate ,IsObjScorePass = 0,IsSubScorePass = 0,IsEntryPass = 0 where SN = x_SN;
            outCount:=outCount+1;
    elsif x_RecordType=3 and InScoreType=1 then--直接录入客观成绩，成绩会直接放到考试成绩中，成绩代码亦同
            update EAS_ExmM_PaperScore set ObjScore1 = x_Score,ObjScoreCode1 = x_ScoreCode,
            ObjEntryStaff1 = InEntryStaff,ObjEntryDate1 = sysdate ,PaperScore = x_Score,PaperScoreCode = x_ScoreCode,EntryOrgType = InEntryOrgType,EntryOrgCode = InEntryOrgCode,ObjScore2 = x_Score,ObjScoreCode2 = x_ScoreCode,
            ObjEntryStaff2 = InEntryStaff,ObjEntryDate2 = sysdate,IsObjScorePass = 1,IsEntryPass = 1 where SN = x_SN;
            outCount:=outCount+1;
    elsif x_RecordType=1 and InScoreType=2 then--一录主观成绩
            update EAS_ExmM_PaperScore set PaperScore = x_Score,PaperScoreCode = x_ScoreCode,EntryOrgType = InEntryOrgType,EntryOrgCode = InEntryOrgCode,SubScore1 = x_Score,SubScore1Code = x_ScoreCode,
            SubEntryStaff1 = InEntryStaff,SubEntryDate1 = sysdate,IsObjScorePass = 0,IsSubScorePass = 0,IsEntryPass = 0 where SN = x_SN;
            outCount:=outCount+1;
    elsif  x_RecordType=3 and InScoreType=2 then--直接录入主观成绩
            update EAS_ExmM_PaperScore set PaperScore = x_Score,PaperScoreCode = x_ScoreCode, EntryOrgType = InEntryOrgType,EntryOrgCode = InEntryOrgCode,SubScore1 = x_Score,SubScore1Code = x_ScoreCode,
            SubEntryStaff1 = InEntryStaff,SubEntryDate1 = sysdate,SubScore2 = x_Score,SubScoreCode2 = x_ScoreCode,
            SubEntryStaff2 = InEntryStaff,SubEntryDate2 = sysdate,IsSubScorePass = 1,IsEntryPass = 1 where SN = x_SN;
            outCount:=outCount+1;
    elsif x_RecordType =2 and InScoreType = 1 then--二录客观成绩
            update EAS_ExmM_PaperScore  set SubScore2 = x_Score,SubScoreCode2 = x_ScoreCode,
            SubEntryStaff2 = InEntryStaff,SubEntryDate2 = sysdate,PaperScore = x_Score,PaperScoreCode = x_ScoreCode, ObjScore2 = x_Score,ObjScoreCode2 = x_ScoreCode,ObjEntryStaff2 = InEntryStaff,ObjEntryDate2 = sysdate,
            IsObjScorePass = 1,
            IsSubScorePass = 1,
            IsEntryPass =1
            where SN=x_SN;
            outCount:=outCount+1;
    elsif  x_RecordType =2 and InScoreType = 2 then
            update EAS_ExmM_PaperScore set PaperScore = x_Score,PaperScoreCode = x_ScoreCode, SubScore2 = x_Score,SubScoreCode2 = x_ScoreCode,SubEntryStaff2 = InEntryStaff,SubEntryDate2 = sysdate,
            IsObjScorePass = 1,
            IsSubScorePass = 1,
            IsEntryPass =1
            where SN=x_SN;
            outCount:=outCount+1;
    end if;
    END LOOP;
    COMMIT;
  end Pro_Exam_RecordExamScore;

    
    --成绩初始化
    PROCEDURE Pro_Exam_InitializeExamScore
    (
        InSegmentCode varchar2,
        InExamPlanCode varchar2,
        InExamCategoryCode varchar2,
        OutCountCMScore out int,
        OutErrorCount out int,
        OutAllCount out int
    )
        is
        x_errorCount int;--没有初始化成功的数量
        strSql varchar2(1000);
        
        
        TYPE signUpRec IS REF CURSOR;--定义用户类型
        sign_row signUpRec; --定义游标变量
        
        x_SignSN number(10);
        x_ExamCategoryCode varchar2(50);
        x_CourseID varchar2(50);
        x_ExamPaperCode varchar2(50);
        x_CollegeCode varchar2(50);
        x_LearningCenterCode varchar2(50);
        x_ClassCode varchar(50);
        x_StudentCode varchar(50);
        x_ExamUnit varchar(20);
        x_AssessMode varchar(20);
        x_NumSignUp number(10);
        
        x_ScoreStandPlan number(10);
        x_xkTopScore number(7,2);
        x_xkTopScoreCode varchar2(10);
        
        x_PaperScoreSN number(10);
        x_XKScoreSN number(10);
        
        x_InputType varchar2(5);--录入方式
        begin
            OutErrorCount :=0;
            OutAllCount:=0;
            OutCountCMScore:=0;
            
            if InExamCategoryCode is null then
                strSql:='select signUp.SN,signUp.ExamCategoryCode,signUp.CourseID,signUp.ExamPaperCode,sss.SignUpNum,signUp.ExamUnit,signUp.AssessMode,signUp.CollegeCode,signUp.LearningCenterCode,signUp.ClassCode,signUp.StudentCode 
                    from eas_Exmm_signup signUp inner join EAS_Elc_StudentStudyStatus sss on sss.studentCode = signUp.studentCode and sss.CourseID = signUp.CourseID
                    where signUp.examPlanCode = '''||InExamPlanCode||''' and signUp.segmentCode = '''||InSegmentCode||''' and signUp.IsConfirm=1  
                    and not exists(
                        select 1 from EAS_ExmM_PaperScore paperScore where paperScore.examPlanCode = signUp.examPlanCode and paperScore.examCategoryCode = signUp.examCategoryCode
                        and paperScore.studentCode = signUp.studentCode and paperScore.examPaperCode = signUp.examPaperCode)';
            else
                strSql:='select signUp.SN,signUp.ExamCategoryCode,signUp.CourseID,signUp.ExamPaperCode,sss.SignUpNum,signUp.ExamUnit,signUp.AssessMode,signUp.CollegeCode,signUp.LearningCenterCode,signUp.ClassCode,signUp.StudentCode 
                    from eas_Exmm_signup signUp inner join EAS_Elc_StudentStudyStatus sss on sss.studentCode = signUp.studentCode and sss.CourseID = signUp.CourseID
                    where signUp.examPlanCode = '''||InExamPlanCode||''' and signUp.segmentCode = '''||InSegmentCode||''' and signUp.ExamCategoryCode='''|| InExamCategoryCode ||''' and signUp.IsConfirm=1  
                    and not exists(
                        select 1 from EAS_ExmM_PaperScore paperScore where paperScore.examPlanCode = signUp.examPlanCode and paperScore.examCategoryCode = signUp.examCategoryCode
                        and paperScore.studentCode = signUp.studentCode and paperScore.examPaperCode = signUp.examPaperCode)';
            end if;
                open sign_row for strSql;
                loop
                    FETCH sign_row into x_SignSN,x_ExamCategoryCode,x_CourseID,x_ExamPaperCode,x_NumSignUp,x_ExamUnit,x_AssessMode,x_CollegeCode,x_LearningCenterCode,x_ClassCode,x_StudentCode;
                    EXIT WHEN sign_row%NOTFOUND OR sign_row%NOTFOUND IS NULL;
                    --比例设置
                    x_ScoreStandPlan := GetScoreStandardPlan(InExamPlanCode, x_ExamCategoryCode, x_ExamPaperCode, InSegmentCode, x_CollegeCode, x_LearningCenterCode);
                    if x_ScoreStandPlan is not null then
                    
                        --考试
                        x_PaperScoreSN := seq_ExmM_ExamScore.nextVal;
                        insert into EAS_ExmM_PaperScore 
                            (SN,ExamPlanCode,ExamCategoryCode,CourseID,ExamPaperCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,StudentCode)
                        values
                            (x_PaperScoreSN,InExamPlanCode,x_ExamCategoryCode,x_CourseID,x_ExamPaperCode,InSegmentCode,x_CollegeCode,x_learningCenterCode,x_ClassCode,x_StudentCode);
                        
                        --形考
                        --获取形考的最高成绩
                        select Score,ScoreCode into x_xkTopScore,x_xkTopScoreCode from EAS_ExmM_XKScore where studentCode=x_StudentCode and courseID = x_CourseID and rownum=1 order by Score desc ;
                        x_InputType := '2';
                        x_XKScoreSN := seq_ExmM_XKScore.nextVal;
                        insert into EAS_ExmM_XKScore
                        (SN,ExamPlanCode,ExamCategoryCode,CourseID,ExamPaperCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,StudentCode,Score,ScoreCode,XKP_SN,InputType)
                        values
                        (x_XKScoreSN,InExamPlanCode,x_ExamCategoryCode,x_CourseID,x_ExamPaperCode,InSegmentCode,x_CollegeCode,x_LearningCenterCode,x_ClassCode,x_StudentCode,x_xkTopScore,x_xkTopScoreCode,x_ScoreStandPlan,x_InputType);
                        
                        --综合成绩
                        insert into EAS_ExmM_ComposeScore
                        (SN,ExamPlanCode,ExamCategoryCode,ExamUnit,CourseID,ExamPaperCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,AssessMode,IsComplex,Sign_SN,StudentCode,XKP_SN,NumSignUp,PublishDate)
                        values
                        (seq_ExmM_StudentScore.nextVal,InExamPlanCode,x_ExamCategoryCode,x_ExamUnit,x_CourseID,x_ExamPaperCode,InSegmentCode,x_CollegeCode,x_LearningCenterCode,x_ClassCode,x_AssessMode,0,x_SignSN,x_StudentCode,x_ScoreStandPlan,x_NumSignUp,null);
                        
                        OutCountCMScore := OutCountCMScore +1;
                    else
                        OutErrorCount := OutErrorCount+1;
                    end if;
                    OutAllCount :=OutAllCount +1;
                end loop;
                close sign_row;              
                commit;
            
    end Pro_Exam_InitializeExamScore;



    --导入实践课成绩
    Procedure Pro_Exam_ImportPCScore
    (
        InSegmentCode varchar2,
        InCollegeCode varchar2,
        InLearningCenterCode varchar2,
        InEntryOrgType int,
        InEntryOrgCode varchar2,
        InCourseID varchar2,
        InEntryStaff varchar2,
        InRewrite int,
        InStrXml varchar2,
        OutCount out int,
        OutErrorCodes out VARCHAR2--发生错误的学生编码
    )
    is
    --定义xml解析
    xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
    doc xmldom.DOMDocument;
    --节点
    pNodes xmldom.DOMNODELIST;
    --临时节点
    tempNode XMLDOM.DOMNODE;
    --子节点
    chilNodes xmldom.DOMNodeList;
    --总数
    pCount        number;

    --插入参数
    x_Score int;
    x_ScoreCode varchar(20);
    x_StudentCode varchar(20);
    x_IsScoreCode int;
    existCount int;
    begin
        --开起解析
       XMLPARSER.PARSECLOB(xmlPar,InStrXml);
       doc:=XMLPARSER.GETDOCUMENT(xmlPar);
       --释放
       XMLPARSER.FREEPARSER(xmlPar);
       --获取节点
       pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
       --获取总数
       pCount := XMLDOM.GETLENGTH(pNodes);
       outCount :=0;
       existCount :=0;
       
       FOR i in 0..pCount-1 
       LOOP
        tempNode := XMLDOM.ITEM(pNodes,i);
        chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
        
        x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0))); 
        x_Score:= XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
        x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
        x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
        x_IsScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
        
        select count(1) into existCount from EAS_ExmM_PaperScore where studentCode = x_StudentCode and CourseID = InCourseID;
        if existCount = 0 then
          if x_IsScoreCode = 0 then
            insert into  EAS_ExmM_PaperScore(CourseID,SegmentCode,CollegeCode,LearningCenterCode,StudentCode,PaperScore,PaperScoreCode,EntryOrgType,EntryOrgCode,SubEntryStaff2,SubEntryDate2,IsEntryPass)
                                      values(InCourseID,InSegmentCode,InCollegeCode,InLearningCenterCode,x_StudentCode,x_Score,x_ScoreCode,InEntryOrgType,InEntryOrgCode,inEntryStaff,sysdate,1);
          else
            insert into  EAS_ExmM_PaperScore(CourseID,SegmentCode,CollegeCode,LearningCenterCode,StudentCode,PaperScoreCode,EntryOrgType,EntryOrgCode,SubEntryStaff2,SubEntryDate2)
                                      values(InCourseID,InSegmentCode,InCollegeCode,InLearningCenterCode,x_StudentCode,x_ScoreCode,InEntryOrgType,InEntryOrgCode,inEntryStaff,sysdate);
          end if;
         
        else
        
          if InRewrite =1 then --如果重写
            if x_IsScoreCode = 0 then
             update EAS_ExmM_PaperScore set PaperScore = x_Score,PaperScoreCode = x_ScoreCode where CourseID = InCourseID and StudentCode = x_StudentCode;
            else
             update EAS_ExmM_PaperScore set PaperScoreCode = x_ScoreCode where CourseID = InCourseID and StudentCode = x_StudentCode;
            end if;
          else
            if length(OutErrorCodes) =0 then
                OutErrorCodes := x_StudentCode;
            else 
                OutErrorCodes := OutErrorCodes ||','||x_StudentCode;
            end if;
          end if;        
        end if;
        
       end Loop;
    end Pro_Exam_ImportPCScore;

    

    --成绩合成
    PROCEDURE Pro_ExmM_GenerateExamScore
    (
        InExamPlanCode varchar2,
        InExamCategoryCode varchar2,
        InSegmentCode varchar2,
        InCollegeCode varchar2,
        InLearningCenterCode varchar2,
        InExamPaperCode varchar2,
        InExamPaperCodeA varchar2,
        InExamPaperCodeB varchar2,
        InStudentCodeA varchar2,
        InStudentCodeB varchar2,
        InExamSecretCode varchar2,
        InComposeOnlyFirst int,
        OutCount out int,--成功数量
        OutUnSuccessCount out int,--不成功数量
        OutError out varchar2
    )
     IS

    strSql varchar2(2000);
    strTempTableSql varchar(200);
    score int;--合成的成绩
    scoreCode varchar2(20);
    
    x_ObjScore NUMBER(7,2);
    x_SubScore NUMBER(7,2);
    x_ObjScoreCode varchar(20);
    x_SubScoreCode varchar(20);
    
    x_ObjScore1 NUMBER(7,2);
    x_ObjScore2 NUMBER(7,2);
    x_SubScore1 NUMBER(7,2);
    x_SubScore2 NUMBER(7,2);
    x_ObjScoreCode1 varchar2(20);
    x_ObjScoreCode2 varchar2(20);
    x_PaperScoreCode varchar2(20);
    x_SubScore1Code varchar2(20);
    x_SubScoreCode2 varchar2(20);
    x_SN int;
    
    x_CodeCount int;--成绩针对的代码数量
    x_error varchar(2000);
    TYPE examScoreRec IS REF CURSOR;--定义用户类型
    c_row examScoreRec; --定义游标变量
    BEGIN
          OutCount :=0;
          OutUnSuccessCount :=0;
          x_error:=null;
          
          strSql := 'select SN,ObjScore1,objScore2,SubScore1,SubScore2,ObjScoreCode1,ObjScoreCode2,SubScore1Code,SubScoreCode2 from EAS_ExmM_PaperScore paperScore';
          
          if InExamPaperCode is not null then
            strSql := strSql || ' inner join EAS_ExmM_SubjectPlan@ouchnbase subjectPlan on paperScore.ExamPaperCode = subjectPlan.ExamPaperCode and paperScore.ExamPlanCode = subjectPlan.ExamPlanCode and paperScore.ExamCategoryCode = subjectPlan.ExamCategoryCode and ExamPaperCode ='''|| InExamPaperCode||'''';
          end if;
          
          strSql := strSql || ' where paperScore.ExamPlanCode ='''|| InExamPlanCode||''' and paperScore.PaperScoreCode is null and segmentCode='''||InSegmentCode||'''';
          if InExamCategoryCode is not null then
            strSql := strSql || ' and paperScore.ExamCategoryCode='''||InExamCategoryCode||'''';
          end if;
          if InCollegeCode is not null then
            strSql := strSql || ' and paperScore.CollegeCode ='''|| InCollegeCode ||'''';
          end if;
          if InLearningCenterCode is not null then
            strSql := strSql || ' and paperScore.LearningCenterCode ='''||InLearningCenterCode||'''';
          end if;
          if InExamPaperCodeA is not null and InExamPaperCodeB is not null then
            strSql := strSql || ' and paperScore.ExamPaperCode between ''' || InExamPaperCodeA || ''' and ''' || InExamPaperCodeB||'''';
          elsif InExamPaperCodeA is not null then
            strSql := strSql || ' and paperScore.ExamPaperCode >= ''' || InExamPaperCodeA ||'''';
          elsif InExamPaperCodeB is not null then
            strSql := strSql || ' and paperScore.ExamPaperCode <= ''' || InExamPaperCodeB || '''';
          end if;
          
          
          
          if InStudentCodeA is not null and InStudentCodeB is not null then
            strSql := strSql || ' and paperScore.StudentCode between ''' || InStudentCodeA || ''' and ''' || InStudentCodeB ||'''';
          elsif InStudentCodeA is not null then
            strSql := strSql || ' and paperScore.StudentCode >= ''' || InStudentCodeA ||'''';
          elsif InStudentCodeB is not null then
            strSql := strSql || ' and paperScore.StudentCode <= ''' || InStudentCodeB || '''';
          end if;
          if InExamSecretCode is not null then
            strSql := strSql || ' and paperScore.SecretNumber= ''' || InExamSecretCode || '''';
          end if;
          if InComposeOnlyFirst = 0 then
            strSql := strSql || ' and (paperScore.ObjScoreCode2 is not null or paperScore.SubScoreCode2 is not null)';
          else
            strSql := strSql || ' and (paperScore. ObjScoreCode1 is not null or paperScore.SubScore1Code is not null)';
          end if;
                dbms_output.put_line(strSql);
          --创建会话级别临时表
          insert into Temp_EAS_Dic_ScoreCode(DicCode,DicName,DicScore) select DicCode,DicName,DicScore from EAS_Dic_ScoreCode@ouchnbase; 
          
          --执行，使用游标
          open c_row for strSql;--打开游标
          
          loop
          FETCH c_row into x_SN,x_ObjScore1,x_objScore2,x_SubScore1,x_SubScore2,x_ObjScoreCode1,x_ObjScoreCode2,x_SubScore1Code,x_SubScoreCode2;
          EXIT WHEN c_row%NOTFOUND OR c_row%NOTFOUND IS NULL;
            score := null;
            x_PaperScoreCode := null;
            x_ObjScore := null;
            x_ObjScoreCode:= null;
            
            
            if InComposeOnlyFirst = 1 then
                if x_ObjScore2 is null then
                    x_ObjScore := x_ObjScore1;
                    x_ObjScoreCode:=x_ObjScoreCode1;
                else
                    x_ObjScore := x_ObjScore2;
                    x_ObjScoreCode:=x_ObjScoreCode2;
                end if;
                if x_SubScore2 is null then
                    x_SubScore := x_SubScore1;
                    x_SubScoreCode := x_SubScore1Code;
                else
                    x_SubScore := x_SubScore2;
                    x_SubScoreCode := x_SubScoreCode2;
                end if;
                if x_ObjScore is not null and x_SubScore is not null then
                    score := x_ObjScore + x_SubScore;
                elsif x_ObjScore is not null then
                    score := x_ObjScore;
                    x_PaperScoreCode := x_ObjScoreCode;
                elsif x_SubScore is not null then
                    score := x_SubScore;
                    x_PaperScoreCode := x_SubScoreCode;
                end if;
            else
                if x_ObjScoreCode2 is not null and x_SubScoreCode2 is not null then
                    score := x_ObjScore2 + x_SubScore2;
                elsif x_ObjScoreCode2 is not null then
                    score := x_ObjScore2 ;
                    x_PaperScoreCode := x_ObjScoreCode2;
                elsif x_SubScoreCode2 is not null then
                    score := x_SubScore2;
                    x_PaperScoreCode := x_SubScoreCode2;
                end if;
            end if;
                  dbms_output.put_line('分数：'||score||'代码：'||x_PaperScoreCode);
            if score > 100 then
              if x_error is not null then
                x_error := x_error || ',';
              end if;
              OutUnSuccessCount := OutUnSuccessCount +1;
              x_error := x_error || x_SN || ':1';
            elsif score = 0 then
              update EAS_ExmM_PaperScore set PaperScore = score ,PaperScoreCode = x_PaperScoreCode where SN = x_SN;
              outCount := outCount +1;
            else
              --是否有对应的代码
              if x_PaperScoreCode is not null then
                  update EAS_ExmM_PaperScore set PaperScore = score ,PaperScoreCode = x_PaperScoreCode where SN = x_SN;
                  outCount := outCount +1;
              else
                  select count(1) into x_CodeCount from Temp_EAS_Dic_ScoreCode where DicScore = score; 
                  if x_CodeCount > 0 then 
                      select DicCode into scoreCode from Temp_EAS_Dic_ScoreCode where DicScore = score and rowNum =1;
                      --获取分数对应的代码
                      update EAS_ExmM_PaperScore set PaperScore = score ,PaperScoreCode = scoreCode where SN = x_SN;
                      outCount := outCount +1;
                  else
                      if x_error is not null then
                        x_error := x_error || ',';
                      end if;
                      OutUnSuccessCount := OutUnSuccessCount +1;
                      x_error := x_error || x_SN || ':2';
                  end if;
              end if;
            end if;
            OutError := x_error;
          end LOOP;
          close c_row;
          commit;
          

          
    END Pro_ExmM_GenerateExamScore;


   --综合成绩合成
   PROCEDURE UpdateComposeScore 
    (
        InStrXml varchar2,
        OutCount out int
    )
    IS
    --定义xml解析
    xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
    doc xmldom.DOMDocument;
    --节点
    pNodes xmldom.DOMNODELIST;
    --临时节点
    tempNode XMLDOM.DOMNODE;
    --子节点
    chilNodes xmldom.DOMNodeList;
    --总数
    pCount        number;

    --插入参数
    x_SN int;
    x_PaperScore number(7,2);--考试成绩编码
    x_PaperScoreCode varchar(20);--考试成绩比例
    x_PaperScale number(7,2);--形考成绩
    x_XKScore  number(7,2);--形考成绩代码
    x_XKScoreCode varchar(20);--形考成绩比例
    x_XKScale number(7,2);
    x_ComposeScore number(7,2);
    x_ComposeScoreCode varchar2(20);


    BEGIN
       OutCount := 0;
        
       --开起解析
       XMLPARSER.PARSECLOB(xmlPar,InStrXml);
       doc:=XMLPARSER.GETDOCUMENT(xmlPar);
       --释放
       XMLPARSER.FREEPARSER(xmlPar);
       --获取节点
       pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
       --获取总数
       pCount := XMLDOM.GETLENGTH(pNodes);
       outCount :=0;
       
       FOR i in 0..pCount-1 
       LOOP
        tempNode := XMLDOM.ITEM(pNodes,i);
        chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
 
        x_SN := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
        x_PaperScore := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
        x_PaperScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2))); 
        x_PaperScale := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
        x_XKScore := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
        x_XKScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
        x_XKScale := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,6)));
        x_ComposeScore := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,7)));
        x_ComposeScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,8)));
        
        --更新到综合成绩表中
        update EAS_ExmM_ComposeScore set PaperScore = x_PaperScore,PaperScoreCode = x_PaperScoreCode,
        PaperScale= x_PaperScale,XkScore = x_XKScore,XkScoreCode = x_XKScoreCode,XkScale = x_XKScale,
        ComposeScore= x_ComposeScore,ComposeScoreCode =x_ComposeScoreCode,IsComplex = 1,ComposeDate=sysdate
        where Sn = x_SN;
        COMMIT;
        OutCount :=OutCount+1;
       
       END LOOP;   

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           NULL;
         WHEN OTHERS THEN
           -- Consider logging the error and then re-raise
           RAISE;
  END UpdateComposeScore;
END PK_ExMM_Score;
/

--
-- PK_EXMM_SESSIONUNIT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_ExmM_SessionUnit AS
    PROCEDURE UpdateSessionUnitInSubjectPlan(InXml IN varchar2,OutCount out int)
     IS
            xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
            doc xmldom.DOMDocument;
            --节点
            pNodes xmldom.DOMNODELIST;
            --临时节点
            tempNode XMLDOM.DOMNODE;
            --子节点
            chilNodes xmldom.DOMNodeList;
            --总数
            pCount        number;

            --插入参数
            x_SN    int ;
            x_SessionUnit  VARCHAR2(30) ;
            
            
        begin
           XMLPARSER.PARSECLOB(xmlPar,InXml);
           doc:=XMLPARSER.GETDOCUMENT(xmlPar);
           --释放
           XMLPARSER.FREEPARSER(xmlPar);
           --获取节点
           pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
           --获取总数
           pCount := XMLDOM.GETLENGTH(pNodes);
           outCount :=0;
           
           FOR i in 0..pCount-1 
           LOOP
            tempNode := XMLDOM.ITEM(pNodes,i);
            chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
             
            x_SN := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
            x_SessionUnit := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
            
            --
            update EAS_ExmM_SubjectPlan plan set plan.ExamSessionUnit = x_SessionUnit,ArrangeState = 1 where plan.SN =x_SN;
            outCount:=outCount+1;
            commit;
           END LOOP;
           
           XMLDOM.FREEDOCUMENT(doc);
           EXCEPTION
           WHEN OTHERS THEN 
           DBMS_OUTPUT.PUT_LINE(SQLERRM);
    end UpdateSessionUnitInSubjectPlan;
END PK_ExmM_SessionUnit;
/

--
-- PK_EXPT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_EXPT AS
/******************************************************************************
   NAME:       PK_EXPT
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-06-17      libin       1. Created this package body.
******************************************************************************/
----导入网考成绩 i_XMLSTR 导入数据XML格式  i_impFile 导入文件名,i_Maintainer 维护人 RETCODE 返回值正常返回（成功条数，失败条数） ，异常返回－1
 PROCEDURE PR_EXPT_IMPORTREPORT(i_XMLSTR VARCHAR2,i_impFile VARCHAR2, i_Maintainer  VARCHAR2 , RETCODE out VARCHAR2) IS
    ---***XML***---
   --格式 <t>
  --<r><A>学号</A><B>姓名</B><C>学习中心代码</C><D>科目代码</D><E>错误信息</E></r>
  --</t>
    --定义xml解析
    xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
    doc xmldom.DOMDocument;
   --节点
    pNodes xmldom.DOMNODELIST;
    --临时节点
    tempNode XMLDOM.DOMNODE;
    --子节点
    chilNodes xmldom.DOMNodeList;
     --总数
    pCount        number;
    ---*** END *** ---
  
   ---** local variables
        v_FullName   VARCHAR2(100) ;
        v_StudentCode VARCHAR2(50);
        v_FeedBack VARCHAR2(200);
        v_LearningcenterCode VARCHAR2(100);
        v_SubjectCode VARCHAR2(100);

        v_SuccessTotalCount NUMBER;
        v_FailTotalCount NUMBER;
        v_start number;
        v_end   number;

        v_Maintaindate date := sysdate;
BEGIN 
    v_start := dbms_utility.get_time;
  --开起解析
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
 
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    v_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    v_FullName := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    v_LearningcenterCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    v_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    v_FeedBack := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    
    insert into TMP_ExmM_ImportReport 
           (StudentCode   ,FullName ,LearningCenterCode    ,SubjectCode   ,FeedBack  ,Maintainer  ,MaintainDate)
    select v_StudentCode,v_FullName,v_LearningcenterCode  ,v_SubjectCode, v_FeedBack,i_Maintainer,v_Maintaindate
    from dual where v_StudentCode is not null and v_LearningcenterCode is not null and v_SubjectCode is not null
    and not exists(select * from TMP_ExmM_ImportReport where studentcode=v_StudentCode and subjectcode=v_SubjectCode );
      
   
   END LOOP;
   
   ---InValidState 1.未上报 2.已经上报已经反馈 3.记录不存在
   merge into TMP_ExmM_ImportReport aa 
   using EAS_Expt_ExptNetExam bb on (aa.studentcode=bb.studentcode and aa.LearningCenterCode=bb.LearningCenterCode and aa.SubjectCode=bb.SubjectCode)
    when  MATCHED THEN
       update set sn=bb.sn ,InValidState=case when bb.IsReport=0 then 1 when bb.isReport=1 and  bb.FeedBackState !=0 then 2  end;
       
       update TMP_ExmM_ImportReport set InValidState=3 where sn is null;
       
    merge into EAS_Expt_ExptNetExam aa 
    using TMP_ExmM_ImportReport bb on (aa.sn=bb.sn)
    when  MATCHED THEN
       update set FeedBack=bb.FeedBack ,FeedBackState=2
       where bb.InValidState is null;
       
       v_SuccessTotalCount:= SQL%ROWCOUNT;     
 
      insert into EAS_ExmM_ImpFail(ImpFileName,StudentCode,FullName,LearningCenterCode,SubjectCode,Maintainer
       ,CreateTime,Fail)
       select i_impFile,StudentCode,FullName,LearningCenterCode,SubjectCode,Maintainer
       ,MaintainDate,InValidState from TMP_ExmM_ImportReport where InValidState is not null
       and not exists(select * from EAS_ExmM_ImpFail where ImpFileName=i_impFile and studentcode=TMP_ExmM_ImportReport.studentcode and 
       SubjectCode=TMP_ExmM_ImportReport.SubjectCode)
       ;
   
         v_FailTotalCount:= SQL%ROWCOUNT;    
 
   v_end := dbms_utility.get_time;
   DBMS_OUTPUT.PUT_LINE(v_end-v_start);
   
   --CLOSE sInfo;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=v_SuccessTotalCount||','||v_FailTotalCount;
    commit; 
    
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
   RETCODE := '-1';
    rollback;
END PR_EXPT_IMPORTREPORT;

END PK_EXPT;
/

--
-- PK_GRAD_AUDIT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_Grad_Audit AS
--更新毕业管理_学生毕业审核表中的申请时预审核状态
    PROCEDURE PR_Grad_UpdateGradCondition(
    isGradPass int,
    isDegreePass int,
    inStudentCode varchar2,
    outCount out int
   )
   is
   x_IsDegree int;--是否申请学位
   x_Result int;
BEGIN
    x_Result := 1;
    select isDegree into x_IsDegree from EAS_Grad_Audit where studentCode = inStudentCode;
    if x_IsDegree >0 then
        if isGradPass =0 then
            x_Result := 0;
        elsif isDegreePass = 0 then
            x_Result := 0;
        end if;
    else
      if isGradPass = 0 then
        x_Result :=0;
      end if;
    end if;
    
    update EAS_Grad_Audit set IsConditionPass = x_Result where studentCode = inStudentCode;
    outCount:=1;
    
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       outCount :=0;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
    
END PR_Grad_UpdateGradCondition;


--初审名单生成
PROCEDURE PR_Grad_TrailListProcess(
    InSegmentCode varchar2,
    OutCount out int
    )
IS
   mySegmentCode varchar2(100);
   x_FACount int;
BEGIN
    mySegmentCode := InSegmentCode ||'%';
    OutCount := 0;
   --获取学生
   declare
           
    cursor c_job
    is
    select student.studentCode,gradStudent.GradType,gradStudent.AuditGardType,gradStudent.AuditDegrType,orgC.OrganizationCode  as collegeCode,student.learningCenterCode from EAS_SchRoll_Student student inner join EAS_Grad_Student gradStudent on student.studentCode = gradStudent.studentCode
     inner join EAS_Org_BasicInfo orgC on ORGC.PARENTCODE = InSegmentCode and OrganizationType ='3'
     where student.learningCenterCode like mySegmentCode;
    c_row c_job%rowtype;
    begin
      for c_row in c_job loop
      --在初审名单中是否存在
           x_FACount := 0;
           select count(1) into x_FACount from EAS_Grad_FirstAudit where StudentCode = c_row.studentCode;
         if c_row.AuditGardType =1 then
           if x_FACount = 0 then
             insert into 
             EAS_Grad_FirstAudit (studentCode,segmentCode,CollageCode,LearningCenterCode,MaintainDate)
             values
             (c_row.studentCode,InSegmentCode,c_row.collegecode,c_row.learningCenterCode,sysdate);
           end if;
         else
           if x_FACount != 0 then
             delete from EAS_Grad_FirstAudit where studentCode = c_row.studentCode;
           end if;
         end if;
         outCount := outCount +1;
      end loop;
    end;
   
END PR_Grad_TrailListProcess;

--单个学生初审名单生成
PROCEDURE PR_Grad_TrailListWithAStudent(
    InStudentCode varchar2,
    OutCount out int
    )
    IS
    x_FACount int;
    Begin
        OutCount := 0;
   --获取学生
   declare
    cursor c_job
    is
    select student.studentCode,gradStudent.GradType,gradStudent.AuditGardType,gradStudent.AuditDegrType,orgC.parentCode as segmentCode,orgL.parentCode  as collegeCode,student.learningCenterCode from EAS_SchRoll_Student student inner join EAS_Grad_Student gradStudent on student.studentCode = gradStudent.studentCode 
     inner join EAS_Org_BasicInfo orgL on ORGL.OrganizationCode = student.LearningCenterCode
     inner join EAS_Org_BasicInfo orgC on ORGC.OrganizationCode = orgL.parentCode
     where student.studentCode = InStudentCode;
    c_row c_job%rowtype;
    begin
      for c_row in c_job loop
      --在初审名单中是否存在
           x_FACount := 0;
           select count(1) into x_FACount from EAS_Grad_FirstAudit where StudentCode = c_row.studentCode;
         if c_row.AuditGardType =1 then
           if x_FACount = 0 then
             insert into 
             EAS_Grad_FirstAudit (studentCode,segmentCode,CollageCode,LearningCenterCode,MaintainDate)
             values
             (c_row.studentCode,c_row.segmentCode,c_row.collegecode,c_row.learningCenterCode,sysdate);
           end if;
         else
           if x_FACount != 0 then
             delete from EAS_Grad_FirstAudit where studentCode = c_row.studentCode;
           end if;
         end if;
         outCount := outCount +1;
      end loop;
    end;
    
    End PR_Grad_TrailListWithAStudent;

END PK_Grad_Audit;
/

--
-- PK_SIGN  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_SIGN AS
/******************************************************************************
   NAME:       PK_SIGN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/11/20      libin       1. Created this package body.
******************************************************************************/

 Function Get_SignStaticsAll(i_ExamplanCode in varchar2) return  SignStatics_tab IS
 
   SignStatics SignStatics_tab :=SignStatics_tab(); ----用于本函数返回记录
   v_tb112 t_SignStatics;    --用于批量存储从业务库获取的数据bulk collect into 只能支持这样的类型
   v_tb113 t_SignStatics;
 BEGIN
     select examplancode,examcategorycode,exampapercode ,count(*) cnt1,sum(case when isconfirm=1 then 1 else 0 end) as cnt2
     bulk collect into v_tb113
     from eas_exmm_signup@ouchn113
     group by examplancode,examcategorycode,exampapercode;
  for i in 1..v_tb113.count 
  loop
    SignStatics.extend();
    SignStatics(i):=R_SignStatics( v_tb113(i).examplancode,v_tb113(i).examCategorycode,v_tb113(i).Exampapercode,v_tb113(i).SignCnt,v_tb113(i).ConfirmCnt); 
  
  end loop;
  return SignStatics;
 end ;

END PK_SIGN;
/

--
-- PK_STUDENTCOURSE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_STUDENTCOURSE AS
/******************************************************************************
   NAME:       PK_STUDENTCOURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/19      libin       1. Created this package body.
******************************************************************************/

   FUNCTION FN_GETSTUDENTCOURSEINDBBASE(in_XML_ELC IN CLOB) RETURN MTB_StudentElc IS
  
   xmlpar          xmlparser.parser := xmlparser.newparser;  
   -- dom文档对象  
   doc             xmldom.domdocument;  
   StudentCoursesnodes   xmldom.domnodelist;  
   -----student ifno
   v_StudentCode      VARCHAR2 (50);  
   v_CourseID      VARCHAR2 (50);
   v_batchcode varchar2(6);
   v_fullname    varchar2(20);
   v_professionallevel varchar(20);
   v_spyname           varchar2(30);
   v_learnname         varchar2(50);       
   
   -----end student info
   chilnodes       xmldom.domnodelist;  
   tempnode        xmldom.domnode;  
   temparrmap      xmldom.domnamednodemap;  
    
    ElcTotalNumber            number;
    var_mtb_studentelc MTB_StudentElc :=MTB_StudentElc(); 
    strSQL varchar2(500);
/******************************************************************************
   NAME:       FN_GETSTUDENTCOURSEINDBBASE
   PURPOSE:    将从学生选课库返回的记录与基础库数据进行关联查询

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_GETSTUDENTCOURSEINDBBASE
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 9:33:10, and 2014/05/16 9:33:10
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   xmlparser.parseclob (xmlpar, in_XML_ELC);  
   doc := xmlparser.getdocument (xmlpar);  
  
   -- 释放解析器实例  
   xmlparser.freeparser (xmlpar);  
  ---取总选课记录
   StudentCoursesnodes := xmldom.getelementsbytagname (doc, 'ElcRecord');  
   
   ElcTotalNumber := xmldom.getlength(StudentCoursesnodes);
   dbms_output.put_line('TotalRecords-->'|| ElcTotalNumber);
   FOR i in 0..ElcTotalNumber-1
   LOOP
     tempnode := xmldom.item (StudentCoursesnodes, i);  
     -- 获取子元素的值  
      chilnodes := xmldom.getchildnodes (tempnode);  
      --tmp := xmldom.getlength (chilnodes);
      v_StudentCode := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,0)));
      v_CourseID := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,1)));
      strSQL := 'select a.batchcode, a.fullname,b.dicname,c.spyname,D3.ORGANIZATIONNAME ' ;
      strSQL := strSQL ||' from EAS_schroll_student a inner join EAs_dic_professionallevel b on a.professionallevel=b.diccode';
      strSQL := strSQL ||' inner join eas_spy_basicinfo c on a.spycode=c.spycode ';
      strSQL := strSQL ||' inner join eas_org_basicinfo d3 on a.learningcentercode=d3.ORGANIZATIONCODE where studentcode='''|| v_StudentCode || '''';
       DBMS_OUTPUT.put_line (strSQL);       
      execute immediate  strSQL into v_batchcode,v_fullname,v_professionallevel,v_spyname,v_learnname;
   
 
      
       DBMS_OUTPUT.put_line (v_StudentCode ||' '|| v_CourseID); 
       var_mtb_studentelc.extend;
       
       var_mtb_studentelc(var_mtb_studentelc.count):= mRow_StudentElc2(v_batchcode,v_StudentCode,v_fullname,v_professionallevel,v_spyname,v_learnname,v_CourseID);
       
   END LOOP;
        
   
   -- 释放文档对象  
   xmldom.freedocument (doc);
   return   var_mtb_studentelc;
EXCEPTION  
   WHEN OTHERS  
   THEN  
      DBMS_OUTPUT.put_line (SQLERRM);  
END FN_GETSTUDENTCOURSEINDBBASE;
 

  

END PK_STUDENTCOURSE;
/

--
-- PK_SYSMESSAGE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_SysMessage AS
    
Procedure Pr_RecordSysMessage
(
    vMsgScope varchar2,
    vMsgContent varchar2,
    vMsgSource varchar2
)
is
/******************************************************************************
   NAME:       FN_RecordMessage
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/6/8   Administrator       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_RecordMessage
      Sysdate:         2015/6/8
      Date and Time:   2015/6/8, 16:27:38, and 2015/6/8 16:27:38
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
x_count int;
BEGIN
   x_count := 0;
   select count(1) into x_count from EAS_Sys_Message where msgScope = vMsgScope and msgContent = vMsgContent and (msgState is null or msgState =0);
   if x_count < 1 then --写入两个的原因是防止之前的还没计算完成，后边的却不让加了
     insert into EAS_Sys_Message (SN,MsgScope,MsgContent,CreateTime,MsgSource,MsgState)
     values(seq_ExmM_Message.nextVal,vMsgScope,vMsgContent,sysdate,vMsgSource,0);
   end if;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Pr_RecordSysMessage;
end PK_SysMessage;
/

--
-- PK_TRACKERSYSMESSAGE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_TrackerSysMessage AS
    procedure InsertTrackerMessage(msgScope varchar2,msgContent varchar2,msgSource varchar2)
    is
    begin
    insert into EAS_Sys_Message (SN,MsgScope,MsgContent,CreateTime,MsgSource)values(seq_ExmM_Message.nextval,msgScope,msgContent,sysdate,msgSource); 
    end;
end PK_TrackerSysMessage;
/

--
-- COMMON_PAGINGLIST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Common_PagingList(
 CurrentPage in number, --起始记录号  
 PageSize in number, --记录数   
 SortExpression in varchar(1000) , --排序字段 
 WhereExpression in varchar(1000) ,
 TableExpression in varchar(1000) ,
 TotalCount in number,
 paging_cursor out pagingPackage.paging_cursor) is
 v_sql varchar2(5000);
 v_begin number:=(pageNow-1)*pageSizes+1;
 v_end number:=pageNow*pageSizes;
 v_sqlcount varchar2(1000);
 begin 
 /*首先执行Where Sort*/
 
 if WhereExpression is null then 
     v_sql := ' select *,rownum as RN from '||TableExpression||' where 1=1 '||WhereExpression;
     v_sqlcount := 'select count(*) from '||TableExpression||' where 1=1 '||WhereExpression; 
 end if;
 if SortExpression is null then
    v_sql :=v_sql||' order by ' ||SortExpression;
 
    v_sql := 'select * from ('||v_sql||') where RN>= '||v_begin ||' AND RN<'||v_end ;
 open paging_cursor for v_sql;
 
 execute immediate v_sql into TotalCount; 
 --close paging_cursor
 end if;
/

--
-- LOOPPROC  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.loopproc (inval NUMBER) 

IS

  tmpvar   NUMBER;

  tmpvar2   NUMBER;

  total     NUMBER;

BEGIN

  tmpvar := 0;

  tmpvar2 := 0;

  total := 0;

  FOR lcv IN 1 .. inval

  LOOP

      total := 2 * total + 1 - tmpvar2;

      tmpvar2 := tmpvar;

      tmpvar := total;

  END LOOP;

  DBMS_OUTPUT.put_line ('TOTAL IS: ' || total);

END loopproc;
/

--
-- OUTPUT_DATE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.output_date is

　　begin

　　dbms_output.put_line(sysdate);

　　end output_date;
/

--
-- PROGRADTRAILLISTPROCESS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.ProGradTrailListProcess(
    InSegmentCode varchar2,
    OutCount out int
    )
IS
   mySegmentCode varchar2(100);
   x_FACount int;
BEGIN
    mySegmentCode := InSegmentCode ||'%';
    OutCount := 0;
   --获取学生
   declare
           
    cursor c_job
    is
    select student.studentCode,gradStudent.GradType,gradStudent.AuditGardType,gradStudent.AuditDegrType,orgC.OrganizationCode  as collegeCode,student.learningCenterCode from EAS_SchRoll_Student student inner join EAS_Grad_Student gradStudent on student.studentCode = gradStudent.studentCode
     inner join EAS_Org_BasicInfo orgC on ORGC.PARENTCODE = InSegmentCode and OrganizationType ='3'
     where student.learningCenterCode like mySegmentCode;
    c_row c_job%rowtype;
    begin
      for c_row in c_job loop
      --在初审名单中是否存在
           x_FACount := 0;
           select count(1) into x_FACount from EAS_Grad_FirstAudit where StudentCode = c_row.studentCode;
         if c_row.AuditGardType =1 then
           if x_FACount = 0 then
             insert into 
             EAS_Grad_FirstAudit (studentCode,segmentCode,CollageCode,LearningCenterCode,MaintainDate)
             values
             (c_row.studentCode,InSegmentCode,c_row.collegecode,c_row.learningCenterCode,sysdate);
           end if;
         else
           if x_FACount != 0 then
             delete from EAS_Grad_FirstAudit where studentCode = c_row.studentCode;
           end if;
         end if;
      end loop;
    end;
   outCount := 1;
END ProGradTrailListProcess;
/

--
-- PR_COPYSEMESTEROPENCOURSES  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_CopySemesterOpenCourses(
i_orgCode in varchar,
i_frombatchcode in varchar,
i_targetBatchcode in varchar
) IS

/******************************************************************************
   NAME:       Pr_CopySemesterOpenCourses
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/9   liufengshuan       1. Created this procedure.

   NOTES:复制选中年度学期分部课程到指定的学期
   
******************************************************************************/
BEGIN

/*
--A.分部课程总表
     select * from EAS_TCP_SegmentCourses etsc ;
--B. 源数据
SELECT    T.* FROM EAS_TCP_SegmentSemesterCourses T  WHERE 1=1  AND T.OrgCode='120'  AND T.YearTerm='200903';--源年度学期
--C. 指导性模块课程
select * from EAS_TCP_ModuleCourses;
--D.实施性模块课程
select * from EAS_TCP_ImplModuleCourse;

--fff.视图 课程组成
select * from V_TCP_IMPLCOURSE;
*/



---------------组合数据
 INSERT INTO EAS_TCP_SegmSemeCourses 
 (  
  SN,
  YearTerm,  
  OrgCode,  
  CourseID,  
  Semester,  
  IsExistTCP,  
  CreateTime  
 )

select sys_guid() SN, i_targetBatchcode pYearTerm,porgCode,pCourseID,pSemester,
(case pisexisttcp when 0 then (select case when count(*)>0 then 1 else 0 end from V_TCP_IMPLCOURSE v
    where 1=1 AND v.OrgCode = i_orgCode  AND v.CourseID =pcourseID  
 and v.batchcode>=i_frombatchcode--'200803' 
 and v.batchcode<=i_targetBatchcode--'200909'
) else pisexisttcp end) isExistTCP1,sysdate CreateTime
from (
    --第一部分
  SELECT  T.YEARTERM PYEARTERM,T.ORGCODE PORGCODE,T.COURSEID PCOURSEID,T.SEMESTER PSEMESTER,T.ISEXISTTCP PISEXISTTCP FROM EAS_TCP_SegmSemeCourses T 
    left join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
    WHERE etsc.coursestate=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--源年度学期
  union 
    --- 第二部分互斥源数据
  select TYEARTERM PYEARTERM,TORGCODE PORGCODE,ecmc.NewCourseCode PCOURSEID,TSEMESTER PSEMESTER,TISEXISTTCP PISEXISTTCP from (
        --1.
        SELECT T.YEARTERM TYEARTERM,T.ORGCODE TORGCODE,T.COURSEID TCOURSEID,T.SEMESTER TSEMESTER,T.ISEXISTTCP TISEXISTTCP   FROM EAS_TCP_SegmSemeCourses T 
            inner join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
            inner join EAS_TCP_ModuleCourses etmc on t.orgcode=etmc.orgcode and t.courseid=etmc.courseid and t.yearTerm=etmc.batchcode
            WHERE 1=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--源年度学期 
            and etsc.coursestate=0 and etmc.courseNature=1
        union
            --2
            SELECT  T.YEARTERM TYEARTERM,T.ORGCODE TORGCODE,T.COURSEID TCOURSEID,T.SEMESTER TSEMESTER,T.ISEXISTTCP TISEXISTTCP  FROM EAS_TCP_SegmSemeCourses T 
            inner join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
            inner join EAS_TCP_ImplModuleCourse etimc on t.orgcode=etimc.segmentcode and t.courseid=etimc.courseid and t.yearTerm=etimc.batchcode
            WHERE 1=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--源年度学期 
            and etsc.coursestate=0 and etimc.courseNature=2
    ) tp
    left join EAS_Course_MutexCourses ecmc on tp.TCourseID=ecmc.oldCourseCode
)p;
   
   
--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_CopySemesterOpenCourses;
/

--
-- PR_EXMM_IMPORTNETSCORE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_IMPORTNETSCORE(
    i_XMLSTR VARCHAR2,
    i_ExamYear VARCHAR2,
    i_ExamMonth VARCHAR2 ,
    i_ExamSemester VARCHAR2,
    i_Maintainer  VARCHAR2 ,
    RETCODE out int)
is 
--定义xml解析
xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
doc xmldom.DOMDocument;
--节点
pNodes xmldom.DOMNODELIST;
--临时节点
tempNode XMLDOM.DOMNODE;
--子节点
chilNodes xmldom.DOMNodeList;
--总数
pCount        number;

v_studentID varchar2(40);
--插入参数

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(30);
x_CollegeCode VARCHAR2(15);
x_SegmentCode    VARCHAR2(10) ;
--查询有没有学生
v_CountStuSql VARCHAR2(2000);
v_Cou number; 

--查询是否导入过
v_IsHaveSql VARCHAR2(2000);
v_IsHave  VARCHAR2(15) ;

v_LearningCenterCode  VARCHAR2(10) ;

v_ClassCode    VARCHAR2(15) ;

v_FullName      VARCHAR2(80) ;

--查询网考科目
v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;


v_EnrollmentStatus  VARCHAR2(2) ;

--查询学分
v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

OutTotalCount NUMBER;
BEGIN 
--开起解析
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutTotalCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    x_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_CollegeCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    x_dblink := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    x_SegmentCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
    --查成绩
    v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='''|| x_ScoreCode||'''';
    execute immediate v_ScoreSql into v_Score;
    select count(StudentID) as Cou into v_Cou from EAS_SchRoll_Student where StudentCode =''||x_StudentCode||'';
    
    if v_Cou >0 then
    select StudentID,LearningCenterCode,ClassCode,FullName,EnrollmentStatus into v_studentID,v_LearningCenterCode,v_ClassCode,v_FullName,v_EnrollmentStatus  from EAS_SchRoll_Student where StudentCode =''||x_StudentCode||'';
    
    --判断学生是否在籍
    if v_EnrollmentStatus =1 then
        --查询网考科目
        v_SubjectCodeSql :='select count(SubjectCode) as SubjectCou from EAS_ExmM_NetExamSubject where SubjectCode='''|| x_SubjectCode ||'''';
            execute immediate v_SubjectCodeSql into v_SubjectCou;
        --判断网考科目是否存在
        if v_SubjectCou > 0 then
            --判断分库 112
            if x_dblink = 'ouchn112' then
            --查询当前条件下网考科目是否导入过
            v_IsHaveSql :='select count(SN) as HaveCou from EAS_ExmM_NetExamScore@ouchn112 where ExamYear = '''||i_ExamYear||''' and  ExamMonth = '''||i_ExamMonth||''' and SubjectCode = '''||x_SubjectCode||''' and StudentCode = '''||x_StudentCode||''''; 
            execute immediate v_IsHaveSql into v_IsHave;
            --判断是否导入过
            if v_IsHave =0 then
            --插入导入网考成绩表
            INSERT INTO EAS_EXMM_NETEXAMSCORE@ouchn112
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
            OutTotalCount:=OutTotalCount+1;
            end if;
            --113
            else
            --查询当前条件下网考科目是否导入过
            v_IsHaveSql :='select count(SN) as HaveCou from EAS_ExmM_NetExamScore@ouchn112 where ExamYear = '''||i_ExamYear||''' and  ExamMonth = '''||i_ExamMonth||''' and SubjectCode = '''||x_SubjectCode||''' and StudentCode = '''||x_StudentCode||''''; 
            execute immediate v_IsHaveSql into v_IsHave;
            --判断是否导入过
            if v_IsHave =0 then
            --插入导入网考成绩表
            INSERT INTO EAS_EXMM_NETEXAMSCORE@ouchn113
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (seq_ExmM_NetExamScore.Nextval@ouchn113,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
            OutTotalCount:=OutTotalCount+1;
            end if;
            end if;
        else
            --插入导入网考不成功表 原因网考科目不存在
        INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
        (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate,Reason)
        VALUES
        (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'网考科目不存在');
        end if;
    else
        --插入导入网考不成功表 原因学生不在籍
        INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
        (SN,SegmentCode,CollegeCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,Score,ScoreCode,Maintainer,MaintainDate,Reason)
        VALUES
        (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'学生不在籍');
    end if;
    else
    --插入导入网考不成功表 原因学生不存在
    INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
    (SN,SegmentCode,CollegeCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,Score,ScoreCode,Maintainer,MaintainDate,Reason)
    VALUES
    (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'学生不存在');
    end if;
    
    COMMIT;
    
   END LOOP;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=OutTotalCount;
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_IMPORTNETSCORE;
/

--
-- PR_EXMM_IMPORTNETSCORETEST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_IMPORTNETSCORETEST(
    i_XMLSTR VARCHAR2,
    i_ExamYear VARCHAR2,
    i_ExamMonth VARCHAR2 ,
    i_ExamSemester VARCHAR2,
    i_Maintainer  VARCHAR2 ,
    RETCODE out int)
is 
--定义xml解析
xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
doc xmldom.DOMDocument;
--节点
pNodes xmldom.DOMNODELIST;
--临时节点
tempNode XMLDOM.DOMNODE;
--子节点
chilNodes xmldom.DOMNodeList;
--总数
pCount        number;

--TYPE stu_info IS REF CURSOR;
--sInfo stu_info; --定义游标变量
--sInfoSql varchar(2000);
--插入参数

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(30);
x_CollegeCode VARCHAR2(15);

v_CountStuSql VARCHAR2(2000);
v_Cou number; 

v_SegmentCodeSql VARCHAR2(2000);
v_SegmentCode    VARCHAR2(10) ;


v_IsHaveSql VARCHAR2(2000);

v_IsHave  VARCHAR2(15) ;

--v_LearningCenterCodeSql  VARCHAR2(2000);
v_LearningCenterCode  VARCHAR2(10);

--v_ClassCodeSql    VARCHAR2(2000) ;
v_ClassCode    VARCHAR2(15) ;

--v_FullNameSql VARCHAR2(2000) ;
v_FullName      VARCHAR2(80) ;


v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;


--查询学籍状态
--v_EnrollmentStatusSql VARCHAR2(2000);
v_EnrollmentStatus  VARCHAR2(2) ;

v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

v_SNSql VARCHAR2(200);
v_SN NUMBER;
OutTotalCount NUMBER;
v_start number;
v_end   number;
BEGIN 
v_start := dbms_utility.get_time;
--开起解析
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutTotalCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    x_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_CollegeCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    --x_dblink := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    
    --查成绩
    --v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='''|| x_ScoreCode||'''';
    --execute immediate v_ScoreSql into v_Score;
    

    --判断有没有学生
    v_CountStuSql :='select count(StudentID) as cou from EAS_SchRoll_Student where StudentCode ='''||x_StudentCode||'''';
    execute immediate v_CountStuSql into v_Cou;
    v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
                execute immediate v_SNSql into v_SN;
    INSERT INTO EAS_ExmM_NetExamScore@ouchn112 
    (SN,SubjectCode,StudentCode,CollegeCode,ScoreCode,ExamYear,ExamMonth,ExamSemester,Maintainer,MaintainDate)
    values (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SubjectCode,x_StudentCode,x_CollegeCode,x_ScoreCode,i_ExamYear,i_ExamMonth,i_ExamSemester,i_Maintainer,SYSDATE);
    --COMMIT;
    OutTotalCount:=OutTotalCount+SQL%ROWCOUNT;
   
   END LOOP;
   v_end := dbms_utility.get_time;
   DBMS_OUTPUT.PUT_LINE(v_end-v_start);
   --CLOSE sInfo;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=OutTotalCount;
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_IMPORTNETSCORETEST;
/

--
-- PR_EXMM_SIGNUP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_SIGNUP(
    i_XMLSTR VARCHAR2,
    i_ExamYear VARCHAR2,
    i_ExamMonth VARCHAR2 ,
    i_ExamSemester VARCHAR2,
    i_Maintainer  VARCHAR2 ,
    RETCODE out int)
is 
--定义xml解析
xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
doc xmldom.DOMDocument;
--节点
pNodes xmldom.DOMNODELIST;
--临时节点
tempNode XMLDOM.DOMNODE;
--子节点
chilNodes xmldom.DOMNodeList;
--总数
pCount        number;

--插入参数

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(15);
x_CollegeCode VARCHAR2(15);

v_CountStuSql VARCHAR2(2000);
v_Cou number; 

v_SegmentCodeSql VARCHAR2(2000);
v_SegmentCode    VARCHAR2(10) ;

--v_CollegeCodeSql VARCHAR2(2000);
--v_CollegeCode  VARCHAR2(15) ;

v_LearningCenterCodeSql  VARCHAR2(2000);
v_LearningCenterCode  VARCHAR2(10);

v_ClassCodeSql    VARCHAR2(2000) ;
v_ClassCode    VARCHAR2(15) ;

v_FullNameSql VARCHAR2(2000) ;
v_FullName      VARCHAR2(80) ;

v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;

v_IsExptNetExam    NUMBER ;
v_IsRecord  NUMBER ;
v_IsReplaceDegreeCourse  NUMBER;

--查询学籍状态
v_EnrollmentStatusSql VARCHAR2(2000);
v_EnrollmentStatus  VARCHAR2(2) ;

v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

v_SNSql VARCHAR2(200);
v_SN NUMBER;
OutTotalCount NUMBER;
BEGIN 
--开起解析
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutTotalCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    x_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_CollegeCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    x_dblink := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));

    
    --查学习中心代码根据学号
    v_LearningCenterCodeSql :='select LearningCenterCode from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_LearningCenterCodeSql into v_LearningCenterCode;

    --查学院代码根据学习中心
    --v_CollegeCodeSql :='select ParentCode from EAS_Org_BasicInfo where OrganizationCode ='||v_LearningCenterCode;
    --execute immediate v_CollegeCodeSql into v_CollegeCode;

    --查分部代码根据学院
    v_SegmentCodeSql :='select ParentCode from EAS_Org_BasicInfo where OrganizationCode ='||x_CollegeCode;
    execute immediate v_SegmentCodeSql into v_SegmentCode;

    --查班代码根据学号
    v_ClassCodeSql :='select ClassCode from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_ClassCodeSql into v_ClassCode;

    --查姓名根据学号
    v_FullNameSql :='select FullName from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_FullNameSql into v_FullName;

    --查网考科目是否存在
    v_SubjectCodeSql :='select count(SubjectCode) as SubjectCou from EAS_ExmM_NetExamSubject where SubjectCode='|| x_SubjectCode;
    execute immediate v_SubjectCodeSql into v_SubjectCou;
    
    --查成绩
    v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='|| x_ScoreCode;
    execute immediate v_ScoreSql into v_Score;

    --判断有没有学生
    v_CountStuSql :='select count(StudentID) as cou from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_CountStuSql into v_Cou;

    if v_Cou > 0 then 
    --查询学生学籍状态
    v_EnrollmentStatusSql :='select EnrollmentStatus from EAS_ExmM_NetExamSubjectCourse where StudentCode ='||x_StudentCode;
        execute immediate v_EnrollmentStatusSql into v_EnrollmentStatus;
    if v_EnrollmentStatus = 1 then
        if v_SubjectCou > 0 then
        if x_dblink = 'ouchn112' then
            v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
            execute immediate v_SNSql into v_SN;
            INSERT INTO EAS_ExmM_NetExamScore@ouchn112
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (v_SN,v_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
        else
            v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn113 as SN  from dual'; 
            execute immediate v_SNSql into v_SN;
            INSERT INTO EAS_ExmM_NetExamScore@ouchn113
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES (v_SN,v_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
        end if;
        else
            v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
            execute immediate v_SNSql into v_SN;
            INSERT INTO EAS_ExmM_NetExamScoreLost@ouchn112
        (SN,ExamYear,ExamMonth,CollegeCode,ExamSemester,SubjectCode,StudentCode,Maintainer,MaintainDate,Reason,LearningCenterCode,FullName,SegmentCode,ScoreCode)
        VALUES(v_SN,i_ExamYear,i_ExamMonth,x_CollegeCode,i_ExamSemester,x_SubjectCode,x_StudentCode,i_Maintainer,SYSDATE,'网考科目不存在',v_LearningCenterCode,v_FullName,v_SegmentCode,x_ScoreCode);
        end if;
    
    else
        v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
        execute immediate v_SNSql into v_SN;
        INSERT INTO EAS_ExmM_NetExamScoreLost@ouchn112
        (SN,ExamYear,ExamMonth,CollegeCode,ExamSemester,SubjectCode,StudentCode,Maintainer,MaintainDate,Reason,LearningCenterCode,FullName,SegmentCode,ScoreCode,Score)
        VALUES(v_SN,i_ExamYear,i_ExamMonth,x_CollegeCode,i_ExamSemester,x_SubjectCode,x_StudentCode,i_Maintainer,SYSDATE,'学生不在籍',v_LearningCenterCode,v_FullName,v_SegmentCode,x_ScoreCode,v_Score);
    end if;

    else
    --插入导入不成功表 原因 学生不存在
    v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
    execute immediate v_SNSql into v_SN;
    INSERT INTO EAS_ExmM_NetExamScoreLost@ouchn112 
    (SN,ExamYear,ExamMonth,CollegeCode,ExamSemester,SubjectCode,StudentCode,Maintainer,MaintainDate,Reason,Score)
    VALUES(v_SN,i_ExamYear,i_ExamMonth,x_CollegeCode,i_ExamSemester,x_SubjectCode,x_StudentCode,i_Maintainer,SYSDATE,'学号不存在',v_Score);
    end if;
    COMMIT;
    OutTotalCount:=OutTotalCount+1;
   
   END LOOP;
       
   XMLDOM.FREEDOCUMENT(doc);
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_SIGNUP;
/

--
-- PR_GETPAGER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pr_GetPager(
pageNo in number,--数据页数，从1开始
pageSize in number,--每页大小
tableName nvarchar2,--表名
whereSQL nvarchar2,--where条件
orderBY nvarchar2,
totalCount out number,--总记录数
v_cur out pkg_query.cur_query) is

strSql varchar2(2000);--获取数据的sql语句
pageCount number;--该条件下记录页数
startIndex number;--开始记录
endIndex number;--结束记录

begin
  strSql:='select count(1) from '||tableName;
  if whereSQL is not null or whereSQL<>'' then 
     strSql:=strSql||' where '||whereSQL;
  end if;  
  EXECUTE IMMEDIATE strSql INTO totalCount;
  --计算数据记录开始和结束
  pageCount:=totalCount/pageSize+1;
  startIndex:=(pageNo-1)*pageSize+1;
  endIndex:=pageNo*pageSize;
  
  strSql:='select rownum ro, t.* from '||tableName||' t';  
  strSql:=strSql||' where rownum<='||endIndex;
  
  if whereSQL is not null or whereSQL<>'' then 
     strSql:=strSql||' and '||whereSQL;
  end if;
  
  if  orderBY is not null or orderBY<>'' then 
     strSql:=strSql||' order by '||orderBY;
  end if;
  
  strSql:='select * from ('||strSql||') where ro >='||startIndex;  
  DBMS_OUTPUT.put_line(strSql);

  OPEN v_cur FOR strSql; 
end pr_GetPager; 
/

--
-- PR_TCP_ADD_CONVERSIONCOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Add_ConversionCourse(
inTCPCode in varchar2,--专业规则编码
inSegOrgCode in varchar2,--分部编码
inLearningCenterCode in varchar2--学习中学编码
)
AS
CourseID EAS_TCP_ConversionCourse.CourseID%TYPE;--课程ID
CourseState EAS_Course_BasicInfo.State%TYPE;--课程状态
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   --创建游标
   DECLARE CURSOR myCusor IS 
    --查询专业规则管理_教学计划模块课程，并取出基本课程中该课程的状态
    SELECT etmc.CourseID,ecbi.State FROM EAS_TCP_ConversionCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);--学习中心课程总表中不存在
        BEGIN
            OPEN myCusor;            
                LOOP
                    BEGIN
                        --循环取出数值
                        FETCH myCusor INTO CourseID,CourseState;
                        --没有数据，退出循环
                        EXIT WHEN myCusor%NOTFOUND;
                        --将课程信息插入到专业规则管理_学习中心课程总表中
                        INSERT INTO EAS_TCP_LearCentCourse
                            ( SN,
                              SegOrgCode ,
                              LearningCenterCode ,
                              CourseID ,
                              CourseState ,
                              CreateTime
                            )
                        VALUES  (seq_TCP_LearCentCour.nextval ,
                                  inSegOrgCode , -- SegOrgCode - nvarchar(4)
                                  inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
                                  CourseID , -- CourseID - nvarchar(5)
                                  CourseState , -- CourseState - tinyint
                                  to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
                                );
--                                dbms_output.put_line( CourseID||CourseState);
                     END;
                END LOOP;
            CLOSE myCusor;
        END;   
END Pr_TCP_Add_ConversionCourse;
/

--
-- PR_TCP_ADD_EXECMODULECOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_ADD_ExecModuleCourse(
inTCPCode in varchar2,--专业规则编码
inSegOrgCode in varchar2,--分部编码
inLearningCenterCode in varchar2--学习中学编码
)
AS
CourseID EAS_TCP_ExecModuleCourse.CourseID%TYPE;--课程ID
CourseState EAS_Course_BasicInfo.State%TYPE;--课程状态
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   --创建游标
   DECLARE CURSOR myCusor IS 
    --查询专业规则管理_教学计划模块课程，并取出基本课程中该课程的状态
    SELECT etmc.CourseID,ecbi.State FROM EAS_TCP_ExecModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);--学习中心课程总表中不存在
        BEGIN
            OPEN myCusor;            
                LOOP
                    BEGIN
                        --循环取出数值
                        FETCH myCusor INTO CourseID,CourseState;
                        --没有数据，退出循环
                        EXIT WHEN myCusor%NOTFOUND;
                        --将课程信息插入到专业规则管理_学习中心课程总表中
                        INSERT INTO EAS_TCP_LearCentCourse
                            ( SN,
                              SegOrgCode ,
                              LearningCenterCode ,
                              CourseID ,
                              CourseState ,
                              CreateTime
                            )
                        VALUES  (seq_TCP_LearCentCour.nextval ,
                                  inSegOrgCode , -- SegOrgCode - nvarchar(4)
                                  inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
                                  CourseID , -- CourseID - nvarchar(5)
                                  CourseState , -- CourseState - tinyint
                                  to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
                                );
--                                dbms_output.put_line( CourseID||CourseState);
                     END;
                END LOOP;
            CLOSE myCusor;
        END;   
END PR_TCP_ADD_ExecModuleCourse;
/

--
-- PR_TCP_ADD_IMPLMODULECOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_ADD_ImplModuleCourse(
inTCPCode in varchar2,--专业规则编码
inSegOrgCode in varchar2,--分部编码
inLearningCenterCode in varchar2--学习中学编码
)
AS
CourseID EAS_TCP_ImplModuleCourse.CourseID%TYPE;--课程ID
CourseState EAS_Course_BasicInfo.State%TYPE;--课程状态
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，将(专业规则管理_实施性教学计模块课程)添加到(专业规则管理_学习中心课程总表)

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   --创建游标
   DECLARE CURSOR myCusor IS 
    --查询专业规则管理_教学计划模块课程，并取出基本课程中该课程的状态
    SELECT etmc.CourseID,ecbi.State FROM EAS_TCP_ImplModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=2 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);--学习中心课程总表中不存在
        BEGIN
            OPEN myCusor;            
                LOOP
                    BEGIN
                        --循环取出数值
                        FETCH myCusor INTO CourseID,CourseState;
                        --没有数据，退出循环
                        EXIT WHEN myCusor%NOTFOUND;
                        --将课程信息插入到专业规则管理_学习中心课程总表中
                        INSERT INTO EAS_TCP_LearCentCourse
                            ( SN,
                              SegOrgCode ,
                              LearningCenterCode ,
                              CourseID ,
                              CourseState ,
                              CreateTime
                            )
                        VALUES  (seq_TCP_LearCentCour.nextval ,
                                  inSegOrgCode , -- SegOrgCode - nvarchar(4)
                                  inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
                                  CourseID , -- CourseID - nvarchar(5)
                                  CourseState , -- CourseState - tinyint
                                  to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
                                );
--                                dbms_output.put_line( CourseID||CourseState);
                     END;
                END LOOP;
            CLOSE myCusor;
        END;   
END PR_TCP_ADD_ImplModuleCourse;
/

--
-- PR_TCP_ADD_MODULECOURSES  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_ADD_ModuleCourses(
inTCPCode in varchar2,--专业规则编码
inSegOrgCode in varchar2,--分部编码
inLearningCenterCode in varchar2--学习中学编码
)
AS
CourseID EAS_TCP_ModuleCourses.CourseID%TYPE;--课程ID
CourseState EAS_Course_BasicInfo.State%TYPE;--课程状态
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/26   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，将(专业规则管理_教学计划模块课程)添加到(专业规则管理_学习中心课程总表)

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 14:54:33, and 2014/3/26 14:54:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   --创建游标
   DECLARE CURSOR myCusor IS 
    --查询专业规则管理_教学计划模块课程，并取出基本课程中该课程的状态
    SELECT etmc.CourseID,ecbi.State FROM EAS_TCP_ModuleCourses etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=1 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);--学习中心课程总表中不存在
        BEGIN
            OPEN myCusor;            
                LOOP
                    BEGIN
                        --循环取出数值
                        FETCH myCusor INTO CourseID,CourseState;
                        --没有数据，退出循环
                        EXIT WHEN myCusor%NOTFOUND;
                        --将课程信息插入到专业规则管理_学习中心课程总表中
                        INSERT INTO EAS_TCP_LearCentCourse
                            ( SN,
                              SegOrgCode ,
                              LearningCenterCode ,
                              CourseID ,
                              CourseState ,
                              CreateTime
                            )
                        VALUES  (seq_TCP_LearCentCour.nextval ,
                                  inSegOrgCode , -- SegOrgCode - nvarchar(4)
                                  inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
                                  CourseID , -- CourseID - nvarchar(5)
                                  CourseState , -- CourseState - tinyint
                                  to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
                                );
--                                dbms_output.put_line( CourseID||CourseState);
                     END;
                END LOOP;
            CLOSE myCusor;
        END;   
END PR_TCP_ADD_ModuleCourses;
/

--
-- PR_TCP_ADD_SEGMSEMECOURSBYTERM  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Add_SegmSemeCoursByTerm(
v_orgCode in varchar,--机构 
v_yearTerm in varchar--学期
) IS

vv_orgCode varchar(15) :=v_orgCode;
vv_yearTerm varchar(20) :=v_yearTerm;
/******************************************************************************
   NAME:       Pr_AddSegmSemeCourseByYearTerm
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/1   liufengshuan       1. Created this procedure.

   NOTES:分部学期开设课程管理----按学期开设
******************************************************************************/
BEGIN

insert into EAS_TCP_SegmSemeCourses(SN,YearTerm,OrgCode,CourseID,Semester,IsExistTCP,CreateTime )
select sys_guid() SN,TPBatchCode YearTerm,TPOrgCode,TPCourseID,1 Semester,tisExistTcp ,sysdate CreateTime from (

    select vti.BatchCode TPBatchCode,vti.OrgCode TPOrgCode,vti.CourseID TPCourseID,vti.IsExistTCP tisExistTcp ,vti.OpenedSemester TPOpenedSemester
     from V_TCP_IMPLCOURSE vti
     right join EAS_TCP_SegmentCourses ets on vti.OrgCode=ets.orgCode AND vti.CourseID=ets.CourseID and ets.courseState=1
     where vti.OrgCode = vv_orgCode
    union
    --取停用课程的互斥课
    select TPBatchCode,TPOrgCode,ecmc.NewCourseCode TPCourseID,tisExistTcp ,TPOpenedSemester from (
        select vti.BatchCode TPBatchCode,vti.OrgCode TPOrgCode,vti.CourseID TPCourseID,vti.IsExistTCP tisExistTcp,vti.OpenedSemester TPOpenedSemester
         from V_TCP_IMPLCOURSE vti
         right join EAS_TCP_SegmentCourses ets on vti.OrgCode=ets.orgCode AND vti.CourseID=ets.CourseID and ets.courseState=0--课程状态停用
         left join EAS_TCP_ModuleCourses etmc on vti.orgcode=etmc.orgcode and vti.courseId=etmc.courseID and vti.batchcode=etmc.batchcode and vti.tcpcode=etmc.tcpcode
         where (etmc.COURSENATURE=1 or etmc.coursenature=2) and vti.OrgCode = vv_orgCode
    )tp
    left join EAS_Course_MutexCourses ecmc on tp.TpCourseID=ecmc.oldCourseCode
    
 )tp
join  (
    select  BATCHCODE, rownum num   from EAS_TCP_RECRUITBATCH a
    where BATCHCODE<=vv_yearTerm  
    and rownum<=4
    order by BATCHCODE desc
)TB on tp.TPBatchCode=TB.batchcode and tp.TPOpenedSemester=TB.num
where 1=1
and not exists(
SELECT 1 
 FROM EAS_TCP_SegmSemeCourses
 where CourseID=TPCourseID AND OrgCode=TPorgCode AND YearTerm=TPBatchCode
);

END Pr_TCP_Add_SegmSemeCoursByTerm;
/

--
-- PR_TCP_COPY_SEGMSEMEOPENCOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Copy_SegmSemeOpenCourse(
i_orgCode in varchar,
i_frombatchcode in varchar,
i_targetBatchcode in varchar
) IS

/******************************************************************************
   NAME:       Pr_CopySemesterOpenCourses
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/9   liufengshuan       1. Created this procedure.

   NOTES:分部学期开设课程管理-- 复制学期开设课程
   复制选中年度学期分部课程到指定的学期
   
******************************************************************************/
BEGIN

/*
--A.分部课程总表
     select * from EAS_TCP_SegmentCourses etsc ;
--B. 源数据
SELECT    T.* FROM EAS_TCP_SegmentSemesterCourses T  WHERE 1=1  AND T.OrgCode='120'  AND T.YearTerm='200903';--源年度学期
--C. 指导性模块课程
select * from EAS_TCP_ModuleCourses;
--D.实施性模块课程
select * from EAS_TCP_ImplModuleCourse;

--fff.视图 课程组成
select * from V_TCP_IMPLCOURSE;
*/



---------------组合数据
 INSERT INTO EAS_TCP_SegmSemeCourses 
 (  
  SN,
  YearTerm,  
  OrgCode,  
  CourseID,  
  Semester,  
  IsExistTCP,  
  CreateTime  
 )

select sys_guid() SN, i_targetBatchcode pYearTerm,porgCode,pCourseID,pSemester,
(case pisexisttcp when 0 then (select case when count(*)>0 then 1 else 0 end from V_TCP_IMPLCOURSE v
    where 1=1 AND v.OrgCode = i_orgCode  AND v.CourseID =pcourseID  
 and v.batchcode>=i_frombatchcode--'200803' 
 and v.batchcode<=i_targetBatchcode--'200909'
) else pisexisttcp end) isExistTCP1,sysdate CreateTime
from (
    --第一部分
  SELECT  T.YEARTERM PYEARTERM,T.ORGCODE PORGCODE,T.COURSEID PCOURSEID,T.SEMESTER PSEMESTER,T.ISEXISTTCP PISEXISTTCP FROM EAS_TCP_SegmSemeCourses T 
    left join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
    WHERE etsc.coursestate=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--源年度学期
  union 
    --- 第二部分互斥源数据
  select TYEARTERM PYEARTERM,TORGCODE PORGCODE,ecmc.NewCourseCode PCOURSEID,TSEMESTER PSEMESTER,TISEXISTTCP PISEXISTTCP from (
        --1.
        SELECT T.YEARTERM TYEARTERM,T.ORGCODE TORGCODE,T.COURSEID TCOURSEID,T.SEMESTER TSEMESTER,T.ISEXISTTCP TISEXISTTCP   FROM EAS_TCP_SegmSemeCourses T 
            inner join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
            inner join EAS_TCP_ModuleCourses etmc on t.orgcode=etmc.orgcode and t.courseid=etmc.courseid and t.yearTerm=etmc.batchcode
            WHERE 1=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--源年度学期 
            and etsc.coursestate=0 and etmc.courseNature=1
        union
            --2
            SELECT  T.YEARTERM TYEARTERM,T.ORGCODE TORGCODE,T.COURSEID TCOURSEID,T.SEMESTER TSEMESTER,T.ISEXISTTCP TISEXISTTCP  FROM EAS_TCP_SegmSemeCourses T 
            inner join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
            inner join EAS_TCP_ImplModuleCourse etimc on t.orgcode=etimc.segmentcode and t.courseid=etimc.courseid and t.yearTerm=etimc.batchcode
            WHERE 1=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--源年度学期 
            and etsc.coursestate=0 and etimc.courseNature=2
    ) tp
    left join EAS_Course_MutexCourses ecmc on tp.TCourseID=ecmc.oldCourseCode
)p;
   
   
--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_TCP_Copy_SegmSemeOpenCourse;
/

--
-- PR_TCP_DEL_DELETEGUIDANCETCP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Del_DeleteGuidanceTCP
(
  i_TCPCode in EAS_TCP_GUIDANCE.TCPCODE%type--专业规则
)
 IS
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

    end if;
    
--   tmpVar := 0;
--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_TCP_Del_DeleteGuidanceTCP;
/

--
-- PR_TCP_ENABLE_GUIDANCEENABLED  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Enable_GuidanceEnabled(
    i_TCPCode in EAS_TCP_GUIDANCE.TCPCODE%type,--专业规则
    i_EnableUser in  EAS_TCP_GUIDANCE.EnableUser%type--启用操作人
) IS
v_tcpCode EAS_TCP_GUIDANCE.TCPCODE%type;--专业规则
v_batchcode EAS_TCP_GUIDANCE.BATCHCODE %type;--学期
/******************************************************************************
   NAME:       Pr_GuidanceEnabled
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/16   liufengshuan       1. Created this procedure.

   NOTES:指导性专业规则--启用

******************************************************************************/
BEGIN

--1.根据TCPCode获取指导性教学计划表业务实体
    SELECT  
      TCPCode,BatchCode into v_tcpCode,v_batchcode FROM EAS_TCP_Guidance WHERE TCPCode = i_TCPCode ;

--2.将指导性专业规则复制到实施性专业规则表中
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

--3.复制指导性专业规则的启用规则到实施性教学计划中相应的启用规则
 
   insert into EAS_TCP_ImplOnRule
        (SN,Batchcode,SegmentCode,TCPCode,ModuleTotalCredits,TotalCredits)
     select 
        seq_TCP_ImplOnRule.nextval SN, 
        d.BatchCode, c.SegmentCode,d.TCPCode
        ,(
            select nvl(sum(Credit),0.000) ModuleCredit from EAS_TCP_ModuleCourses
            where CourseNature=1 and Batchcode=v_batchcode and TCPCode=i_TCPCode
        ) ModuleTotalCredits--模板总学分
        ,(
             select nvl(sum(CenterCompulsoryCourseCredit),0.000) from EAS_TCP_GuidanceOnModuleRule
             where 1=1 and Batchcode=v_batchcode and TCPCode=i_TCPCode
        ) TotalCredits--总部考试总学分
    from EAS_TCP_GuidanceOnRule g
    left join EAS_TCP_Guidance d on g.TCPCode=d.TCPCode and g.BatchCode=d.BatchCode 
    left join EAS_Spy_OpenSpySegment c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
    and c.ProfessionalLevel=d.ProfessionalLevel 
    where 1=1
    and c.OpenState='1' and  g.TCPCode=i_TCPCode and g.BatchCode=v_batchcode;
    
--4.复制指导性专业规则的启用模块规则到实施性教学计划中相应的启用模块规则
 
    insert into EAS_TCP_ImplOnModuleRule
    ( SN,BatchCode,SegmentCode,TCPCode,ModuleCode,RequiredTotalCredits,ModuleTotalCredits,SCSegmentTotalCredits,SCCenterTotalCredits)
        select 
            seq_TCP_ImplModuRule.nextVal SN,
            g.BatchCode, c.SegmentCode, g.TCPCode,g.ModuleCode
            ,g.CenterCompulsoryCourseCredit RequiredTotalCredits --总部考试总学分
            ,g.CenterCompulsoryCourseCredit+g.SegmentCompulsoryCourseCredit ModuleTotalCredits--模块总学分
              ,'0.00' SCSegmentTotalCredits,0.00 SCCenterTotalCredits
        from EAS_TCP_GuidanceOnModuleRule g
        left join EAS_TCP_Guidance d on g.TCPCode=d.TCPCode and g.BatchCode=d.BatchCode 
        left join EAS_Spy_OpenSpySegment c on c.SpyCode=d.SpyCode and c.StudentType=d.StudentType 
        and c.ProfessionalLevel=d.ProfessionalLevel
        where 1=1
        and c.OpenState='1' and  g.TCPCode=i_TCPCode and g.BatchCode=v_batchcode;

--5. 指导性专业规则的状态为启用

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

--
-- PR_TCP_MODIFY_EXECUTIONSTATE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_Modify_ExecutionState(
inSN in varchar2,--执行性专业规则ID
inTCPCode in varchar2,--专业规则编码
inUserID in varchar2,--修改人ID
inLearningCenterCode in varchar2--学习中学编码
)
AS
D_SegOrgCode  varchar2(50);--分部编码
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，执行性专业规则启用

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN    
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;   
begin
    UPDATE EAS_TCP_Execution
    SET 
    ExcState=1,
    Executor=inUserID,
    ExecuteTime=to_char(sysdate, 'hh24:mi:ss')
    WHERE SN=inSN;
    
    SELECT SegmentCode into D_SegOrgCode FROM EAS_TCP_Execution where SN=inSN;
    
    PR_TCP_ADD_ConversionCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    PR_TCP_ADD_ExecModuleCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    PR_TCP_ADD_ImplModuleCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_实施性教学计模块课程)添加到(专业规则管理_学习中心课程总表)
    PR_TCP_ADD_ModuleCourses(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    end;
    
    --如果存在异常，回滚数据
    exception when others then
    begin
        rollback;
    end;
    
    commit;
END PR_TCP_Modify_ExecutionState;
/

--
-- PR_TCP_MODIFY_EXECUTIONSTATE_T  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_Modify_ExecutionState_T(
inSN in varchar2,--执行性专业规则ID
inTCPCode in varchar2,--专业规则编码
inUserID in varchar2,--修改人ID
inLearningCenterCode in varchar2,--学习中学编码
OutException out varchar2--返回异常信息
)
AS
D_SegOrgCode  varchar2(50);--分部编码
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，执行性专业规则启用

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN    
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;   
begin

    --修改执行型专业规则启用状态
    UPDATE EAS_TCP_Execution
    SET 
    ExcState=1,
    Executor=inUserID,
    ExecuteTime=to_char(sysdate, 'hh24:mi:ss')
    WHERE SN=inSN;
    
    --获取分部编码
    SELECT SegmentCode into D_SegOrgCode FROM EAS_TCP_Execution where SN=inSN;
    
    --将(专业规则管理_补修课程表)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
          SegOrgCode ,
          LearningCenterCode ,
          CourseID ,
          CourseState ,
          CreateTime
        )
    SELECT 
        seq_TCP_LearCentCour.nextval ,
        D_SegOrgCode , -- SegOrgCode - nvarchar(4)
        inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
        etmc.CourseID,
        ecbi.State,
        to_char(sysdate, 'hh24:mi:ss') 
    FROM EAS_TCP_ConversionCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE TCPCode=inTCPCode--专业规则编号相同
    AND NOT exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    --将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
        SegOrgCode ,
        LearningCenterCode ,
        CourseID ,
        CourseState ,
        CreateTime
        )
    SELECT
        seq_TCP_LearCentCour.nextval ,
        D_SegOrgCode , -- SegOrgCode - nvarchar(4)
        inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
        etmc.CourseID , -- CourseID - nvarchar(5)
        ecbi.State , -- CourseState - tinyint
        to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
    FROM EAS_TCP_ExecModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE TCPCode=inTCPCode--专业规则编号相同
    AND ETMC.LEARNINGCENTERCODE=inLearningCenterCode--学习中心编码条件
    AND not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);  
    
    --将(专业规则管理_实施性教学计模块课程)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
        SegOrgCode ,
        LearningCenterCode ,
        CourseID ,
        CourseState ,
        CreateTime
        )
    SELECT  
    seq_TCP_LearCentCour.nextval ,
    D_SegOrgCode , -- SegOrgCode - nvarchar(4)
    inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
    etmc.CourseID , -- CourseID - nvarchar(5)
    ecbi.State , -- CourseState - tinyint
    to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
    FROM EAS_TCP_ImplModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=2 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and ETMC.SEGMENTCODE=D_SegOrgCode--分部条件
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    --将(专业规则管理_教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
        SegOrgCode ,
        LearningCenterCode ,
        CourseID ,
        CourseState ,
        CreateTime
        )
    SELECT  
    seq_TCP_LearCentCour.nextval ,
    D_SegOrgCode , -- SegOrgCode - nvarchar(4)
    inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
    etmc.CourseID , -- CourseID - nvarchar(5)
    ecbi.State , -- CourseState - tinyint
    to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
    FROM EAS_TCP_ModuleCourses etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=1 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    END;
    
    --如果存在异常，回滚数据
    exception when others then
    begin
    OutException:=sqlerrm;
        rollback;
    end;
    OutException:='执行成功';
    commit;
END PR_TCP_Modify_ExecutionState_T;
/

--
-- P_XMLPARSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.p_xmlparse 
(p_xml   IN     CLOB,  
r_cur      OUT SYS_REFCURSOR)
IS
   -- xml解析器  
   xmlpar          xmlparser.parser := xmlparser.newparser;  
   -- dom文档对象  
   doc             xmldom.domdocument;  
   StudentCoursesnodes   xmldom.domnodelist;  
   StudentCode      VARCHAR2 (50);  
   CourseID      VARCHAR2 (50);
   chilnodes       xmldom.domnodelist;  
   tempnode        xmldom.domnode;  
   temparrmap      xmldom.domnamednodemap;  
  
   -- 以下变量用于获取xml节点的值  
   v_attribute     VARCHAR2 (50);  
   v_value         VARCHAR2 (50);  
   tmp             INTEGER;  
   l_sql           VARCHAR2 (32767) := 'select ';  
   ElcTotalNumber            number;
/******************************************************************************
   NAME:       p_xmlparse
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     p_xmlparse
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 9:33:10, and 2014/05/16 9:33:10
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
 
   xmlparser.parseclob (xmlpar, p_xml);  
   doc := xmlparser.getdocument (xmlpar);  
  
   -- 释放解析器实例  
   xmlparser.freeparser (xmlpar);  
  ---取总选课记录
   StudentCoursesnodes := xmldom.getelementsbytagname (doc, 'ElcRecord');  
   
   ElcTotalNumber := xmldom.getlength(StudentCoursesnodes);
   dbms_output.put_line('TotalRecords-->'|| ElcTotalNumber);
   FOR i in 0..ElcTotalNumber-1
   LOOP
     tempnode := xmldom.item (StudentCoursesnodes, i);  
     -- 获取子元素的值  
      chilnodes := xmldom.getchildnodes (tempnode);  
      tmp := xmldom.getlength (chilnodes);
      StudentCode := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,0)));
      CourseID := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,1)));
       DBMS_OUTPUT.put_line (StudentCode ||' '|| CourseID);  
   END LOOP;
        
   
   -- 释放文档对象  
   xmldom.freedocument (doc);  
EXCEPTION  
   WHEN OTHERS  
   THEN  
      DBMS_OUTPUT.put_line (SQLERRM);  
END p_xmlparse;
/

--
-- SELECTSTUDENTSOFNUM  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.SelectStudentsOfNum(lcCode in varchar2,outcount out number) IS

BEGIN
   select  count(LearningCenterCode)as mycount into outcount from EAS_SchRoll_Student where LearningCenterCode=lcCode;
   
 
END SelectStudentsOfNum;
/

--
-- SP_PAGE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.sp_Page(p_PageSize int, --每页记录数
p_PageNo int, --当前页码,从 1 开始
p_SqlSelect varchar2, --查询语句,含排序部分
p_OutRecordCount out int,--返回总记录数
p_OutCursor out refCursorType)
as
v_sql varchar2(3000);
v_count int;
v_heiRownum int;
v_lowRownum int;
begin
----取记录总数
v_sql := 'select count(*) from (' || p_SqlSelect || ')';
execute immediate v_sql into v_count;
p_OutRecordCount := v_count;
----执行分页查询
v_heiRownum := p_PageNo * p_PageSize;
v_lowRownum := v_heiRownum - p_PageSize + 1;

v_sql := 'SELECT * 
FROM (
SELECT A.*, rownum rn 
FROM ('|| p_SqlSelect ||') A
WHERE rownum <= '|| to_char(v_heiRownum) || '
) B
WHERE rn >= ' || to_char(v_lowRownum) ;
--注意对rownum别名的使用,第一次直接用rownum,第二次一定要用别名rn

OPEN p_OutCursor FOR v_sql;

end sp_Page;
/

--
-- TEST0  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.test0
IS
BEGIN
insert into test values(1,1);

END;
/

--
-- TEST2  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.test2
IS
BEGIN
insert into test values(1,1);

END;
/

--
-- TEST5  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.test5(a in number,b out number) AS 
BEGIN
	b:=a;
END;

/

--
-- UPDATEGRADAUDITCONDITIONPASS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.UpdateGradAuditConditionPass(
isGradPass int,
isDegreePass int,
inStudentCode varchar2
) IS

    x_IsDegree int;--是否申请学位
    x_Result int;
BEGIN
    x_Result := 1;
    select isDegree into x_IsDegree from EAS_Grad_Audit where studentCode = inStudentCode;
    if x_IsDegree >0 then
        if isGradPass =0 then
            x_Result := 0;
        elsif isDegreePass = 0 then
            x_Result := 0;
        end if;
    else
      if isGradPass = 0 then
        x_Result :=0;
      end if;
    end if;
    
    update EAS_Grad_Audit set IsConditionPass = x_Result where studentCode = inStudentCode;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END UpdateGradAuditConditionPass;
/

--
-- "test5"  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS."test5" AS
BEGIN
	select 1 from dual;
END;

/

--
-- EXISTS2  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.EXISTS2 (IN_SQL IN VARCHAR2)
  RETURN NUMBER
IS
  /**********************************************************
  * 使用示例
  * begin
  *   if EXISTS2('select * from dual where 1=1')=1 then
  *     dbms_output.put_line('有记录');
  *   else
  *     dbms_output.put_line('无记录');
  *   end if;
  * end;
  *****************************************************************/
  V_SQL VARCHAR2(4000);
  V_CNT NUMBER(1);
BEGIN
  V_SQL := 'SELECT COUNT(*) FROM DUAL WHERE EXISTS (' || IN_SQL || ')';
  EXECUTE IMMEDIATE V_SQL INTO V_CNT;
  RETURN(V_CNT);
END;
/

--
-- FN_BIT2NUMBER  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.FN_BIT2NUMBER(P_BIN IN VARCHAR2) RETURN NUMBER AS
  V_SQL    VARCHAR2(30000) := 'SELECT BIN_TO_NUM(';
  V_RETURN NUMBER;
BEGIN
  IF LENGTH(P_BIN) >= 256 THEN
    RAISE_APPLICATION_ERROR(-20001, 'INPUT BIN TOO LONG!');
  END IF;
  IF LTRIM(P_BIN, '01') IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'INPUT STR IS NOT VALID BIN VALUE!');
  END IF;
  FOR I IN 1 .. LENGTH(P_BIN) LOOP
    V_SQL := V_SQL || SUBSTR(P_BIN, I, 1) || ',';
  END LOOP;
  V_SQL := RTRIM(V_SQL, ',') || ') FROM DUAL';
  EXECUTE IMMEDIATE V_SQL
    INTO V_RETURN;
  RETURN V_RETURN;
END;
/

--
-- FN_ELC_GETSTUDENELC  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.fn_Elc_GetStudenElc( iindex number) RETURN mTB_StudentElc IS
var_mtb_studentelc MTB_StudentElc :=MTB_StudentElc(); 
/******************************************************************************
   NAME:       fn_Elc_GetStudenElc
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     fn_Elc_GetStudenElc
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 17:59:34, and 2014/05/16 17:59:34
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   
      for cur in (select * from eas_dic_subject) LOOP
         var_mtb_studentelc.extend;
         var_mtb_studentelc(var_mtb_studentelc.count):= mrow_studentelc(cur.dicname,cur.diccode);
       End loop;
    return var_mtb_studentelc;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END fn_Elc_GetStudenElc;
/

--
-- FN_GETNETGUID  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.fn_getNetGuid(
v_guid varchar2
)
return varchar2
as
    v_ret varchar(40):='';
begin
   if length(v_guid)=32 then
   v_ret:= substr(v_guid,1,8)||'-'||substr(v_guid,9,4)||'-'||substr(v_guid,13,4)||'-'||substr(v_guid,17,4)||'-'||substr(v_guid,21,12); 
   
   end if;
   return v_ret;
   
end fn_getNetGuid;
/

--
-- FN_GETTCPCODE  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.fn_GetTCPCode(
i_batchcode varchar2,
i_studentype varchar2,
i_professionallevel varchar2,
i_spycode varchar2
) 
RETURN varchar2 
IS
v_result varchar2(40):='';
/******************************************************************************
   NAME:       fn_GetTCPCode
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/17   liufengshuan       1. Created this function.

   NOTES: 根据学期+学生类型+层次+专业代码 

******************************************************************************/
BEGIN
   if i_batchcode is not null then
   
    v_result:= substr(i_batchcode,-4)||i_studentype||i_professionallevel||i_spycode;
    
   end if;
    return v_result;

END fn_GetTCPCode;
/

--
-- FN_HEXTOSTRING  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.FN_HEXTOSTRING(hex_value in INT) 
RETURN VARCHAR2 IS 
v_Value VARCHAR2(50) ;
tmp_value char(30);
tmp_num int;
tmp_count int;
BEGIN
    v_Value := '' ;
    tmp_num := 1;    
    tmp_value :=to_char(hex_value) ;
    
    tmp_count := length(tmp_value) ;
    while tmp_num <= tmp_count 
    loop
 
     if(substr(to_char(hex_value)  , -tmp_num , 1) = '1' ) then
    
        v_Value := concat(CONCAT(v_Value,TO_CHAR(tmp_num)) , ',' );
     
     end if ;
     tmp_num :=tmp_num+1;
    end loop;
    if length(v_Value) > 0 then
         return substr(v_Value, 0 , length(v_Value)-1) ;
    else 
         return  '' ;     
    end if;
END;
/

--
-- FN_RECORDSYSMESSAGE  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.FN_RecordSysMessage
(
    vMsgScope varchar2,
    vMsgContent varchar2,
    vMsgSource varchar2
)
RETURN NUMBER IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       FN_RecordMessage
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/6/8   Administrator       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_RecordMessage
      Sysdate:         2015/6/8
      Date and Time:   2015/6/8, 16:27:38, and 2015/6/8 16:27:38
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 1;
   insert into EAS_Sys_Message (SN,MsgScope,MsgContent,CreateTime,MsgSource)
   values(seq_ExmM_Message.nextVal,vMsgScope,vMsgContent,sysdate,vMsgSource);
   RETURN tmpVar;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END FN_RecordSysMessage;
/

--
-- GETNORMALSEMESTERS  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.GetNormalSemesters(n_byte varchar) RETURN varchar IS
  V_RTN VARCHAR(20);
  V_N1  NUMBER;
  V_N2  NUMBER;
  V_Length int;
  V_I int;
  V_X int;
BEGIN
   V_Length := length(n_byte);
   V_I :=V_Length -1;
   V_X :=1;
   loop
      V_N1 := substr(n_byte,V_I,1);
      if V_N1='1' then
        if length(V_RTN)!=0 then
            V_RTN := V_RTN ||','; 
        end if;
        V_RTN := V_RTN || (V_X);
      end if;
      
      V_I := V_I -1;
      V_X := V_X +1;
      
   exit when V_I =0;
   end loop;
   
   RETURN V_RTN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END GetNormalSemesters;
/

--
-- IDATTRIBUTEOFDOCELCMENTS  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.idAttributeOfDocElcments 
(
xmldoc in CLOB)
 RETURN varchar2 IS

/******************************************************************************
   NAME:       idAttributeOfDocElcments
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     idAttributeOfDocElcments
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 10:31:45, and 2014/05/16 10:31:45
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

 theXmlDoc xmldom.DOMDocument;
n1          xmldom.DOMNodeList;
len1        number(10);
len2        number(10);
v1          xmldom.DOMNode;
n2          xmldom.DOMNodeList;
attn        xmldom.DOMNode;
vretuval     varchar2(1000):='';
XMLParseError EXCEPTION;
    PRAGMA EXCEPTION_INIT( XMLParseError, -20100 );
    -- Local parse function keeps code cleaner. Return NULL if parse fails
    FUNCTION parse(xml CLOB) RETURN xmldom.DOMDocument IS
      retDoc xmldom.DOMDocument;
      parser xmlparser.Parser;
    BEGIN
      parser := xmlparser.newParser;
      xmlparser.ParseCLOB(parser,xml);
      retDoc := xmlparser.getDocument(parser);
      xmlparser.freeParser(parser);
      RETURN retdoc;
    EXCEPTION
       --If the parse fails, we''ll jump here.
      WHEN XMLParseError THEN
        xmlparser.freeParser(parser);
        dbms_output.put_line('errors');
       RETURN retdoc;
    END;
BEGIN
    -- Parse the xml document passed in the CLOB argument
    theXmlDoc := parse(xmldoc);
    -- If the XML document returned is not NULL...
    IF NOT xmldom.IsNull(theXmlDoc) THEN
      -- Get the outermost enclosing element (aka "Document Element")
      --theDocElt := xmldom.getDocumentElement(theXmlDoc);
      -- Get the value of the document element's "id" attribute
      n1:= xmldom.getElementsByTagName(theXmlDoc, 'HB');
      len1     := xmldom.getLength(n1);
      dbms_output.put_line(len1);
      --获得<HB></HB>节点的数量
    for i in 0 .. len1 - 1 loop
    --获得节点
      v1     := xmldom.item(n1, i);
      --获得该节点下所有的子节点
      n2     := xmldom.getChildNodes(v1);
      --获得子节点的数量
      len2 := xmldom.getLength(n2);
           for j in 0..len2-1 loop
        --dbms_output.put_line(len2);
               attn:=xmldom.item(n2,j);
               dbms_output.put_line(xmldom.getNodeValue(xmldom.getFirstChild(attn)));
           end loop;
end loop;
      -- Free the memory used by the parsed XML document
      xmldom.freeDocument(theXmlDoc);
      RETURN vretuval;
    ELSE
      RETURN vretuval;
    END IF;
END idAttributeOfDocElcments;
/

--
-- IDATTRIBUTEOFDOCELEMENTS  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.idAttributeOfDocElements 
(
xmldoc in CLOB)
 RETURN varchar2 IS

/******************************************************************************
   NAME:       idAttributeOfDocElcments
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     idAttributeOfDocElcments
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 10:31:45, and 2014/05/16 10:31:45
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

 theXmlDoc xmldom.DOMDocument;
n1          xmldom.DOMNodeList;
len1        number(10);
len2        number(10);
v1          xmldom.DOMNode;
n2          xmldom.DOMNodeList;
attn        xmldom.DOMNode;
vretuval     varchar2(1000):='';
XMLParseError EXCEPTION;
    PRAGMA EXCEPTION_INIT( XMLParseError, -20100 );
    -- Local parse function keeps code cleaner. Return NULL if parse fails
    FUNCTION parse(xml CLOB) RETURN xmldom.DOMDocument IS
      retDoc xmldom.DOMDocument;
      parser xmlparser.Parser;
    BEGIN
      parser := xmlparser.newParser;
      xmlparser.ParseCLOB(parser,xml);
      retDoc := xmlparser.getDocument(parser);
      xmlparser.freeParser(parser);
      RETURN retdoc;
    EXCEPTION
       --If the parse fails, we''ll jump here.
      WHEN XMLParseError THEN
        xmlparser.freeParser(parser);
        dbms_output.put_line('errors');
       RETURN retdoc;
    END;
BEGIN
    -- Parse the xml document passed in the CLOB argument
    theXmlDoc := parse(xmldoc);
    -- If the XML document returned is not NULL...
    IF NOT xmldom.IsNull(theXmlDoc) THEN
      -- Get the outermost enclosing element (aka "Document Element")
      --theDocElt := xmldom.getDocumentElement(theXmlDoc);
      -- Get the value of the document element's "id" attribute
      n1:= xmldom.getElementsByTagName(theXmlDoc, 'HB');
      len1     := xmldom.getLength(n1);
      dbms_output.put_line(len1);
      --获得<HB></HB>节点的数量
    for i in 0 .. len1 - 1 loop
    --获得节点
      v1     := xmldom.item(n1, i);
      --获得该节点下所有的子节点
      n2     := xmldom.getChildNodes(v1);
      --获得子节点的数量
      len2 := xmldom.getLength(n2);
           for j in 0..len2-1 loop
        --dbms_output.put_line(len2);
               attn:=xmldom.item(n2,j);
               dbms_output.put_line(xmldom.getNodeValue(xmldom.getFirstChild(attn)));
           end loop;
end loop;
      -- Free the memory used by the parsed XML document
      xmldom.freeDocument(theXmlDoc);
      RETURN vretuval;
    ELSE
      RETURN vretuval;
    END IF;
END idAttributeOfDocElements;
/

--
-- IS_NUMBER  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.is_number (
                str_in IN VARCHAR2
                ) RETURN NUMBER DETERMINISTIC PARALLEL_ENABLE IS
   n NUMBER;
BEGIN
   n := TO_NUMBER(str_in);
   RETURN 1;
EXCEPTION
   WHEN VALUE_ERROR THEN
      RETURN 0;
END;
/

--
-- SPLITSTR  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.splitstr(p_string in varchar2,p_delimiter in varchar2) RETURN str_split PIPELINED
IS
v_length NUMBER := LENGTH(p_string);
v_start  NUMBER := 1;
v_index  NUMBER;
/******************************************************************************
   NAME:       splitstr
   PURPOSE:    拆分字符串

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/03   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     splitstr
      Sysdate:         2014/06/03
      Date and Time:   2014/06/03, 14:20:43, and 2014/06/03 14:20:43
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   
 WHILE(v_start <= v_length)
    LOOP
        v_index := INSTR(p_string, p_delimiter, v_start);

        IF v_index = 0
        THEN
            PIPE ROW(SUBSTR(p_string, v_start));
            v_start := v_length + 1;
        ELSE
            PIPE ROW(SUBSTR(p_string, v_start, v_index - v_start));
            v_start := v_index + 1;
        END IF;
    END LOOP;

    RETURN;

END splitstr;
/

--
-- SPLITTOARRAY  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.splitToArray  
   (src VARCHAR2, delimiter varchar2)  
  RETURN myVarchar2 IS  
  psrc VARCHAR2(500);  
  a myVarchar2 := myVarchar2();  
  i NUMBER := 1;  --  
  j NUMBER := 1;  
BEGIN
  psrc := RTrim(LTrim(REPLACE(src,'''',''), delimiter), delimiter);  
  LOOP  
    i := InStr(psrc, delimiter, j);  
    --Dbms_Output.put_line(i);  
    IF i>0 THEN  
      a.extend;  
      a(a.Count) := Trim(SubStr(psrc, j, i-j));  
      j := i+1;  
      --Dbms_Output.put_line(a(a.Count-1));  
    END IF;  
    EXIT WHEN i=0;  
  END LOOP;  
  IF j < Length(psrc) THEN  
    a.extend;  
    a(a.Count) := Trim(SubStr(psrc, j, Length(psrc)+1-j));  
  END IF;  
  RETURN a;  
END;
/

--
-- SP_LISTSTUDENTELC  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.sp_ListStudentElc RETURN 
TYPES.CURSORTYPE  
IS
l_cursor TYPES.CURSORTYPE ;
/******************************************************************************
   NAME:       sp_ListStudentElc
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     sp_ListStudentElc
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 16:11:30, and 2014/05/16 16:11:30
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   open l_cursor for select diccode,dicname from eas_dic_subject;
   RETURN l_cursor;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END sp_ListStudentElc;
/

--
-- TESTFUN612  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.testfun612(classcode varchar2,LEARNINGCENTERCODE VARCHAR2
               
        )RETURN NUMBER
        is
               result number;
        BEGIN
           
                    SELECT count(*) as total into result FROM EAS_SCHROLL_STUDENT WHERE 1>0 AND CLASSCODE = '081200202014009' AND LEARNINGCENTERCODE = '1200202' AND ENROLLMENTSTATUS = '1';
                    return result;
        END;

/

--
-- TOBYTE  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.ToByte(V_Num int) RETURN varchar IS
  V_RTN VARCHAR(8);
  V_N1  NUMBER;
  V_N2  NUMBER;
BEGIN
  V_N1 := ABS(V_NUM);
  --如果为正数
  IF SIGN(V_NUM) > 0 THEN
    LOOP
      V_N2  := MOD(V_N1, 2);
      V_N1  := ABS(TRUNC(V_N1 / 2));
      V_RTN := TO_CHAR(V_N2) || V_RTN;
      EXIT WHEN V_N1 = 0;
    END LOOP;
  else
  RETURN '';
  end if;
   RETURN V_RTN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END ToByte;
/

--
-- "testf"  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS."testf" RETURN -- VARCHAR2
AS
BEGIN
	-- routine body goes here, e.g.
	-- DBMS_OUTPUT.PUT_LINE('Navicat for Oracle');
	RETURN NULL;
END;
/

--
-- COL_EXECMODULECOURSE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."COL_EXECMODULECOURSE"                                                                                  
AS TABLE OF TYP_EXECMODULECOURSE
/

--
-- COL_MODULERULE  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."COL_MODULERULE"                                                                                  
AS TABLE OF TYP_MODULERULE
/

--
-- PK_EXMM  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXMM AS
/******************************************************************************
   NAME:       PK_EXMM
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-10-23      libin       1. Created this package.
******************************************************************************/
/* 对象定义   */
  --------------------------时间单元部分------
   TYPE SessionUnit_Array IS varray(8) of varchar2(80); --存储时间单元
 
   -------------------------考试日期数组--------
   TYPE ExamDate_array IS TABLE OF date INDEX BY BINARY_INTEGER; --存储考试日期自动增加类型
  
  ----  考试试卷列表 自动增加类型
    TYPE t_PaperArray is table of varchar2(30) index by binary_integer; 
  
  
 
/*      存储过程定义 */
  -- 自动建立或追加计划开考课程
  PROCEDURE PR_EXMM_BATCHADDEXAMCOURSEPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_OperateType IN number,RETCODE OUT varchar2) ;
  
  --继承开考课程
  PROCEDURE PR_EXMM_INHERITEXAMCOURSEPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2);
  
  
  -- 自动建立或追加计划开考科目
  PROCEDURE PR_EXMM_BATCHADDSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_EXAMTIMELENGTH IN number ,i_OperateType IN number,RETCODE OUT varchar2) ;

 --继承计划开考科目
  PROCEDURE PR_EXMM_INHERITSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2);
    
 -- i_planSN 考试定义SN  i_SegmentCode 分部代码  i_tbFrom 从1主表2下发表取数据 arrRet 返回对应的考试开始时间数据
  PROCEDURE PR_EXMM_GETSESSIONUNIT(i_PlanSN number,i_CategoryCode varchar2, i_SegmentCode varchar2,i_tbFrom number,arrRet OUT SessionUnit_Array);
  ------返回考试日期 i_Operate 1 只使用新时间段 2 使用扩展时间段
  PROCEDURE PR_EXMM_GETEXAMDATELIST(i_NewBeginDate date,i_NewEndDate date,i_ExistBeginDate date,i_ExistEndDate date,i_Operate number,ExamDatelist out ExamDate_array);
  
      --返回考试计划对象
  PROCEDURE PR_EXMM_GETEXAMPLANOBJ(i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,r_ExamPlan OUT EXAMPLAN);
  ----返回相应的考试时间对象
   PROCEDURE PR_EXMM_GETEXAMTIMEOBJ(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,i_OperateType number,r_EXAMTIME out EXAMTIME);
   
   ----判断计划开考课程试卷数与计划开考科目试卷数是否一致
   PROCEDURE PR_EXMM_COMPAREPAPER(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,r_Ret out Number);
  --------------------------------时间单元初始化
  ---------------------------总部时间单元初始化及增量初始化 i_OperateType 1初始化 2 增量初始化
  PROCEDURE PR_EXMM_DEALSESSIONUNIT1(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) ;
   
  
  ---------------------------分部时间单元初始化及增量初始化 i_OperateType 1初始化 2 增量初始化
  PROCEDURE PR_EXMM_DEALSESSIONUNIT2(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) ;
  
  -------------------删除编排信息
  PROCEDURE PR_EXMM_CLEARSESSIONUNIT(i_MAINTAINER IN varchar2,I_EXAMPLANSN NUMBER,I_EXAMCATEGORYCODE VARCHAR2,I_SEGMENTCODE VARCHAR2 ,RETCODE OUT varchar2);
  
 --继承时间单元
  PROCEDURE PR_EXMM_INHERITSESSIONUNIT(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSNSOURCE IN number,i_EXAMCATEGORYTCODESOURCE IN varchar2,i_EXAMPLANSNTARGET IN number,i_EXAMCATEGORYTCODETARGET IN varchar2,RETCODE OUT varchar2);
  
  /* 函数定义   */
  ------返回指定分部中属于总部的计划开考科目光标方式
  Function FN_Exmm_Get010Paper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
  
  ------返回指定分部中属于总部的计划开考科目 for loop 方式
  Function FN_Exmm_Get010Paper2(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
  
  procedure PR_GetPlan(i_PlanSN IN number,i_SegmentCode IN varchar2 ,objPlan out EXAMPLAN);
  
  ------返回指定分部中属于总部的计划开考科目 for loop 方式
  Function FN_Exmm_GetExecPaper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
------返回指定学习中心中属于所属分部的计划开考科目 for loop 方式
  Function FN_Exmm_GetExecSegmentPaper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
    
  --继承考试科目比例
   --成功返回OK，否则返回错误信息有：
     -- 1 异常：EXCEPTION 
     -- 2: a 源考试定义中，不存在考试科目成绩合成比例信息
     --3: b 没有或多于一个目标专业规则
     --4:e 批次已经下发,不能自动建立
     ---------------------------------- 操作人－－－－－－－－－ 分部或总部代码－－－－－－源计划顺序号－－－－－－－－   源考试类别顺序号－－－－－－－－－目标考试计划顺序号－－－－－－－目标考试类别顺序号 －－－－－－－返回值
  PROCEDURE PR_EXMM_INHERITXKSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2);
 
  
END PK_EXMM;
/

--
-- PK_TCP  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_TCP AS
/******************************************************************************
   NAME:       PK_TCP
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/03      libin       1. Created this package.
******************************************************************************/

 -- 指导性专业规则启用条件判断
  PROCEDURE PR_TCP_GUIDANCEENABLE(TCPCODE IN varchar2,RETCODE OUT varchar2);
  -- 指导性专业规则启用条件批量判断
  FUNCTION  FN_TCP_GUIDANCEENABLE(TCPCODELIST in varchar2) RETURN str_split PIPELINED;
  --实施性专业规则启用条件判断
  PROCEDURE PR_TCP_IMPLENABLE(ORGCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2);
  -- 实施性专业规则启用条件批量判断
  FUNCTION  FN_TCP_IMPLENABLE(ORGCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED;
  -- 执行性专业规则启用条件判断
   PROCEDURE PR_TCP_EXECENABLE(ORGCODE IN varchar2, LEARNINGCENTERCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2);
   -- 执行性专业规则启用条件批量判断
   FUNCTION  FN_TCP_EXECENABLE(ORGCODE IN varchar2,LEARNINGCENTERCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED;
   -- 启用一个单独的指导性专业规则
    PROCEDURE PR_TCP_ENABLEDGUIDANCE(TCPCODE in EAS_TCP_GUIDANCE.TCPCODE%type,ENABLEUSER in  EAS_TCP_GUIDANCE.EnableUser%type,RETCODE OUT varchar2);
    -- 批量启用指导性专业规则
    PROCEDURE PR_TCP_BATCHENABLEDGUIDANCE(TCPCODELIST in varchar2,ENABLEUSER in  EAS_TCP_GUIDANCE.EnableUser%type,RETCODE OUT varchar2);
    -- 单独删除指导性专业规则
    PROCEDURE PR_TCP_DELETEGUIDANCETCP(I_TCPCODE IN EAS_TCP_GUIDANCE.TCPCODE%TYPE,RETCODE OUT varchar2);
    --批量删除指导性专业规则
    PROCEDURE PR_TCP_BATCHDELETEGUIDANCETCP(TCPCODELIST in varchar2,RETCODE OUT varchar2);
   -- 启用一个单独的实施性专业规则
    PROCEDURE PR_TCP_ENABLEDIMPL(ORGCODE IN varchar2,TCPCODE in EAS_TCP_GUIDANCE.TCPCODE%type,IMPLEMENTERUSER in  EAS_TCP_IMPLEMENTATION.Implementer%type,RETCODE OUT varchar2);
     -- 批量启用实施性专业规则
    PROCEDURE PR_TCP_BATCHENABLEDIMPL(ORGCODE IN varchar2,TCPCODELIST in varchar2,IMPLEMENTERUSER in  EAS_TCP_IMPLEMENTATION.Implementer%type,RETCODE OUT varchar2);
    ---延用实施性专业规则
    PROCEDURE PR_TCP_PUTOFFIMPL(ORGCODE IN VARCHAR2,TCPCODE IN EAS_TCP_GUIDANCE.TCPCODE%TYPE ,RETCODE OUT varchar2);
     -- 批量-延用实施性专业规
    PROCEDURE PR_TCP_BATCHPUTOFFIMPL(ORGCODE IN varchar2,TCPCODELIST in varchar2,RETCODE OUT varchar2);
     -- 下发实施性专业规
    PROCEDURE PR_TCP_PUBLISHIMPL(iORGCODE IN varchar2,iBATCHCODE in varchar2,RETCODE OUT varchar2);
    -- 计算分部执行性专业规则初始化
    FUNCTION FN_TCP_GETEXECRULEONINIT(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN TYP_IMPLRULE ;
    
     -- 计算分部执行性专业规则模块规则初始化
    FUNCTION FN_TCP_GETEXECMODULERULEONINIT(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN COL_MODULERULE ;
   
    --执行性专业规则--启用 add liufengshuan (专业规则编码,操作人,学习中学编码,out 返回状态)
    PROCEDURE PR_TCP_ExecutionEnable( i_TCPCode in varchar2,i_OperatorName in varchar2,i_LearningCenterCode in varchar2,returnCode out varchar2);
    
    --执行性专业规则--批量启用 add liufengshuan (专业规则编码,操作人,学习中学编码,out 返回没有启用成功的tcpcode)
    PROCEDURE PR_TCP_BatchExecutionEnable( i_TCPCodeList in varchar2,i_OperatorName in varchar2,i_LearningCenterCode in varchar2,returnCode out varchar2);
    
    --根据年度学期,学生类型,专业层次,专业编码获取专业规则编码
    Function FN_TCP_GetNewTCPCode(i_batchcode varchar2,i_studentype varchar2,i_professionallevel varchar2,i_spycode varchar2) RETURN varchar2;
    
    --指导性专业规则管理--复制专业规则
    PROCEDURE Pr_TCP_CopyGuidanceTCP(i_BatchCode in EAS_TCP_GUIDANCE.BatchCode%type,i_MAINTAINER IN varchar2,RETCODE out varchar2); 
   
    ---执行性专业规则--延用课程
    PROCEDURE PR_TCP_ExecDeferCourse(i_TCPCode IN EAS_TCP_Execution.TCPCODE%TYPE ,i_LearningCenterCode in EAS_TCP_Execution.LearningCenterCode%TYPE,RETCODE OUT varchar2);
    
        ---执行性专业规则--批量延用课程
    PROCEDURE PR_TCP_BatchExecDeferCourse(i_TCPCodeList IN varchar2 ,i_LearningCenterCode in EAS_TCP_Execution.LearningCenterCode%TYPE,RETCODE OUT varchar2);


    --学习中心-学期开设课程管理-- 复制学期开设课程功能 add by liufengshuan
    PROCEDURE PR_TCP_CopyLCenterSemeCourse(i_LearingCenterCode in EAS_TCP_LearCentSemeCour.LearningCenterCode%Type,i_frombatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,i_targetBatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,returnCode out varchar2);
   
   --学习中心-学期开设课程管理-- 按学期开设课程功能 add by liufengshuan
    PROCEDURE PR_TCP_LCenterAddSemeCourse(i_LearingCenterCode in EAS_TCP_LearCentSemeCour.LearningCenterCode%Type,i_frombatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,returnCode out varchar2);
    
    --分部--:分部学期开设课程管理-- 复制学期开设课程 复制选中年度学期分部课程到指定的学期
    PROCEDURE Pr_TCP_CopySegmSemeOpenCourse(i_orgCode in varchar,i_frombatchcode in varchar,i_targetBatchcode in varchar,returnCode out varchar2);
    
    --分部---分部学期开设课程管理----按学期开设
    PROCEDURE Pr_TCP_AddSegmSemeCoursByTerm(i_orgCode in varchar,i_yearTerm in varchar,returnCode out varchar2);
    ---返回指定学习中心专业规则内课程
    FUNCTION FN_TCP_GETEXECMODULECOURSE(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iLEARNINGCENTERCODE in EAS_TCP_EXECUTION.LEARNINGCENTERCODE%type , iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN COL_EXECMODULECOURSE ;
  ----------返回分部实施性专业规则课程（指导性必修+实施性所有课程）
    Function FN_TCP_GetImplModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses;
    ----返回学习中心执行性专业规则课程（指导性必修+实施性必修+执行性）
     Function FN_TCP_GetExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2,i_LearnCode varchar2) return TcpModuleCourses;
     -----返回执行性专业规则模板课程
     Function FN_TCP_GetMExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses;
       -- 执行性专业规则模板启用条件判断
   PROCEDURE PR_TCP_MEXECENABLE(ORGCODE IN varchar2, TCPCODE IN varchar2,RETCODE OUT varchar2 );
         
  -- 执行性专业规则模板启用条件批量判断
   FUNCTION  FN_TCP_MEXECENABLE(ORGCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED;
   ----建立执行性模板
   PROCEDURE PR_TCP_ADDMEXECE(ORGCODE IN varchar2, TCPCODE IN varchar2,RETCODE OUT varchar2 );
  
   ----下发执行性模板
   PROCEDURE PR_TCP_PUBMEXECE(i_Maintainer IN varchar2,i_ORGCODE IN varchar2, i_TCPCODE IN varchar2,RETCODE OUT varchar2 );
   
   --继承执行性模板单独执行
  PROCEDURE PR_TCP_INHERITMEXECE_1(i_SourceSN IN NUMBER,i_ORGCODE IN varchar2, i_TCPCODE IN varchar2,RETCODE OUT varchar2);
  
   --继承执行性模板              源批次                          目标批次                       分部代码               层次                     专业                 返回值 ，成功返回OK 
   --错误信息有三类：1 异常：EXCEPTION 2 a:没有或多于一个源执行专业规则模块  3 b 没有或多于一个目标专业规则                  
  PROCEDURE PR_TCP_INHERITMEXECE(i_SourceBatchCode IN varchar2,i_TargetBatchCode IN varchar2,i_ORGCODE IN varchar2, i_Profession IN varchar2, i_SpyCode IN varchar2,RETCODE OUT varchar2);
  
 
END PK_TCP;
/

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

--
-- PR_TCP_COPY_COPYGUIDANCETCP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Copy_CopyGuidanceTCP
(
     i_BatchCode in EAS_TCP_GUIDANCE.BatchCode%type,--年度学期
     returnCode out varchar2
)
 IS

v_prevBatchCode EAS_TCP_RECRUITBATCH.BATCHCODE%type;--目标学期的上一年度学期

/******************************************************************************
   NAME:       Pr_GuidanceCopyTCP
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/17   Administrator       1. Created this procedure.

   NOTES:指导性专业规则管理--复制专业规则
   
******************************************************************************/
BEGIN

--1.目标学期的上一年度学期
    select BatchCode into v_prevBatchCode from EAS_TCP_RECRUITBATCH Batch
    where Batch.BATCHCODE<i_BatchCode  and rownum<2
    order by Batch.BATCHCODE desc;
    
    dbms_output.put_line(i_BatchCode||'查出结果为:年度学期=' ||i_BatchCode );

   if v_prevBatchCode is not null and length(v_prevBatchCode)>0 then
   
     returnCode:='1';
     
     ---2. 复制 EAS_TCP_Guidance
        insert into EAS_TCP_Guidance
        (
               TCPCode,BatchCode,TCPName,EducationType,StudentType,ProfessionalLevel
              ,SpyCode,MinGradCredits,MinExamCredits,ExemptionMaxCredits,SchoolSystem
              ,DegreeCollegeID,DegreeSemester,Remark,State,CopySourceCode,Creator,CreateTime
              --,EnableUser,EnableTime
        )
        select    
            fn_GetTCPCode(i_BatchCode, g.studenttype, g.professionallevel,g.spycode) tcpcodenew,
            i_BatchCode BatchCode,
            --g.BatchCode,
            (select RECRUITBATCHName from EAS_TCP_RECRUITBATCH where batchcode=i_BatchCode)||
            (select dicname  from EAS_Dic_StudentType where diccode=g.studenttype )||
            (select dicname from EAS_Dic_ProfessionalLevel where diccode=g.professionallevel)||
            (select spyname from EAS_Spy_BasicInfo where spycode=g.spycode) tcpnamenew
            --,g.TCPCode
            --,g.TCPName
            ,g.EducationType,g.StudentType,g.ProfessionalLevel,g.SpyCode
            ,g.MinGradCredits,g.MinExamCredits,g.ExemptionMaxCredits,g.SchoolSystem
            ,g.DegreeCollegeID,g.DegreeSemester,g.Remark
            ,0 State
            ,v_prevBatchCode CopySourceCode
            ,g.Creator
            ,sysdate CreateTime
            --,g.EnableUser
            --,g.EnableTime 
        from EAS_TCP_Guidance  g
                --目标学期的上一个学期
        where g.batchcode=v_prevBatchCode
        and not exists(
            select 1 from EAS_TCP_Guidance where batchcode=i_BatchCode 
            and studenttype=g.studenttype and professionallevel=g.professionallevel 
            and spycode=g.spycode
        );
        
          dbms_output.put_line('EAS_TCP_Guidance' ||  SQL%ROWCOUNT);
   
        
    --3.复制EAS_TCP_GuidanceOnRule
        insert into EAS_TCP_GuidanceOnRule
         ( SN,BatchCode,TCPCode,TotalCredits,ModuleTotalCredits,RequiredTotalCredits)
        select
            seq_TCP_GuidOnRule.nextval SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew, 
            --etgr.TCPCode,
            etgr.TotalCredits,
            etgr.ModuleTotalCredits,
            etgr.RequiredTotalCredits
         from EAS_TCP_GuidanceOnRule etgr
         inner join EAS_TCP_Guidance etg on etgr.tcpcode=etg.tcpcode
                --目标学期的上一个学期
        where etgr.Batchcode=v_prevBatchCode
            and not exists(
                select 1 from EAS_TCP_GuidanceOnRule where batchcode=i_BatchCode    and tcpcode=etg.tcpcode
            );
            
                dbms_output.put_line('EAS_TCP_GuidanceOnRule' ||  SQL%ROWCOUNT);
            
    ---4. 复制EAS_TCP_Module
        insert into EAS_TCP_Module
         ( SN,BatchCode,TCPCode,ModuleCode,MinGradCredits,MinExamCredits,CreateTime )
        select
            sys_guid() SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew, 
            --etm.tcpcode,
            etm.ModuleCode,
            etm.MinGradCredits,
            etm.MinExamCredits,
            sysdate CreateTime
            
         from EAS_TCP_Module etm
        left join EAS_TCP_Guidance etg on etm.tcpcode=etg.tcpcode
                --目标学期的上一个学期
        where etm.Batchcode=v_prevBatchCode
        and not exists(
            select 1 from EAS_TCP_Module where batchcode=i_BatchCode and tcpcode=etg.tcpcode
        );
        
            dbms_output.put_line('EAS_TCP_Module' ||  SQL%ROWCOUNT);

    --5. EAS_TCP_ModuleCourses
        insert into EAS_TCP_ModuleCourses
         ( SN,ModuleCode,BatchCode,TCPCode,CourseID,CourseName,CourseNature,Credit,OrgCode,OpenedSemester,ExamUnitType,IsExtendedCourse,IsDegreeCourse,IsSimilar,CreateTime )
        select
            sys_guid() SN,
            etmc.ModuleCode,
            --目标学期
            i_BatchCode BatchCode,
            --etmc.BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
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
        left join EAS_TCP_Guidance etg on etmc.tcpcode=etg.tcpcode
        --目标学期的上一个学期
        where etmc.Batchcode=v_prevBatchCode
        and not exists(
            select 1 from EAS_TCP_ModuleCourses where batchcode=i_BatchCode and tcpcode=etg.tcpcode
        );
        
            dbms_output.put_line('EAS_TCP_ModuleCourses' ||  SQL%ROWCOUNT);
        
        
      --6. 复制 EAS_TCP_GuidanceOnModuleRule
        insert into EAS_TCP_GuidanceOnModuleRule
         ( OnRuleID,BatchCode,TCPCode,ModuleCode,TotalCredits,RequiredTotalCredits,CenterCompulsoryCourseCredit,SegmentCompulsoryCourseCredit )
        select
           seq_TCP_GuidModuRule.nextval OnRuleID,
            --目标学期
            i_BatchCode BatchCode,
           fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etgm.ModuleCode,
            etgm.TotalCredits,
            etgm.RequiredTotalCredits,
            etgm.CenterCompulsoryCourseCredit,
            etgm.SegmentCompulsoryCourseCredit
            
         from EAS_TCP_GuidanceOnModuleRule etgm
        left join EAS_TCP_Guidance etg on etgm.tcpcode=etg.tcpcode
                --目标学期的上一个学期
        where etgm.Batchcode=v_prevBatchCode   
        and not exists(
            select 1 from EAS_TCP_GuidanceOnModuleRule where batchcode=i_BatchCode and tcpcode=etg.tcpcode
        );
        
            dbms_output.put_line('EAS_TCP_GuidanceOnModuleRule' ||  SQL%ROWCOUNT);


    --7.相似课 EAS_TCP_SimilarCourses
        insert into EAS_TCP_SimilarCourses
         ( SN,BatchCode,TCPCode,ModuleCode,CourseID,SimilarGroup,CreateTime )
        select
            seq_TCP_SimilarCourses.nextval SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etsc.ModuleCode,
            etsc.CourseID,
            etsc.SimilarGroup,
            sysdate CreateTime
            
         from EAS_TCP_SimilarCourses etsc
        left join EAS_TCP_Guidance etg on etsc.tcpcode=etg.tcpcode
        --目标学期的上一个学期
        where etsc.Batchcode=v_prevBatchCode    
        and not exists(
                select 1 from EAS_TCP_SimilarCourses where batchcode=i_BatchCode and tcpcode=etg.tcpcode
            );
            
        dbms_output.put_line('EAS_TCP_SimilarCourses' ||  SQL%ROWCOUNT);   
    
     --8.补修课   
       insert into EAS_TCP_ConversionCourse
         ( SN,BatchCode,TCPCode,CourseID,SuggestOpenSemester,ExamunitType,CreateTime )
        select
            sys_guid() SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etcc.CourseID,
            etcc.SuggestOpenSemester,
            etcc.ExamunitType,
            sysdate CreateTime
         from EAS_TCP_ConversionCourse etcc
        left join EAS_TCP_Guidance etg on etcc.tcpcode=etg.tcpcode
        --目标学期的上一个学期
        where etcc.Batchcode=v_prevBatchCode    
        and not exists(
                select 1 from EAS_TCP_ConversionCourse where batchcode=i_BatchCode and tcpcode=etg.tcpcode
            );
    
    dbms_output.put_line('EAS_TCP_ConversionCourse' ||  SQL%ROWCOUNT);
    
    
    
    
    end if;
    
  EXCEPTION

     WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     returnCode:='0';
        rollback;

END Pr_TCP_Copy_CopyGuidanceTCP;
/