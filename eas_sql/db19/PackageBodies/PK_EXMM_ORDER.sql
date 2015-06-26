--
-- PK_EXMM_ORDER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_EXMM_Order AS
    PROCEDURE Pro_Exam_CreateOrders
    (
    inExamPlanCode varchar2,
    inCreateOrgCode varchar2,
    inExamCategoryCode varchar2,
    inOrgCode varchar2,
    inOrgType int,
    inCollegeCode varchar2,
    inTopOrgCode varchar2,
    inExamSiteCodes varchar2,
    inExamUnitType varchar2,
    inMaintainer varchar2,
    outCount out int
    )IS
    strSql varchar2(1000);
    strSql2 varchar2(2000);
    tsn int;--序列号
    oldCount int;
    
    x_D31 int;
    x_D26 int;
    x_D11 int;
    x_D5 int;
    x_NumOfExaminee int;
    x_A10 int;
    x_A5 int;
    x_ExamPaperCode varchar2(50);
    x_ExamSiteCode varchar2(50);
    x_ExamCategoryCode varchar2(50);
    x_ExamUnitType int;
    x_Count int;
    x_CollegeCode varchar2(50);
    x_SegmentCode varchar2(50);
    x_ExamSiteCodes varchar2(32767);
    x_i int;
    x_IsReport int;--是否上报,当考试单位为1时，自动设置为1
    
    TYPE examOrderRec IS REF CURSOR;--定义用户类型
    c_row examOrderRec; --定义游标变量
    cursor cSiteCodes
           is
            select  column_value as siteID from table(splitToArray(inExamSiteCodes,','));
           cSiteCode cSiteCodes%rowtype;
    BEGIN
        outCount:=0;
        x_i := 0;
        x_IsReport := 0;
        
        for cSiteCode in cSiteCodes loop
        oldCount :=0;
        --查询是否编排过了
        strSql:='select count(1) from Eas_ExmM_Order where examPlanCode = ''' || inExamPlanCode ||'''';
         if inExamCategoryCode is not null then
             strSql := strSql || ' and examCategoryCode ='''||InExamCategoryCode||'''';
         end if;
         if inExamSiteCodes is not null then
             strSql := strSql || ' and examSiteCode ='''||cSiteCode.siteID||'''';
         end if;
         if inExamUnitType is not null and inExamUnitType != 0 then
              strSql := strSql ||'
              and examUnit = '''||inExamUnitType || '''';
         end if;
         execute immediate  strSql into oldCount;
         if oldCount = 0 then
           if x_i > 0 then
            x_ExamSiteCodes := x_ExamSiteCodes ||',';
           end if;
           x_ExamSiteCodes := x_ExamSiteCodes || cSiteCode.siteID;
           x_i := x_i+1;
         end if;
         
         end loop;
         if x_ExamSiteCodes is null or length(x_ExamSiteCodes) < 1 then
             outCount:=-10;
             return;
         end if;
    --声明一个查询出总和数据的游标-试卷
       strSql2 :='
        select * from(
              with dresult as
              (select paperStandard.D31,paperStandard.D26,paperStandard.D11,paperStandard.D5,
              case when result.numOfRoom >=10 then 1 else 0 end A10,
              case when result.numOfRoom <10 then 1 else 0 end A5,
              result.examSiteCode,
              result.examPaperCode,result.numOfRoom,result.examCategoryCode,
              result.examUnitType
              from EAS_ExmM_ArrangeResult result
              inner join EAS_ExmM_PaperStandard paperStandard
              on result.numOfRoom = paperStandard.Num 
              where result.examPlanCode = '''||inExamPlanCode ||'''';
              if x_ExamSiteCodes is not null then
              strSql2 := strSql2 ||'and result.examSiteCode in (select * from table(splitToArray('''||x_ExamSiteCodes||''','','')))';
              end if;
              if inExamCategoryCode is not null then
              strSql2 := strSql2 || '
              and result.examcategoryCode = '''||inExamcategoryCode ||'''';
              end if;
              if inExamUnitType is not null  and inExamUnitType != 0 then
              strSql2 := strSql2 ||'
              and result.examUnitType = '''||inExamUnitType||'''';
              end if;
              strSql2 := strSql2 || '
              ),
              sumResult as (
                  select sum(D31) as D31,sum(D26) as D26,sum(D11) as D11,sum(D5) as D5,sum(numOfRoom) as numOfExaminee,
                  sum(A10) as A10,sum(A5) as A5,
                  examPaperCode,examSiteCode,examCategoryCode,examUnitType
                  from dresult group by examPaperCode,examSiteCode,examCategoryCode,examUnitType
                  )
              select D31,D26,D11,D5,numOfExaminee,A10,A5,examPaperCode,examSiteCode,examCategoryCode,examUnitType from sumResult
              )';
         DBMS_OUTPUT.PUT_LINE(strSql2);
      --填写试卷订单信息
      --执行，使用游标
        open c_row for strSql2;--打开游标
        loop
        FETCH c_row into x_D31,x_D26,x_D11,x_D5,x_NumOfExaminee,x_A10,x_A5,x_ExamPaperCode,x_ExamSiteCode,x_ExamCategoryCode,x_ExamUnitType;
        EXIT WHEN c_row%NOTFOUND OR c_row%NOTFOUND IS NULL;
        --查询学院编码
        if inOrgType =2 then
            select CollageCode into x_CollegeCode from EAS_ExmM_ExamSite@ouchnbase where ExamSiteCode = x_ExamSiteCode and rownum=1;
            x_SegmentCode := inOrgCode;
        elsif inOrgType = 3 then
            x_CollegeCode := inOrgCode;
            select ParentCode into x_SegmentCode from EAS_Org_BasicInfo@ouchnbase  where OrganizationCode = x_CollegeCode and rownum =1;
        end if;
        tsn := seq_ExmM_Order.nextVal;
         --总表
         if x_ExamUnitType = 1 then
            x_IsReport := 1;
         else
            x_IsReport := 0;
         end if;
         
         insert into EAS_ExmM_Order(SN,ExamPlanCode,CreateOrgCode,ExamCategoryCode,ExamSiteCode,ExamPaperCode,NumOfExaminee,OrgCode,OrgType,isReport,TopOrgCode,MaintainDate,Maintainer,ExamUnit,OrderType)
         values(tsn,inExamPlanCode,inCreateOrgCode,x_examCategoryCode,x_examSiteCode,x_ExamPaperCode,x_NumOfExaminee,x_CollegeCode,3,x_IsReport,x_SegmentCode,sysdate,inMaintainer,x_examUnitType,1);
         
         --试卷订单
         if x_D31 >0  and x_D31 is not null then
         insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment) values(tsn,'e1',x_D31,0);
         end if;
         if x_D26>0 and x_D26 is not null then 
         insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment) values(tsn,'e2',x_D26,0);
         end if;
         if x_D11>0  and x_D11 is not null then
         insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment) values(tsn,'e3',x_D11,0);
         end if;
         if x_D5 >0  and x_D5 is not null then
         insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment) values(tsn,'e4',x_D5,0);
         end if;
        --答案订单
         if x_A10 >0  and x_A10 is not null then
            insert into EAS_ExmM_AnswerOrder(SN,AnswerNormCode,TotalOrders,Adjustment) values(tsn,'a1',x_A10,0);
         end if;
         if x_A5>0 and x_A5 is not null then
            insert into EAS_ExmM_AnswerOrder(SN,AnswerNormCode,TotalOrders,Adjustment) values(tsn,'a2',x_A5,0);
         end if;
         outCount:=outCount + 1;
       end loop;
       
       close c_row;
       
       if inOrgType = 3 then
       
       
       declare
           cursor c_paper_1
           is
           select sum(numOfexaminee) numOfexaminee2,examPaperCode,examCategoryCode,examUnit from eas_exmm_order  where examPlanCode=inExamPlanCode and examCategoryCode=inExamCategoryCode and orgType='3' and orgCode = inOrgCode and examSiteCode is not null group by exampapercode,examPaperCode,examCategoryCode,ExamUnit; 
           c_paperRow_1 c_paper_1%rowtype;
       begin
           for c_paperRow_1 in c_paper_1 loop
            --层级3数据
               select count(1) into x_Count from EAS_ExmM_Order where ExamSiteCode is null and ExamPlanCode = inExamPlanCode and ExamCategoryCode=c_paperRow_1.examCategoryCode and ExamPaperCode=c_paperRow_1.examPaperCode and orgType='3' and topOrgCode = inOrgCode;
               if x_Count=0 then
                tsn := seq_ExmM_Order.nextVal;
                if c_paperRow_1.examUnit = '1' then
                    x_IsReport :=1;
                else
                    x_IsReport := 0;
                end if;
                
                insert into EAS_ExmM_Order(SN,ExamPlanCode,CreateOrgCode,ExamCategoryCode,ExamSiteCode,ExamPaperCode,NumOfExaminee,OrgCode,OrgType,isReport,TopOrgCode,MaintainDate,Maintainer,ExamUnit,OrderType)
                    values(tsn,inExamPlanCode,inCreateOrgCode,c_paperRow_1.examCategoryCode,null,c_paperRow_1.examPaperCode,c_paperRow_1.numOfexaminee2,inOrgCode,3,x_IsReport,inTopOrgCode,sysdate,inMaintainer,c_paperRow_1.examUnit,1);
                   --试卷和答案详细数据
                  declare
                   cursor c_job_1
                   is
                   select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and examsiteCode is not null and orgType = 3 and examPaperCode = c_paperRow_1.examPaperCode) group by paperstandardcode; 
                   c_row_1 c_job_1%rowtype;
                   --答案
                   cursor c_ans_1
                   is
                   select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and examsiteCode is not null and orgType = 3 and examPaperCode = c_paperRow_1.examPaperCode) group by answerNormCode; 
                   c_anRow_1 c_ans_1%rowtype;
                   begin
                      
                       for c_row_1 in c_job_1 loop
                         if c_row_1.paperStandardCode = 'e1' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_1.orderCount,0);
                         elsif c_row_1.paperStandardCode = 'e2' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_1.orderCount,0);
                         elsif  c_row_1.paperStandardCode = 'e3' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_1.orderCount,0);
                         elsif  c_row_1.paperStandardCode = 'e4' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_1.orderCount,0);
                         end if;
                       end loop;
                       
                       for c_anRow_1 in c_ans_1 loop
                         if c_anRow_1.answerNormCode = 'a1' then
                            insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_1.answerCount,0);
                         elsif c_anRow_1.answerNormCode = 'a2' then
                            insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_1.answerCount,0);
                         end if;
                       end loop;
                   end;
              else 
                   update EAS_ExmM_Order set NumOfExaminee = c_paperRow_1.numOfexaminee2 where OrgCode = inOrgCode and examPaperCode = c_paperRow_1.examPaperCode and ExamPlanCode=inExamPlanCode and examSiteCode is null and OrgType =3;
                   select Sn into tsn from EAS_ExmM_Order where OrgCode = inOrgCode and examPaperCode = c_paperRow_1.examPaperCode and ExamPlanCode=inExamPlanCode and examCategoryCode =c_paperRow_1.examCategoryCode  and examSiteCode is null and OrgType =3;
                --试卷和答案详细数据
                   declare
                   cursor c_job_2
                   is
                   select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and examsiteCode is not null and orgType = 3 and examPaperCode = c_paperRow_1.examPaperCode) group by paperstandardcode; 
                   c_row_2 c_job_2%rowtype;
                   
                   --答案
                   cursor c_ans_2
                   is
                   select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and examsiteCode is not null and orgType = 3 and examPaperCode = c_paperRow_1.examPaperCode) group by answerNormCode; 
                   c_anRow_2 c_ans_2%rowtype;
                   
                   eaCount int;
                   begin
                       for c_row_2 in c_job_2 loop
                         if c_row_2.paperStandardCode = 'e1' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e1';
                            if eaCount > 0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e1';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_2.orderCount,0);
                            end if;
                         elsif c_row_2.paperStandardCode = 'e2' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e2';
                            if eaCount > 0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e2';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_2.orderCount,0);
                            end if;
                         elsif  c_row_2.paperStandardCode = 'e3' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e3';
                            if eaCount > 0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e3';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_2.orderCount,0);
                            end if;
                         elsif  c_row_2.paperStandardCode = 'e4' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e4';
                            if eaCount >0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e4';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_2.orderCount,0);
                            end if;
                         end if;
                       end loop;
                       
                       for c_anRow_2 in c_ans_2 loop
                         if c_anRow_2.answerNormCode = 'a1' then
                            select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a1';
                            if eaCount >0 then
                                update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a1';
                            else
                                insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_2.answerCount,0);
                            end if;
                         elsif c_anRow_2.answerNormCode = 'a2' then
                            select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a2';
                            if eaCount >0 then
                                update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a2';
                            else
                                insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_2.answerCount,0);
                            end if;
                         end if;
                       end loop;
                   end;
              end if;
           end loop;
       end;
       
       declare
           cursor c_job2
           is
           select sum(numOfexaminee) numOfexaminee2,examPaperCode,examCategoryCode,examUnit from eas_exmm_order  where examPlanCode=inExamPlanCode and examCategoryCode=inExamCategoryCode and orgType=3 and examSiteCode is null and orgCode = inOrgCode group by exampapercode,examPaperCode,examCategoryCode,ExamUnit; 
           c_row2 c_job2%rowtype;
       begin
           for c_row2 in c_job2 loop
           --层级2数据
              select count(1) into x_Count from EAS_ExmM_Order where ExamSiteCode is null and ExamPlanCode = inExamPlanCode and ExamCategoryCode=c_row2.examCategoryCode and ExamPaperCode=c_row2.examPaperCode and orgType='2' and topOrgCode = inTopOrgCode;
              if x_Count=0 then
                tsn := seq_ExmM_Order.nextVal;
                if c_row2.examUnit = '1' then
                    x_IsReport :=1;
                else
                    x_IsReport := 0;
                end if;
                
                insert into EAS_ExmM_Order(SN,ExamPlanCode,CreateOrgCode,ExamCategoryCode,ExamSiteCode,ExamPaperCode,NumOfExaminee,OrgCode,OrgType,isReport,TopOrgCode,MaintainDate,Maintainer,ExamUnit,OrderType)
                    values(tsn,inExamPlanCode,inCreateOrgCode,c_row2.examCategoryCode,null,c_row2.examPaperCode,c_row2.numOfexaminee2,inTopOrgCode,2,x_IsReport,'010',sysdate,inMaintainer,c_row2.examUnit,1);
                    
                   --试卷和答案详细数据
                   declare
                   cursor c_job_1
                   is
                   select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examsiteCode is null and orgType = 3 and examPaperCode = c_row2.examPaperCode) group by paperstandardcode; 
                   c_row_1 c_job_1%rowtype;
                   
                   --答案
                   cursor c_ans_1
                   is
                   select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examsiteCode is null and orgType = 3 and examPaperCode = c_row2.examPaperCode) group by answerNormCode; 
                   c_anRow_1 c_ans_1%rowtype;
                   begin
                       for c_row_1 in c_job_1 loop
                         if c_row_1.paperStandardCode = 'e1' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_1.orderCount,0);
                         elsif c_row_1.paperStandardCode = 'e2' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_1.orderCount,0);
                         elsif  c_row_1.paperStandardCode = 'e3' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_1.orderCount,0);
                         elsif  c_row_1.paperStandardCode = 'e4' then
                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_1.orderCount,0);
                         end if;
                       end loop;
                       
                       
                       for c_anRow_1 in c_ans_1 loop
                         if c_anRow_1.answerNormCode = 'a1' then
                            insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_1.answerCount,0);
                         elsif c_anRow_1.answerNormCode = 'a2' then
                            insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_1.answerCount,0);
                         end if;
                       end loop;
                   end;
              else 
                  select Sn into tsn from EAS_ExmM_Order where OrgCode = inTopOrgCode and examPaperCode = c_row2.examPaperCode and ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examSiteCode is null and OrgType =2;
                  update EAS_ExmM_Order set NumOfExaminee = c_row2.numOfexaminee2 where sn = tsn;
                --试卷和答案详细数据
                   declare
                   cursor c_job_2
                   is
                   select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode  and examsiteCode is not null and orgType = 3 and examPaperCode = c_row2.examPaperCode) group by paperstandardcode; 
                   c_row_2 c_job_2%rowtype;
                   
                   --答案
                   cursor c_ans_2
                   is
                   select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examsiteCode is null and orgType = 3 and examPaperCode = c_row2.examPaperCode) group by answerNormCode; 
                   c_anRow_2 c_ans_2%rowtype;
                   
                   eaCount int;
                   begin
                       for c_row_2 in c_job_2 loop
                         if c_row_2.paperStandardCode = 'e1' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e1';
                            if eaCount > 0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e1';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_2.orderCount,0);
                            end if;
                         elsif c_row_2.paperStandardCode = 'e2' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e2';
                            if eaCount > 0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e2';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_2.orderCount,0);
                            end if;
                         elsif  c_row_2.paperStandardCode = 'e3' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e3';
                            if eaCount > 0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e3';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_2.orderCount,0);
                            end if;
                         elsif  c_row_2.paperStandardCode = 'e4' then
                            select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e4';
                            if eaCount >0 then
                                update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e4';
                            else
                                insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_2.orderCount,0);
                            end if;
                         end if;
                       end loop;
                       
                       for c_anRow_2 in c_ans_2 loop
                         if c_anRow_2.answerNormCode = 'a1' then
                            select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a1';
                            if eaCount >0 then
                                update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a1';
                            else
                                insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_2.answerCount,0);
                            end if;
                         elsif c_anRow_2.answerNormCode = 'a2' then
                            select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a2';
                            if eaCount >0 then
                                update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a2';
                            else
                                insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_2.answerCount,0);
                            end if;
                         end if;
                       end loop;
                   end;
              end if;
           end loop;
       end;
       
       commit;
       
       elsif inOrgType = 2 then--如果当前单位为分部
       DBMS_OUTPUT.PUT_LINE('层级3数据');
       declare 
          cursor c_seg
           is
           select OrganizationCode from   EAS_Org_BasicInfo@ouchnbase where ParentCode = inOrgCode;
           c_college_Row c_seg%rowtype;
           begin 
             for c_college_Row in c_seg loop
                x_CollegeCode := c_college_Row.OrganizationCode;
                
                declare
                   cursor c_paper_1
                   is
                   select sum(numOfexaminee) numOfexaminee2,examPaperCode,examCategoryCode,examUnit from eas_exmm_order  where examPlanCode=inExamPlanCode and examCategoryCode=inExamCategoryCode and orgType='3' and examSiteCode is not null and orgCode=x_CollegeCode group by exampapercode,examPaperCode,examCategoryCode,ExamUnit; 
                   c_paperRow_1 c_paper_1%rowtype;
                   begin
                       for c_paperRow_1 in c_paper_1 loop
                        --层级3数据
                           select count(1) into x_Count from EAS_ExmM_Order where ExamSiteCode is null and ExamPlanCode = inExamPlanCode and ExamCategoryCode=c_paperRow_1.examCategoryCode and ExamPaperCode=c_paperRow_1.examPaperCode and orgType='3' and OrgCode=x_CollegeCode;
                           if x_Count=0 then
                            tsn := seq_ExmM_Order.nextVal;
                            if c_paperRow_1.examUnit = '1' then
                                x_IsReport :=1;
                            else
                                x_IsReport :=0;
                            end if;
                            insert into EAS_ExmM_Order(SN,ExamPlanCode,CreateOrgCode,ExamCategoryCode,ExamSiteCode,ExamPaperCode,NumOfExaminee,OrgCode,OrgType,isReport,TopOrgCode,MaintainDate,Maintainer,ExamUnit,OrderType)
                                values(tsn,inExamPlanCode,inCreateOrgCode,c_paperRow_1.examCategoryCode,null,c_paperRow_1.examPaperCode,c_paperRow_1.numOfexaminee2,x_CollegeCode,3,x_IsReport,inOrgCode,sysdate,inMaintainer,c_paperRow_1.examUnit,1);
                               --试卷和答案详细数据
                              declare
                               cursor c_job_1
                               is
                               select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and orgCode=x_CollegeCode and examsiteCode is not null and orgType = 3 and examPaperCode=c_paperRow_1.examPaperCode) group by paperstandardcode; 
                               c_row_1 c_job_1%rowtype;
                               --答案
                               cursor c_ans_1
                               is
                               select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and orgCode=x_CollegeCode and examsiteCode is not null and orgType = 3 and examPaperCode=c_paperRow_1.examPaperCode) group by answerNormCode; 
                               c_anRow_1 c_ans_1%rowtype;
                               begin
                                  
                                   for c_row_1 in c_job_1 loop
                                     if c_row_1.paperStandardCode = 'e1' then
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_1.orderCount,0);
                                     elsif c_row_1.paperStandardCode = 'e2' then
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_1.orderCount,0);
                                     elsif  c_row_1.paperStandardCode = 'e3' then
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_1.orderCount,0);
                                     elsif  c_row_1.paperStandardCode = 'e4' then
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_1.orderCount,0);
                                     end if;
                                   end loop;
                                   
                                   for c_anRow_1 in c_ans_1 loop
                                     if c_anRow_1.answerNormCode = 'a1' then
                                        insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_1.answerCount,0);
                                     elsif c_anRow_1.answerNormCode = 'a2' then
                                        insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_1.answerCount,0);
                                     end if;
                                   end loop;
                               end;
                          else 
                               
                               select Sn into tsn from EAS_ExmM_Order where OrgCode = x_CollegeCode and examPaperCode = c_paperRow_1.examPaperCode and ExamPlanCode=inExamPlanCode and examCategoryCode =c_paperRow_1.examCategoryCode  and examSiteCode is null and OrgType =3;
                               update EAS_ExmM_Order set NumOfExaminee = c_paperRow_1.numOfexaminee2 where sn =tsn;
                               
                               dbms_output.put_line('分部-层级3-更新');
                            --试卷和答案详细数据
                               declare
                               cursor c_job_2
                               is
                               select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and orgCode=x_CollegeCode and examsiteCode is not null and orgType = 3   and examPaperCode = c_paperRow_1.examPaperCode) group by paperstandardcode; 
                               c_row_2 c_job_2%rowtype;
                               
                               --答案
                               cursor c_ans_2
                               is
                               select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_paperRow_1.examCategoryCode and orgCode=x_CollegeCode and examsiteCode is not null and orgType = 3  and examPaperCode=c_paperRow_1.examPaperCode) group by answerNormCode; 
                               c_anRow_2 c_ans_2%rowtype;
                               
                               eaCount int;
                               begin
                                   for c_row_2 in c_job_2 loop
                                     if c_row_2.paperStandardCode = 'e1' then
                                        select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e1';
                                        if eaCount > 0 then
                                            update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e1';
                                        else
                                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_2.orderCount,0);
                                        end if;
                                     elsif c_row_2.paperStandardCode = 'e2' then
                                        select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e2';
                                        if eaCount > 0 then
                                            update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e2';
                                        else
                                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_2.orderCount,0);
                                        end if;
                                     elsif  c_row_2.paperStandardCode = 'e3' then
                                        select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e3';
                                        if eaCount > 0 then
                                            update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e3';
                                        else
                                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_2.orderCount,0);
                                        end if;
                                     elsif  c_row_2.paperStandardCode = 'e4' then
                                        select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e4';
                                        if eaCount >0 then
                                            update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e4';
                                        else
                                            insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_2.orderCount,0);
                                        end if;
                                     end if;
                                   end loop;
                                   
                                   for c_anRow_2 in c_ans_2 loop
                                     if c_anRow_2.answerNormCode = 'a1' then
                                        select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a1';
                                        if eaCount >0 then
                                            update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a1';
                                        else
                                            insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_2.answerCount,0);
                                        end if;
                                     elsif c_anRow_2.answerNormCode = 'a2' then
                                        select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a2';
                                        if eaCount >0 then
                                            update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a2';
                                        else
                                            insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_2.answerCount,0);
                                        end if;
                                     end if;
                                   end loop;
                               end;
                          end if;
                       end loop;
                   end;   
                end loop;
                
                           
          
          DBMS_OUTPUT.PUT_LINE('层级二数据');
          declare
           cursor c_job2
           is
           select sum(numOfexaminee) numOfexaminee2,examPaperCode,examCategoryCode,examUnit from eas_exmm_order  where examPlanCode=inExamPlanCode and examCategoryCode=inExamCategoryCode and orgType=3 and TopOrgCode = inOrgCode  and examSiteCode is null group by exampapercode,examPaperCode,examCategoryCode,ExamUnit; 
           c_row2 c_job2%rowtype;
           begin
               for c_row2 in c_job2 loop
               --层级2数据
                  select count(1) into x_Count from EAS_ExmM_Order where ExamSiteCode is null and ExamPlanCode = inExamPlanCode and ExamCategoryCode=c_row2.examCategoryCode and ExamPaperCode=c_row2.examPaperCode and orgType='2' and orgCode= inOrgCode;
                  if x_Count=0 then
                    tsn := seq_ExmM_Order.nextVal;
                    
                    if c_row2.examUnit = '1' then
                        x_IsReport :=1;
                    else
                        x_IsReport := 0;
                    end if;
                    insert into EAS_ExmM_Order(SN,ExamPlanCode,CreateOrgCode,ExamCategoryCode,ExamSiteCode,ExamPaperCode,NumOfExaminee,OrgCode,OrgType,isReport,TopOrgCode,MaintainDate,Maintainer,ExamUnit,OrderType)
                        values(tsn,inExamPlanCode,inCreateOrgCode,c_row2.examCategoryCode,null,c_row2.examPaperCode,c_row2.numOfexaminee2,inOrgCode,2,x_IsReport,'010',sysdate,inMaintainer,c_row2.examUnit,1);
                        
                       --试卷和答案详细数据
                       declare
                       cursor c_job_1
                       is
                       select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode  and examsiteCode is null and orgType = 3 and examPaperCode=c_row2.examPaperCode) group by paperstandardcode; 
                       c_row_1 c_job_1%rowtype;
                       
                       --答案
                       cursor c_ans_1
                       is
                       select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examsiteCode is null and orgType = 3 and examPaperCode=c_row2.examPaperCode) group by answerNormCode; 
                       c_anRow_1 c_ans_1%rowtype;
                           begin
                               for c_row_1 in c_job_1 loop
                                 if c_row_1.paperStandardCode = 'e1' then
                                    insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_1.orderCount,0);
                                 elsif c_row_1.paperStandardCode = 'e2' then
                                    insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_1.orderCount,0);
                                 elsif  c_row_1.paperStandardCode = 'e3' then
                                    insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_1.orderCount,0);
                                 elsif  c_row_1.paperStandardCode = 'e4' then
                                    insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_1.orderCount,0);
                                 end if;
                               end loop;
                               
                               
                               for c_anRow_1 in c_ans_1 loop
                                 if c_anRow_1.answerNormCode = 'a1' then
                                    insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_1.answerCount,0);
                                 elsif c_anRow_1.answerNormCode = 'a2' then
                                    insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_1.answerCount,0);
                                 end if;
                               end loop;
                           end;
                      else 
                          
                          select Sn into tsn from EAS_ExmM_Order where OrgCode = inOrgCode and examPaperCode = c_row2.examPaperCode and ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examSiteCode is null and OrgType =2;
                          update EAS_ExmM_Order set NumOfExaminee = c_row2.numOfexaminee2 where Sn = tsn;
                        --试卷和答案详细数据
                           declare
                           cursor c_job_2
                           is
                           select paperStandardCode,sum(TotalOrders) orderCount from EAS_ExmM_PaperOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode  and examsiteCode is not null and orgType = 3 and examPaperCode=c_row2.examPaperCode) group by paperstandardcode; 
                           c_row_2 c_job_2%rowtype;
                           
                           --答案
                           cursor c_ans_2
                           is
                           select answerNormCode,sum(TotalOrders) answerCount from EAS_ExmM_AnswerOrder where sn in(select sn from EAS_ExmM_Order where ExamPlanCode=inExamPlanCode and examCategoryCode=c_row2.examCategoryCode and examsiteCode is null and orgType = 3 and examPaperCode=c_row2.examPaperCode) group by answerNormCode; 
                           c_anRow_2 c_ans_2%rowtype;
                           
                           eaCount int;
                           begin
                               for c_row_2 in c_job_2 loop
                                 if c_row_2.paperStandardCode = 'e1' then
                                    select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e1';
                                    if eaCount > 0 then
                                        update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e1';
                                    else
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e1',c_row_2.orderCount,0);
                                    end if;
                                 elsif c_row_2.paperStandardCode = 'e2' then
                                    select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e2';
                                    if eaCount > 0 then
                                        update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e2';
                                    else
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e2',c_row_2.orderCount,0);
                                    end if;
                                 elsif  c_row_2.paperStandardCode = 'e3' then
                                    select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e3';
                                    if eaCount > 0 then
                                        update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e3';
                                    else
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e3',c_row_2.orderCount,0);
                                    end if;
                                 elsif  c_row_2.paperStandardCode = 'e4' then
                                    select count(1) into eaCount from EAS_ExmM_PaperOrder where SN=tsn and paperStandardCode='e4';
                                    if eaCount >0 then
                                        update EAS_ExmM_PaperOrder set TotalOrders = c_row_2.orderCount where SN=tsn and paperStandardCode='e4';
                                    else
                                        insert into EAS_ExmM_PaperOrder(SN,PaperStandardCode,TotalOrders,Adjustment)values(tsn,'e4',c_row_2.orderCount,0);
                                    end if;
                                 end if;
                               end loop;
                               
                               for c_anRow_2 in c_ans_2 loop
                                 if c_anRow_2.answerNormCode = 'a1' then
                                    select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a1';
                                    if eaCount >0 then
                                        update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a1';
                                    else
                                        insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a1',c_anRow_2.answerCount,0);
                                    end if;
                                 elsif c_anRow_2.answerNormCode = 'a2' then
                                    select count(1) into eaCount from EAS_ExmM_AnswerOrder where SN=tsn and AnswerNormCode='a2';
                                    if eaCount >0 then
                                        update EAS_ExmM_AnswerOrder set TotalOrders = c_anRow_2.answerCount where SN=tsn and AnswerNormCode='a2';
                                    else
                                        insert into EAS_ExmM_AnswerOrder(SN,answerNormCode,TotalOrders,Adjustment)values(tsn,'a2',c_anRow_2.answerCount,0);
                                    end if;
                                 end if;
                               end loop;
                           end;
                          end if;
                       end loop;
                   end;
               
                
                
               commit;
           end;
       end if;
    end Pro_Exam_CreateOrders;
END PK_EXMM_Order;
/

