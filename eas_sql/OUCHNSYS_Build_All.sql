--
-- Create Schema Script 
--   Database Version          : 11.2.0.3.0 
--   Database Compatible Level : 11.2.0.3.0 
--   Script Compatible Level   : 11.2.0.3.0 
--   Toad Version              : 12.1.0.22 
--   DB Connect String         : ORCL18 
--   Schema                    : OUCHNSYS 
--   Script Created by         : OUCHNSYS 
--   Script Created at         : 2015/06/26 17:12:24 
--   Physical Location         :  
--   Notes                     :  
--

-- Object Counts: 
--   Functions: 17      Lines of Code: 539 
--   Packages: 14       Lines of Code: 386 
--   Package Bodies: 13 Lines of Code: 5154 
--   Procedures: 31     Lines of Code: 2309 
--   Types: 19 
--   Type Bodies: 2 



-- "Set define off" turns off substitution variables. 
Set define off; 


@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\ARREXAMDATE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\EXAMPLAN.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\EXAMTIME.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MROW_STUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MROW_STUDENTELC2.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MTB_STUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\MYVARCHAR2.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\R_PAPERLIST.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\R_SIGNSTATICS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\SIGNSTATICS_TAB.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\STR_SPLIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TCPCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TCPMODULECOURSES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TYP_EXECMODULECOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TYP_IMPLRULE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\TYP_MODULERULE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\T_PAPERLIST.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\TypeBodies\EXAMPLAN.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\TypeBodies\EXAMTIME.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PAGER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PAGINGPACKAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PDTYPES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PKG_SELECT_COURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM_SESSIONUNIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXPT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_GRAD_AUDIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_SIGN.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_STUDENTCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_SYSMESSAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_TRACKERSYSMESSAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\TYPES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\INTEGRITYPACKAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PAGER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PKG_SELECT_COURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM_SCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM_SESSIONUNIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXPT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_GRAD_AUDIT.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_SIGN.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_STUDENTCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_SYSMESSAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_TRACKERSYSMESSAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\COMMON_PAGINGLIST.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\LOOPPROC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\OUTPUT_DATE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PROGRADTRAILLISTPROCESS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_COPYSEMESTEROPENCOURSES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_EXMM_IMPORTNETSCORE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_EXMM_IMPORTNETSCORETEST.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_EXMM_SIGNUP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_GETPAGER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ADD_CONVERSIONCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ADD_EXECMODULECOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ADD_IMPLMODULECOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ADD_MODULECOURSES.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ADD_SEGMSEMECOURSBYTERM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_COPY_SEGMSEMEOPENCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_DEL_DELETEGUIDANCETCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ENABLE_GUIDANCEENABLED.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_ENABLE_IMPLENABLED.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_EXECUTIONENABLE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_EXT_IMPLEXTENDCOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_MODIFY_EXECUTIONSTATE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_MODIFY_EXECUTIONSTATE_T.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\P_XMLPARSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\SELECTSTUDENTSOFNUM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\SP_PAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\TEST0.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\TEST2.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\TEST5.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\UPDATEGRADAUDITCONDITIONPASS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\test5_1.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\EXISTS2.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\FN_BIT2NUMBER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\FN_ELC_GETSTUDENELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\FN_GETNETGUID.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\FN_GETTCPCODE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\FN_HEXTOSTRING.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\FN_RECORDSYSMESSAGE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\GETNORMALSEMESTERS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\IDATTRIBUTEOFDOCELCMENTS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\IDATTRIBUTEOFDOCELEMENTS.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\IS_NUMBER.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\SPLITSTR.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\SPLITTOARRAY.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\SP_LISTSTUDENTELC.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\TESTFUN612.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\TOBYTE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Functions\testf.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\COL_EXECMODULECOURSE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Types\COL_MODULERULE.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_EXMM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Packages\PK_TCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_EXMM.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\PackageBodies\PK_TCP.sql;
@D:\����������Ŀ\document\�����ĵ�\toad\schema\Procedures\PR_TCP_COPY_COPYGUIDANCETCP.sql;
