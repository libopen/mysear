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
/* ������   */
  --------------------------ʱ�䵥Ԫ����------
   TYPE SessionUnit_Array IS varray(8) of varchar2(80); --�洢ʱ�䵥Ԫ
 
   -------------------------������������--------
   TYPE ExamDate_array IS TABLE OF date INDEX BY BINARY_INTEGER; --�洢���������Զ���������
  
  ----  �����Ծ��б� �Զ���������
    TYPE t_PaperArray is table of varchar2(30) index by binary_integer; 
  
  
 
/*      �洢���̶��� */
  -- �Զ�������׷�Ӽƻ������γ�
  PROCEDURE PR_EXMM_BATCHADDEXAMCOURSEPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_OperateType IN number,RETCODE OUT varchar2) ;
  
  --�̳п����γ�
  PROCEDURE PR_EXMM_INHERITEXAMCOURSEPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2);
  
  
  -- �Զ�������׷�Ӽƻ�������Ŀ
  PROCEDURE PR_EXMM_BATCHADDSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN IN number,i_EXAMCATEGORYTSN IN number,i_EXAMTIMELENGTH IN number ,i_OperateType IN number,RETCODE OUT varchar2) ;

 --�̳мƻ�������Ŀ
  PROCEDURE PR_EXMM_INHERITSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2);
    
 -- i_planSN ���Զ���SN  i_SegmentCode �ֲ�����  i_tbFrom ��1����2�·���ȡ���� arrRet ���ض�Ӧ�Ŀ��Կ�ʼʱ������
  PROCEDURE PR_EXMM_GETSESSIONUNIT(i_PlanSN number,i_CategoryCode varchar2, i_SegmentCode varchar2,i_tbFrom number,arrRet OUT SessionUnit_Array);
  ------���ؿ������� i_Operate 1 ֻʹ����ʱ��� 2 ʹ����չʱ���
  PROCEDURE PR_EXMM_GETEXAMDATELIST(i_NewBeginDate date,i_NewEndDate date,i_ExistBeginDate date,i_ExistEndDate date,i_Operate number,ExamDatelist out ExamDate_array);
  
      --���ؿ��Լƻ�����
  PROCEDURE PR_EXMM_GETEXAMPLANOBJ(i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,r_ExamPlan OUT EXAMPLAN);
  ----������Ӧ�Ŀ���ʱ�����
   PROCEDURE PR_EXMM_GETEXAMTIMEOBJ(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,i_OperateType number,r_EXAMTIME out EXAMTIME);
   
   ----�жϼƻ������γ��Ծ�����ƻ�������Ŀ�Ծ����Ƿ�һ��
   PROCEDURE PR_EXMM_COMPAREPAPER(i_ExamPlanCode varchar2,i_ExamCategoryCode varchar2,i_PlanUseOrgCode varchar2,r_Ret out Number);
  --------------------------------ʱ�䵥Ԫ��ʼ��
  ---------------------------�ܲ�ʱ�䵥Ԫ��ʼ����������ʼ�� i_OperateType 1��ʼ�� 2 ������ʼ��
  PROCEDURE PR_EXMM_DEALSESSIONUNIT1(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) ;
   
  
  ---------------------------�ֲ�ʱ�䵥Ԫ��ʼ����������ʼ�� i_OperateType 1��ʼ�� 2 ������ʼ��
  PROCEDURE PR_EXMM_DEALSESSIONUNIT2(i_Maintainer IN varchar2,i_ExamPlanSN number,i_ExamCategorySN number,i_PlanUseOrgCode varchar2,i_OperateType number,RETCODE OUT varchar2) ;
  
  -------------------ɾ��������Ϣ
  PROCEDURE PR_EXMM_CLEARSESSIONUNIT(i_MAINTAINER IN varchar2,I_EXAMPLANSN NUMBER,I_EXAMCATEGORYCODE VARCHAR2,I_SEGMENTCODE VARCHAR2 ,RETCODE OUT varchar2);
  
 --�̳�ʱ�䵥Ԫ
  PROCEDURE PR_EXMM_INHERITSESSIONUNIT(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSNSOURCE IN number,i_EXAMCATEGORYTCODESOURCE IN varchar2,i_EXAMPLANSNTARGET IN number,i_EXAMCATEGORYTCODETARGET IN varchar2,RETCODE OUT varchar2);
  
  /* ��������   */
  ------����ָ���ֲ��������ܲ��ļƻ�������Ŀ��귽ʽ
  Function FN_Exmm_Get010Paper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
  
  ------����ָ���ֲ��������ܲ��ļƻ�������Ŀ for loop ��ʽ
  Function FN_Exmm_Get010Paper2(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
  
  procedure PR_GetPlan(i_PlanSN IN number,i_SegmentCode IN varchar2 ,objPlan out EXAMPLAN);
  
  ------����ָ���ֲ��������ܲ��ļƻ�������Ŀ for loop ��ʽ
  Function FN_Exmm_GetExecPaper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
------����ָ��ѧϰ���������������ֲ��ļƻ�������Ŀ for loop ��ʽ
  Function FN_Exmm_GetExecSegmentPaper(i_ExamPlanCode varchar2,i_SegmentCode varchar2) return t_PaperList; 
    
  --�̳п��Կ�Ŀ����
   --�ɹ�����OK�����򷵻ش�����Ϣ�У�
     -- 1 �쳣��EXCEPTION 
     -- 2: a Դ���Զ����У������ڿ��Կ�Ŀ�ɼ��ϳɱ�����Ϣ
     --3: b û�л����һ��Ŀ��רҵ����
     --4:e �����Ѿ��·�,�����Զ�����
     ---------------------------------- �����ˣ����������������� �ֲ����ܲ����룭����������Դ�ƻ�˳��ţ���������������   Դ�������˳��ţ�����������������Ŀ�꿼�Լƻ�˳��ţ�������������Ŀ�꿼�����˳��� ������������������ֵ
  PROCEDURE PR_EXMM_INHERITXKSUBJECTPLAN(i_Maintainer IN varchar2,i_SEGMENTCODE IN varchar2,i_EXAMPLANSN_SOURCE IN number,i_EXAMCATEGORYSN_SOURCE IN number,i_EXAMPLANSN_TARGET IN number,i_EXAMCATEGORYSN_TARGET IN number,RETCODE OUT varchar2);
 
  
END PK_EXMM;
/

