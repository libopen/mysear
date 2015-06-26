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

