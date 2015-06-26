--
-- PK_EXAM_NETEXAMSCORE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_EXAM_NETEXAMSCORE AS
/******************************************************************************
   NAME:       PR_EXMM_IMPORTNETSCORE
   PURPOSE:  �������_���������ɼ���

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-05-21      libin       1. Created this package body.
******************************************************************************/
----���������ɼ� i_XMLSTR ��������XML��ʽ  i_UnifBatchCode ��������,i_Maintainer ά���� RETCODE ����ֵ�������أ��ɹ�������ʧ�������� ���쳣���أ�1
 PROCEDURE PR_EXMM_IMPORTNETSCORE(i_XMLSTR VARCHAR2,i_UnifBatchCode VARCHAR2, i_Maintainer  VARCHAR2 , RETCODE out VARCHAR2) IS
    ---***XML***---
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
    ---*** END *** ---
  
   ---** local variables
        v_SubjectCode   VARCHAR2(10) ;
        v_StudentCode VARCHAR2(20);
        v_ScoreCode VARCHAR2(10);
        v_SegmentCode VARCHAR2(15);

        v_SuccessTotalCount NUMBER;
        v_FailTotalCount NUMBER;
        v_start number;
        v_end   number;

        v_Maintaindate date := sysdate;
BEGIN 
    v_start := dbms_utility.get_time;
  --�������
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --�ͷ�
   XMLPARSER.FREEPARSER(xmlPar);
   --��ȡ�ڵ�
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --��ȡ����
   pCount := XMLDOM.GETLENGTH(pNodes);
 
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    v_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    v_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    v_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    v_SegmentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    
    
    insert into TMP_ExmM_NetExamScore 
           (sn                          ,SubjectCode   ,StudentCode ,SegmentCode    ,ScoreCode   ,UnifBatchCode  ,Maintainer  ,MaintainDate,invalidstate)
    select seq_ExmM_NetExamScore.Nextval,v_SubjectCode,v_StudentCode,v_SegmentCode  ,v_ScoreCode, i_UnifBatchCode,i_Maintainer,v_Maintaindate,'1'
    from dual where v_SubjectCode is not null and v_StudentCode is not null
    and not exists(select * from TMP_ExmM_NetExamScore where studentcode=v_StudentCode and subjectcode=v_StudentCode and  
    UnifBatchCode=i_UnifBatchCode);
      
   
   END LOOP;
   
   merge into TMP_ExmM_NetExamScore aa 
   using eas_schroll_student@ouchnbase bb on (aa.studentcode=bb.studentcode)
    when  MATCHED THEN
       update set CollegeCode=substr(bb.LearningCenterCode,1,5),LearningCenterCode=bb.LearningCenterCode
           ,ClassCode=bb.ClassCode,FullName=bb.FullName,EnrollmentStatus=bb.EnrollmentStatus,InValidState=case when bb.EnrollmentStatus<>'1' then 'D' else '1' end;
    
   update TMP_ExmM_NetExamScore set InValidState='C' where fullname is null;
   
    update TMP_ExmM_NetExamScore set InValidState='E' where  not exists(select * from EAS_ExmM_NetExamSubject@ouchnbase where subjectcode=TMP_ExmM_NetExamScore.subjectCode) ;
  
         
   merge into TMP_ExmM_NetExamScore aa 
    using eas_dic_scorecode@ouchnbase bb on (aa.ScoreCode=bb.diccode)
    when  MATCHED THEN
       update set aa.score=bb.dicscore;
       
   merge into TMP_ExmM_NetExamScore aa 
    using eas_exmm_netExamScore bb on (aa.studentcode=bb.studentcode and aa.UnifBatchCode=bb.UnifBatchCode and aa.SubjectCode=bb.SubjectCode)
     when  MATCHED THEN
          update set aa.sn=bb.sn;
          
   merge into eas_exmm_netExamScore aa
       using TMP_ExmM_NetExamScore bb on (aa.sn=bb.sn)
       when  MATCHED THEN
          update set aa.scorecode=bb.scorecode ,aa.score=bb.score,aa.maintainer=bb.maintainer,AA.MAINTAINDATE =BB.MAINTAINDATE 
        when not  MATCHED THEN   
       insert (
              SN,segmentcode,collegecode,learningcentercode,classcode,UnifBatchCode,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
           values(bb.sn,bb.segmentcode,bb.collegecode,bb.learningcentercode,bb.classcode,bb.UnifBatchCode,bb.SubjectCode,bb.StudentCode,bb.FullName,bb.Score,bb.ScoreCode,bb.Maintainer,bb.MaintainDate)
           where bb.InValidState='1';
       v_SuccessTotalCount:= SQL%ROWCOUNT;          
           ------deal EAS_ExmM_NetExamScoreLost
           
      insert into EAS_ExmM_NetExamScoreLost(sn,segmentcode,collegecode,learningcentercode,classcode,UnifBatchCode,studentcode,subjectcode,FullName,Score,ScoreCode,maintainer,maintaindate,Reason,ImpSource)
      select    sn,segmentcode,collegecode,learningcentercode,classcode,UnifBatchCode,studentcode,subjectcode,FullName,Score,ScoreCode,maintainer,maintaindate,InValidState,1 from TMP_ExmM_NetExamScore
      where InValidState<>'1';
        v_FailTotalCount:= SQL%ROWCOUNT;    
 
   v_end := dbms_utility.get_time;
   DBMS_OUTPUT.PUT_LINE(v_end-v_start);
   
   --CLOSE sInfo;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=v_SuccessTotalCount||','||v_FailTotalCount;
    commit; 
    
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
   RETCODE := '-1';
    rollback;
END PR_EXMM_IMPORTNETSCORE;
    
    

/******************************************************************************
   NAME:       PR_EXMM_IMPORTNETSCORE_30
   PURPOSE:����ͳ��Ӣ��ɼ����ѧӢ��A��30%ѧ����

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-05-21      libin       1. Created this package body.
******************************************************************************/
----���������ɼ� i_XMLSTR ��������XML��ʽ  i_UnifBatchCode ��������,i_Maintainer ά���� RETCODE ����ֵ�������ɹ�������ʧ�������� ���쳣���أ�1
 PROCEDURE PR_EXMM_IMPORTNETSCORE_30(i_XMLSTR VARCHAR2,i_UnifBatchCode VARCHAR2, i_Maintainer  VARCHAR2 , RETCODE out VARCHAR2) IS
    ---***XML***---
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
    ---*** END *** ---
  
   ---** local variables
        v_SubjectCode   VARCHAR2(10) ;
        v_StudentCode VARCHAR2(20);
        v_SegmentCode VARCHAR2(15);

        v_SuccessTotalCount NUMBER;
        v_FailTotalCount NUMBER;

        v_start number;
        v_end   number;

        v_Maintaindate date := sysdate;
BEGIN 
    v_start := dbms_utility.get_time;
  --�������
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --�ͷ�
   XMLPARSER.FREEPARSER(xmlPar);
   --��ȡ�ڵ�
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --��ȡ����
   pCount := XMLDOM.GETLENGTH(pNodes);

   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    v_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    v_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    v_SegmentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
      
    
    insert into TMP_ExmM_NetExamScore 
           (sn                          ,SubjectCode   ,StudentCode ,SegmentCode      ,UnifBatchCode  ,Maintainer  ,MaintainDate)
    select seq_ExmM_NetExamScore.Nextval,v_SubjectCode,v_StudentCode,v_SegmentCode    , i_UnifBatchCode,i_Maintainer,v_Maintaindate
    from dual where v_SubjectCode is not null and v_StudentCode is not null
    and not exists(select * from TMP_ExmM_NetExamScore where studentcode=v_StudentCode and subjectcode=v_StudentCode and  
    UnifBatchCode=i_UnifBatchCode);
      
   
   END LOOP; 
   
   
   merge into TMP_ExmM_NetExamScore aa 
   using eas_schroll_student@ouchnbase bb on (aa.studentcode=bb.studentcode)
    when  MATCHED THEN
       update set CollegeCode=substr(bb.LearningCenterCode,1,5),LearningCenterCode=bb.LearningCenterCode
           ,ClassCode=bb.ClassCode,FullName=bb.FullName,EnrollmentStatus=bb.EnrollmentStatus,InValidState=case when bb.EnrollmentStatus<>'1' then 'D' else '1' end;
    
   update TMP_ExmM_NetExamScore set InValidState='C' where fullname is null;
   
   update TMP_ExmM_NetExamScore set InValidState='E' where  not exists(select * from EAS_ExmM_NetExamSubject@ouchnbase where subjectcode=TMP_ExmM_NetExamScore.subjectCode) ;

  
   merge into TMP_ExmM_NetExamScore aa 
    using EAS_ExmM_UnifiedExamEngScore bb on (aa.studentcode=bb.studentcode and aa.UnifBatchCode=bb.UnifBatchCode and aa.SubjectCode=bb.SubjectCode)
     when  MATCHED THEN
          update set aa.sn=bb.sn;

        
    merge into EAS_ExmM_UnifiedExamEngScore aa
       using TMP_ExmM_NetExamScore bb on (aa.sn=bb.sn)
       when  MATCHED THEN
          update set aa.maintainer=bb.maintainer,AA.MAINTAINDATE =BB.MAINTAINDATE 
        when not  MATCHED THEN   
       insert (
              SN,segmentcode,collegecode,learningcentercode,UnifBatchCode,SubjectCode,StudentCode,FullName,Maintainer,MaintainDate)
             values(bb.sn,bb.segmentcode,bb.collegecode,bb.learningcentercode,bb.UnifBatchCode,bb.SubjectCode,bb.StudentCode,bb.FullName,bb.Maintainer,bb.MaintainDate)
            where bb.InValidState='1';
     
             v_SuccessTotalCount:= SQL%ROWCOUNT;          
 
   
      
           ------deal EAS_ExmM_NetExamScoreLost
           
      insert into EAS_ExmM_NetExamScoreLost(sn,segmentcode,collegecode,learningcentercode,classcode,UnifBatchCode,studentcode,subjectcode,FullName,Score,ScoreCode,maintainer,maintaindate,Reason,ImpSource)
      select    sn,segmentcode,collegecode,learningcentercode,classcode,UnifBatchCode,studentcode,subjectcode,FullName,Score,ScoreCode,maintainer,maintaindate,InValidState,2 from TMP_ExmM_NetExamScore
      where InValidState<>'1';
        v_FailTotalCount:= SQL%ROWCOUNT;
        
   v_end := dbms_utility.get_time;
   DBMS_OUTPUT.PUT_LINE(v_end-v_start);
   
   --CLOSE sInfo;
   XMLDOM.FREEDOCUMENT(doc);
    RETCODE :=v_SuccessTotalCount||','||v_FailTotalCount;
    commit; 
    
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
   RETCODE := '-1';
    rollback;
END PR_EXMM_IMPORTNETSCORE_30;
    
    
   
   

END PK_EXAM_NETEXAMSCORE;
/

