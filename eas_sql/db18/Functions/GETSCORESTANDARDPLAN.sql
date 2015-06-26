--
-- GETSCORESTANDARDPLAN  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.GetScoreStandardPlan
(
  InExamPlanCode varchar2,
  InExamCategoryCode varchar2,
  InExamPaperCode varchar2,
  InSegmentCode varchar2,
  InCollegeCode varchar2,
  InLearningCenterCode varchar2
) RETURN Number
IS
x_SN Number;
x_Count number;
BEGIN
      x_SN :=0;
      select count(1) into x_Count from EAS_ExmM_XKStandardPlan@ouchnbase where examPlanCode = InExamPlanCode and examCategoryCode = InExamCategoryCode and examPaperCode = InExamPaperCode
      and learningCenterCode = InLearningCenterCode;
      
      if x_Count =0 then
        select count(1) into x_Count from EAS_ExmM_XKStandardPlan@ouchnbase where examPlanCode = InExamPlanCode and examCategoryCode = InExamCategoryCode and examPaperCode = InExamPaperCode
        and collegeCode = InCollegeCode;
        if x_Count =0 then
            select count(1) into x_Count from EAS_ExmM_XKStandardPlan@ouchnbase where examPlanCode = InExamPlanCode and examCategoryCode = InExamCategoryCode and examPaperCode = InExamPaperCode
            and segmentCode  = InSegmentCode;
            if x_Count = 0 then
               return null;
            else
                select SN into x_SN from EAS_ExmM_XKStandardPlan@ouchnbase where examPlanCode = InExamPlanCode and examCategoryCode = InExamCategoryCode and examPaperCode = InExamPaperCode
                and segmentCode  = InSegmentCode;
                return x_SN;
            end if;
        else
         select SN into x_SN from EAS_ExmM_XKStandardPlan@ouchnbase where examPlanCode = InExamPlanCode and examCategoryCode = InExamCategoryCode and examPaperCode = InExamPaperCode
         and collegeCode = InCollegeCode;
         return x_SN;
        end if;
      else
        select SN into x_SN from EAS_ExmM_XKStandardPlan@ouchnbase where examPlanCode = InExamPlanCode and examCategoryCode = InExamCategoryCode and examPaperCode = InExamPaperCode
        and learningCenterCode = InLearningCenterCode;
        return x_SN;
      end if;
      if x_SN =0 then
        return null;
      end if;
      return x_SN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       return null;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       return null;
END GetScoreStandardPlan;
/

