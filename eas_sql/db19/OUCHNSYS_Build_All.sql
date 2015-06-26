--
-- Create Schema Script 
--   Database Version          : 11.2.0.3.0 
--   Database Compatible Level : 11.2.0.3.0 
--   Script Compatible Level   : 11.2.0.3.0 
--   Toad Version              : 12.1.0.22 
--   DB Connect String         : ORCL19 
--   Schema                    : OUCHNSYS 
--   Script Created by         : OUCHNSYS 
--   Script Created at         : 2015/06/26 17:18:42 
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


@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\LIST50_VARCHAR.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\MROW_STUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\MTB_STUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\MYVARCHAR2.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\ROW_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\R_SIGNSTATICS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\SIGNSTATICS_TAB.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\TAB_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\TCPCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Types\TCPMODULECOURSES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_ELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_EXAM_NETEXAMSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_EXMM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_EXMM_EXAMLAYOUT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_EXMM_SIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_TCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_ELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_EXAM_NETEXAMSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_EXMM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_EXMM_EXAMLAYOUT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_EXMM_SIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_TCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PRCALMODULETOTALCREDIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PROCALMODULETOTALCREDIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PRO_CONFIRMSIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PRO_EXAM_ANSWERORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PRO_EXAM_PAPERORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PRO_EXAM_SIGNORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PRO_EXAM_TYPEORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PR_EXMM_IMPORTNETSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PR_EXMM_SIGNUPTEST.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\PR_EXMM_UPDATESTUSTADYSTATUS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Procedures\SELECTSTUDENTSOFNUM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Functions\GETSCORESTANDARDPLAN.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Functions\SPLITTOARRAY.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_EXMM_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_EXMM_SCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\Packages\PK_GRADUATION_TRIAL.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_EXMM_ORDER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_EXMM_SCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\db19\PackageBodies\PK_GRADUATION_TRIAL.sql;
