--
-- Create Schema Script 
--   Database Version          : 11.2.0.3.0 
--   Database Compatible Level : 11.2.0.3.0 
--   Script Compatible Level   : 11.2.0.3.0 
--   Toad Version              : 12.1.0.22 
--   DB Connect String         : ORCL19 
--   Schema                    : OUCHNSYS 
--   Script Created by         : OUCHNSYS 
--   Script Created at         : 2015/06/26 17:17:08 
--   Physical Location         :  
--   Notes                     :  
--

-- Object Counts: 
--   Functions: 2       Lines of Code: 77 
--   Packages: 9        Lines of Code: 283 
--   Package Bodies: 9  Lines of Code: 2471 
--   Procedures: 11     Lines of Code: 714 
--   Types: 10 



-- "Set define off" turns off substitution variables. 
Set define off; 


@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\LIST50_VARCHAR.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MROW_STUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MTB_STUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MYVARCHAR2.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\ROW_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\R_SIGNSTATICS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\SIGNSTATICS_TAB.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TAB_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TCPCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TCPMODULECOURSES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_ELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXAM_NETEXAMSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM_EXAMLAYOUT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM_SIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_TCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_ELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXAM_NETEXAMSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM_EXAMLAYOUT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM_SIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_TCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PRCALMODULETOTALCREDIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PROCALMODULETOTALCREDIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PRO_CONFIRMSIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PRO_EXAM_ANSWERORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PRO_EXAM_PAPERORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PRO_EXAM_SIGNORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PRO_EXAM_TYPEORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_EXMM_IMPORTNETSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_EXMM_SIGNUPTEST.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_EXMM_UPDATESTUSTADYSTATUS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\SELECTSTUDENTSOFNUM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\GETSCORESTANDARDPLAN.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\SPLITTOARRAY.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM_SCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_GRADUATION_TRIAL.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM_SCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_GRADUATION_TRIAL.sql;
