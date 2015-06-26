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

