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

