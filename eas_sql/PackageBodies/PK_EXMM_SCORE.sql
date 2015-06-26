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

