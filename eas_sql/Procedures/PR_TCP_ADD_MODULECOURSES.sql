--
-- PR_TCP_ADD_MODULECOURSES  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_ADD_ModuleCourses(
inTCPCode in varchar2,--专业规则编码
inSegOrgCode in varchar2,--分部编码
inLearningCenterCode in varchar2--学习中学编码
)
AS
CourseID EAS_TCP_ModuleCourses.CourseID%TYPE;--课程ID
CourseState EAS_Course_BasicInfo.State%TYPE;--课程状态
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/26   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，将(专业规则管理_教学计划模块课程)添加到(专业规则管理_学习中心课程总表)

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 14:54:33, and 2014/3/26 14:54:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   --创建游标
   DECLARE CURSOR myCusor IS 
    --查询专业规则管理_教学计划模块课程，并取出基本课程中该课程的状态
    SELECT etmc.CourseID,ecbi.State FROM EAS_TCP_ModuleCourses etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=1 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);--学习中心课程总表中不存在
        BEGIN
            OPEN myCusor;            
                LOOP
                    BEGIN
                        --循环取出数值
                        FETCH myCusor INTO CourseID,CourseState;
                        --没有数据，退出循环
                        EXIT WHEN myCusor%NOTFOUND;
                        --将课程信息插入到专业规则管理_学习中心课程总表中
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
END PR_TCP_ADD_ModuleCourses;
/

