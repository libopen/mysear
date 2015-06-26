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


@D:\国开教务项目\document\技术文档\toad\schema\Types\ARREXAMDATE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\EXAMPLAN.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\EXAMTIME.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\MROW_STUDENTELC.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\MROW_STUDENTELC2.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\MTB_STUDENTELC.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\MYVARCHAR2.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\R_PAPERLIST.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\R_SIGNSTATICS.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\SIGNSTATICS_TAB.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\STR_SPLIT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\TCPCOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\TCPMODULECOURSES.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\TYP_EXECMODULECOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\TYP_IMPLRULE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\TYP_MODULERULE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\T_PAPERLIST.sql;
@D:\国开教务项目\document\技术文档\toad\schema\TypeBodies\EXAMPLAN.sql;
@D:\国开教务项目\document\技术文档\toad\schema\TypeBodies\EXAMTIME.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PAGER.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PAGINGPACKAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PDTYPES.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PKG_SELECT_COURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_EXMM_SESSIONUNIT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_EXPT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_GRAD_AUDIT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_SIGN.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_STUDENTCOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_SYSMESSAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_TRACKERSYSMESSAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\TYPES.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\INTEGRITYPACKAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PAGER.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PKG_SELECT_COURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_EXMM_SCORE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_EXMM_SESSIONUNIT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_EXPT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_GRAD_AUDIT.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_SIGN.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_STUDENTCOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_SYSMESSAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_TRACKERSYSMESSAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\COMMON_PAGINGLIST.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\LOOPPROC.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\OUTPUT_DATE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PROGRADTRAILLISTPROCESS.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_COPYSEMESTEROPENCOURSES.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_EXMM_IMPORTNETSCORE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_EXMM_IMPORTNETSCORETEST.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_EXMM_SIGNUP.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_GETPAGER.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ADD_CONVERSIONCOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ADD_EXECMODULECOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ADD_IMPLMODULECOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ADD_MODULECOURSES.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ADD_SEGMSEMECOURSBYTERM.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_COPY_SEGMSEMEOPENCOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_DEL_DELETEGUIDANCETCP.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ENABLE_GUIDANCEENABLED.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_ENABLE_IMPLENABLED.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_EXECUTIONENABLE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_EXT_IMPLEXTENDCOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_MODIFY_EXECUTIONSTATE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_MODIFY_EXECUTIONSTATE_T.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\P_XMLPARSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\SELECTSTUDENTSOFNUM.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\SP_PAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\TEST0.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\TEST2.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\TEST5.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\UPDATEGRADAUDITCONDITIONPASS.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\test5_1.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\EXISTS2.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\FN_BIT2NUMBER.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\FN_ELC_GETSTUDENELC.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\FN_GETNETGUID.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\FN_GETTCPCODE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\FN_HEXTOSTRING.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\FN_RECORDSYSMESSAGE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\GETNORMALSEMESTERS.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\IDATTRIBUTEOFDOCELCMENTS.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\IDATTRIBUTEOFDOCELEMENTS.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\IS_NUMBER.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\SPLITSTR.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\SPLITTOARRAY.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\SP_LISTSTUDENTELC.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\TESTFUN612.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\TOBYTE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Functions\testf.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\COL_EXECMODULECOURSE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Types\COL_MODULERULE.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_EXMM.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Packages\PK_TCP.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_EXMM.sql;
@D:\国开教务项目\document\技术文档\toad\schema\PackageBodies\PK_TCP.sql;
@D:\国开教务项目\document\技术文档\toad\schema\Procedures\PR_TCP_COPY_COPYGUIDANCETCP.sql;
