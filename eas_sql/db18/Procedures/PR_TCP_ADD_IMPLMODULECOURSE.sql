--
-- PR_TCP_ADD_IMPLMODULECOURSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_ADD_ImplModuleCourse(
inTCPCode in varchar2,--רҵ�������
inSegOrgCode in varchar2,--�ֲ�����
inLearningCenterCode in varchar2--ѧϰ��ѧ����
)
AS
CourseID EAS_TCP_ImplModuleCourse.CourseID%TYPE;--�γ�ID
CourseState EAS_Course_BasicInfo.State%TYPE;--�γ�״̬
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:ִ����רҵ�������õ��ã���(רҵ�������_ʵʩ�Խ�ѧ��ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   --�����α�
   DECLARE CURSOR myCusor IS 
    --��ѯרҵ�������_��ѧ�ƻ�ģ��γ̣���ȡ�������γ��иÿγ̵�״̬
    SELECT etmc.CourseID,ecbi.State FROM EAS_TCP_ImplModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=2 --�γ�����Ϊ���޿�
    and TCPCode=inTCPCode--רҵ��������ͬ
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);--ѧϰ���Ŀγ��ܱ��в�����
        BEGIN
            OPEN myCusor;            
                LOOP
                    BEGIN
                        --ѭ��ȡ����ֵ
                        FETCH myCusor INTO CourseID,CourseState;
                        --û�����ݣ��˳�ѭ��
                        EXIT WHEN myCusor%NOTFOUND;
                        --���γ���Ϣ���뵽רҵ�������_ѧϰ���Ŀγ��ܱ���
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

