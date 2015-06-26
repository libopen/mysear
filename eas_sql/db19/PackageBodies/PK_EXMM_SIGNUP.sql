--
-- PK_EXMM_SIGNUP  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_ExmM_SignUp AS

--------------------------------------------����-------------------------------------
--����
PROCEDURE PR_EXMM_SIGNUP(
    InSignUpXml VARCHAR2,
    InExamBatchCode VARCHAR2,
    InExamPlanCode VARCHAR2 ,
    --InExamCategoryCode VARCHAR2,
    InSegmentCode  VARCHAR2 ,
    InLearningCenterCode   VARCHAR2 ,
    InApplicant     NVARCHAR2 ,
    InSignUpType    NUMBER ,
    OutTotalCount out int)
is 
--����xml����
xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
doc xmldom.DOMDocument;
--�ڵ�
pNodes xmldom.DOMNODELIST;
--��ʱ�ڵ�
tempNode XMLDOM.DOMNODE;
--�ӽڵ�
chilNodes xmldom.DOMNodeList;
--����
pCount        number;

--�������
x_AssessMode    VARCHAR2(10) ;
x_ExamSiteCode  VARCHAR2(10) ;
x_CourseID  VARCHAR2(10);
x_CourseName    VARCHAR2(80) ;
x_TCPCode   VARCHAR2(15) ;
x_ClassCode VARCHAR2(15);
x_StudentCode      VARCHAR2(20) ;
x_ExamUnit  NVARCHAR2(50);
x_RefID    number ;
x_ExamPaperCode VARCHAR2(10);
x_ExamPaperMemo VARCHAR2(200);
x_CollegeCode VARCHAR2(15);
x_ExamCategoryCode VARCHAR2(3);
x_ExamSessionUnit VARCHAR2(3) ;
isExists int;
BEGIN 
--�������
   XMLPARSER.PARSECLOB(xmlPar,InSignUpXml);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --�ͷ�
   XMLPARSER.FREEPARSER(xmlPar);
   --��ȡ�ڵ�
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
   --��ȡ����
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutTotalCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
     
    x_AssessMode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ExamSiteCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_CourseID := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_CourseName := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    x_TCPCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    x_ClassCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,6)));
    x_ExamUnit := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,7)));
    x_RefID := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,8)));
    x_ExamPaperCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,9)));
    x_ExamPaperMemo :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,10)));
    x_CollegeCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,11)));
    x_ExamCategoryCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,12)));
    x_ExamSessionUnit :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,13)));
    --
    select count(1) into isExists from EAS_EXMM_SIGNUP where examBatchCode = inExamBatchCode and examPlanCode = InExamPlanCode and examCategoryCode = x_ExamCategoryCode and studentCode = x_StudentCode and examPaperCode = x_ExamPaperCode and ELC_RefID =x_RefID ;
    if isExists = 0 then
        INSERT INTO EAS_EXMM_SIGNUP (SN,ExamBatchCode,ExamPlanCode,ExamCategoryCode,AssessMode,ExamSiteCode,ExamPaperCode,ExamSessionUnit,ExamPaperMemo,CourseID,CourseName,TCPCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,StudentCode,ExamUnit,ELC_RefID,Applicant,ApplicatDate,SignUpType,IsConfirm)
        VALUES(seq_ExmM_SignUp.nextval,InExamBatchCode,InExamPlanCode,x_ExamCategoryCode,x_AssessMode,x_ExamSiteCode,x_ExamPaperCode,x_ExamSessionUnit,x_ExamPaperMemo,x_CourseID,x_CourseName,x_TCPCode,InSegmentCode,x_CollegeCode,InLearningCenterCode,x_ClassCode,x_StudentCode,x_ExamUnit,x_RefID,InApplicant,SYSDATE,InSignUpType,0);
    end if; 
    COMMIT;
    OutTotalCount:=OutTotalCount+1;
   
   END LOOP;
       
   XMLDOM.FREEDOCUMENT(doc);
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_SIGNUP;

--ȷ�ϱ���-֧�������ͱ���תѡ�εı�����¼
PROCEDURE Pro_ConfirmSignUpToElc(
    InBatchCode varchar2,
    InStrWhere varchar2,
    InConfirmer varchar2,
    OutCount out int
) IS
strSql varchar2(1000);
strSignUpSql varchar2(1000);
strElcSql varchar2(1000);
--����
x_StudentCode varchar2(50);
x_CourseID varchar2(80);
x_LearningCenterCode varchar2(50);
x_ClassCode varchar2(50);
x_SpyCode varchar2(50);
x_StudentID varchar2(80);
x_refid number(10);
x_stuSN number(10);
x_signUpSN number(10);

TYPE signUpRec IS REF CURSOR;--�����û�����
sign_row signUpRec; --�����α����
BEGIN
   
   strSql:='UPDATE EAS_ExmM_SignUp SET Confirmer = '''||InConfirmer ||''',ConfirmDate=sysdate,IsConfirm=''1'' where 1=1 '||InStrWhere ||' and (IsConfirm=''0'' or IsConfirm is null)';
   execute immediate strSql;
   OutCount := SQL%ROWCOUNT;
   --���������ѡ�εĸ���
   strElcSql := 'UPDATE EAS_Elc_StudentStudyStatus status set SignUpNum = case when SignUpNum is null then 1 else SignUpNum +1 end where exists(select 1 from EAS_ExmM_SignUp signUp where status.StudentCode = StudentCode and status.CourseID = CourseID '||InStrWhere||')';
   execute immediate strElcSql;
   
   
   --��ȡ������ѡ����Ϣ�ı�����¼
   strSignUpSql:='select SN,studentCode,CourseID,LearningCenterCode,ClassCode from Eas_ExmM_SignUp signUp where  signUp.IsConfirm=''1'' '||InStrWhere ||' and SignUpType=5';
   --��ȡ������Ϣ
   open sign_row for strSignUpSql;
   loop
          FETCH sign_row into x_signUpSN,x_StudentCode,x_CourseID,x_LearningCenterCode,x_ClassCode;
          EXIT WHEN sign_row%NOTFOUND OR sign_row%NOTFOUND IS NULL;
          --��ȡѧ����רҵ��Ϣ��ѧ��id
          select SpyCode,StudentID into x_SpyCode,x_StudentID from EAS_SchRoll_Student@ouchnbase where studentCode=x_StudentCode;
          if x_SpyCode is not null and x_StudentID is not null then
          --д�뵽ѡ�α�
            x_refid := seq_Elc_StudentElc.nextval;
            insert into EAS_Elc_StudentElcInfo(SN,BatchCode,StudentCode,CourseID,LearningCenterCode,ClassCode,IsPlan,Operator,ElcState,OperateTime,ConfirmState,ConfirmTime,CurrentSelectNumber,SpyCode,IsApplyExam,ElcType,StudentID,refid)
            values
            (sys_guid(),InBatchCode,x_StudentCode,x_CourseID,x_LearningCenterCode,x_ClassCode,'1',InConfirmer,'1',sysdate,'1',sysdate,1,x_SpyCode,1,7,x_StudentID,x_refid);
          --д��ѧϰ״̬
            x_stuSN := seq_Elc_StudentStudyStatus.nextval;
            insert into EAS_Elc_StudentStudyStatus(SN,StudentCode,CourseID,StudyStatus,SignUpNum)
            values
            (x_stuSN,x_StudentCode,x_CourseID,'2',1);
          --���µ���������
            update Eas_ExmM_SignUp set elc_refid = x_refid where SN = x_signUpSN;
          end if;        
   end loop;
   close sign_row;
   commit;
END Pro_ConfirmSignUpToElc;


---------------------------------------ɾ��---------------------------------------------------------------

/*ͨ�����к�ɾ��*/
procedure PR_DeleteSignUpByPK(InSNs varchar2,InMaintainer varchar2,OutCount out int)
IS
   strSql varchar2(8000);
begin
    strSql:='insert into EAS_ExmM_SignUpDelLog(SN,ExamBatchCode,ExamPlanCode,
    ExamCategoryCode,
    AssessMode,ExamSiteCode,ExamSessionUnit,
    ExamPaperCode,ExamPaperMemo,CourseID,
    CourseName,TCPCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,
    StudentCode,ExamUnit,Applicant,ApplicatDate,SignUpType,
    IsConfirm,Confirmer,ConfirmDate,FeeCertificate,Elc_refid,DelMaintainer,DelMaintainDate
    )
    select SN,ExamBatchCode,ExamPlanCode,
    ExamCategoryCode,
    AssessMode,ExamSiteCode,ExamSessionUnit,
    ExamPaperCode,ExamPaperMemo,CourseID,
    CourseName,TCPCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,
    StudentCode,ExamUnit,Applicant,ApplicatDate,SignUpType,
    IsConfirm,Confirmer,ConfirmDate,FeeCertificate,Elc_refid,'''||InMaintainer||''','''||sysdate||'''
    from         
    EAS_ExmM_SignUp signUp
    where signUp.SN in ('||InSNs||') and signUp.isConfirm=''1''  and not exists(select 1 from EAS_ExmM_SeatArrange seatArrange where seatArrange.SignUp_SN = signUp.SN )';
    execute immediate strSql;
    --����ѧϰ�����
    strSql :='update EAS_Elc_StudentStudyStatus sss  set sss.SignUpNum = sss.SignUpNum -1 where 
        exists(select 1 from EAS_Elc_StudentElcInfo sei where sei.studentCode = sss.studentCode and sei.courseId=sss.courseId and exists(
            select 1 from EAS_ExmM_SignUp signUp where isConfirm=''1'' and signUp.SN in('||InSNs||')  and not exists(select 1 from EAS_ExmM_SeatArrange seatArrange where seatArrange.SignUp_SN = signUp.SN)
        ))  and sss.SignUpNum >=1';
        execute immediate strSql;
    --ɾ��
    strSql:='delete from EAS_ExmM_SignUp signUp where signUp.SN in('||InSNs||') and not exists(select 1 from EAS_ExmM_SeatArrange seatArrange where seatArrange.SignUp_SN = signUp.SN )';
    execute immediate strSql;
    OutCount := SQL%ROWCOUNT;
    commit;

end PR_DeleteSignUpByPK;

--ɾ��������Ϣ������ɾ���Ѿ�ȷ�ϵı������ݣ�
procedure PR_DeleteSignUp(InStrWhere varchar2,InMaintainer varchar2,OutCount out int)
    is
    strSql varchar2(2000);
    begin 
        strSql:='insert into EAS_ExmM_SignUpDelLog(SN,ExamBatchCode,ExamPlanCode,
        ExamCategoryCode,
        AssessMode,ExamSiteCode,ExamSessionUnit,
        ExamPaperCode,ExamPaperMemo,CourseID,
        CourseName,TCPCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,
        StudentCode,ExamUnit,Applicant,ApplicatDate,SignUpType,
        IsConfirm,Confirmer,ConfirmDate,FeeCertificate,Elc_refid,DelMaintainer,DelMaintainDate
        )
        select SN,ExamBatchCode,ExamPlanCode,
        ExamCategoryCode,
        AssessMode,ExamSiteCode,ExamSessionUnit,
        ExamPaperCode,ExamPaperMemo,CourseID,
        CourseName,TCPCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,
        StudentCode,ExamUnit,Applicant,ApplicatDate,SignUpType,
        IsConfirm,Confirmer,ConfirmDate,FeeCertificate,Elc_refid,'''||InMaintainer||''','''||sysdate||'''
        from
        EAS_ExmM_SignUp signUp
        where 1=1 '||InStrWhere||' and isConfirm=''1'' and not exists(select 1 from EAS_ExmM_SeatArrange seatArrange where seatArrange.SignUp_SN = signUp.SN )';
        execute immediate strSql;
        
        strSql :='update EAS_Elc_StudentStudyStatus sss  set sss.SignUpNum = sss.SignUpNum -1 where 
        exists(select 1 from EAS_Elc_StudentElcInfo sei where sei.studentCode = sss.studentCode and sei.courseId=sss.courseId and exists(
            select 1 from EAS_ExmM_SignUp signUp where isConfirm=''1'' '||InStrWhere|| ' and not exists(select 1 from EAS_ExmM_SeatArrange seatArrange where seatArrange.SignUp_SN = signUp.SN )
        )) and sss.SignUpNum >=1';
        execute immediate strSql;
        
        strSql:='delete from EAS_ExmM_SignUp signUp where 1=1 '||InStrWhere ||' and not exists(select 1 from EAS_ExmM_SeatArrange seatArrange where seatArrange.SignUp_SN = signUp.SN )';
        execute immediate strSql;
        OutCount := SQL%ROWCOUNT;
        commit;
        
end PR_DeleteSignUp;


---------------------------------------�Ծ��----------------------------------------
/*�����Ծ�źͱ�ע��Ϣ������Ծ�ű�ע��ϢΪ�գ��򲻸���*/
PROCEDURE PR_ExmM_SignUp_UpdateExamPaper(InStrXml VARCHAR2,OutCount out int )
IS
    --����xml����
    xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
    doc xmldom.DOMDocument;
    --�ڵ�
    pNodes xmldom.DOMNODELIST;
    --��ʱ�ڵ�
    tempNode XMLDOM.DOMNODE;
    --�ӽڵ�
    chilNodes xmldom.DOMNodeList;
    --����
    pCount        number;
    
    
    x_SN NUMBER(10);
    x_ExamPaperCode VARCHAR2(20) ;
    x_ExamPaperMemo VARCHAR2(200);
    x_ExamSessionUnit varchar2(20);
BEGIN
    
--�������
   XMLPARSER.PARSECLOB(xmlPar,InStrXml);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --�ͷ�
   XMLPARSER.FREEPARSER(xmlPar);
   --��ȡ�ڵ�
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
   
   --��ȡ����
   pCount := XMLDOM.GETLENGTH(pNodes);
   outCount :=0;
   
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    x_SN:= XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ExamPaperCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1))); 
    x_ExamPaperMemo := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_ExamSessionUnit:= XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    
    if x_ExamPaperMemo is Null or x_ExamPaperMemo ='' then
        update EAS_ExmM_SignUp set ExamPaperCode = x_ExamPaperCode,ExamSessionUnit = x_ExamSessionUnit where SN = x_SN;
    else
        update EAS_ExmM_SignUp set ExamPaperCode = x_ExamPaperCode,ExamSessionUnit = x_ExamSessionUnit ,ExamPaperMemo =x_ExamPaperMemo where SN = x_SN;
    end if;
    commit;
    OutCount:=OutCount+1;
   END LOOP;

    
   EXCEPTION
     WHEN OTHERS THEN
     outCount := 0;
       -- Consider logging the error and then re-raise
       DBMS_OUTPUT.PUT_LINE(SQLERRM);
       RAISE;
END PR_ExmM_SignUp_UpdateExamPaper;




--------------------------------ѧϰ״̬-------------------------------------------
--���±�������
PROCEDURE PR_ExmM_upDateStuStadyStatus(InWhereStr VARCHAR2,OutCount out int )
IS 
strSql varchar2(5000);
BEGIN
      strSql := 'UPDATE EAS_Elc_StudentStudyStatus status set SignUpNum = case when SignUpNum is null then 1 else SignUpNum +1 end where exists(select 1 from EAS_ExmM_SignUp signUp where status.StudentCode = signUp.StudentCode and status.CourseID = signUp.CourseID and '||InWhereStr||')';
      dbms_output.put_line(strSql);
      execute immediate strSql;
      OutCount := SQL%ROWCOUNT;
      commit;
END PR_ExmM_upDateStuStadyStatus;

end PK_ExmM_SignUp;
/

