--
-- PRO_CONFIRMSIGNUP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pro_ConfirmSignUp(
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
TYPE signUpRec IS REF CURSOR;--�����û�����
sign_row signUpRec; --�����α����
BEGIN
   
   strSql:='UPDATE EAS_ExmM_SignUp SET Confirmer = '''||InConfirmer ||''',ConfirmDate=sysdate,IsConfirm=''1'' where 1=1 '||InStrWhere ||' and (IsConfirm==''0'' or IsConfirm is null)';
     execute immediate strSql;
     OutCount := SQL%ROWCOUNT;
   --���������ѡ�εĸ���
   strElcSql := 'UPDATE EAS_Elc_StudentStudyStatus status set SignUpNum = case when SignUpNum is null then 1 else SignUpNum +1 end where exists(select 1 from EAS_ExmM_SignUp signUp where status.StudentCode = StudentCode and status.CourseID = CourseID and '||InStrWhere||')';
   execute immediate strElcSql;
   
   
   --��ȡ������ѡ����Ϣ�ı�����¼
   strSignUpSql:='select studentCode,CourseID,LearningCenterCode,ClassCode from Eas_ExmM_SignUp signUp where and signUp.IsConfirm==''1'''||InStrWhere ||' and not exists(select 1 from EAS_Elc_StudentElcInfo where refid=signUp.refid)';
   --��ȡ������Ϣ
   open sign_row for strSignUpSql;
   loop
          FETCH sign_row into x_StudentCode,x_CourseID,x_LearningCenterCode,x_ClassCode;
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
          end if;
          
   end loop;
   close sign_row;
END Pro_ConfirmSignUp;
/

