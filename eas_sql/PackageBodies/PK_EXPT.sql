--
-- PK_EXPT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_EXPT AS
/******************************************************************************
   NAME:       PK_EXPT
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-06-17      libin       1. Created this package body.
******************************************************************************/
----���������ɼ� i_XMLSTR ��������XML��ʽ  i_impFile �����ļ���,i_Maintainer ά���� RETCODE ����ֵ�������أ��ɹ�������ʧ�������� ���쳣���أ�1
 PROCEDURE PR_EXPT_IMPORTREPORT(i_XMLSTR VARCHAR2,i_impFile VARCHAR2, i_Maintainer  VARCHAR2 , RETCODE out VARCHAR2) IS
    ---***XML***---
   --��ʽ <t>
  --<r><A>ѧ��</A><B>����</B><C>ѧϰ���Ĵ���</C><D>��Ŀ����</D><E>������Ϣ</E></r>
  --</t>
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
        v_FullName   VARCHAR2(100) ;
        v_StudentCode VARCHAR2(50);
        v_FeedBack VARCHAR2(200);
        v_LearningcenterCode VARCHAR2(100);
        v_SubjectCode VARCHAR2(100);

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
    
    v_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    v_FullName := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    v_LearningcenterCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    v_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    v_FeedBack := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    
    insert into TMP_ExmM_ImportReport 
           (StudentCode   ,FullName ,LearningCenterCode    ,SubjectCode   ,FeedBack  ,Maintainer  ,MaintainDate)
    select v_StudentCode,v_FullName,v_LearningcenterCode  ,v_SubjectCode, v_FeedBack,i_Maintainer,v_Maintaindate
    from dual where v_StudentCode is not null and v_LearningcenterCode is not null and v_SubjectCode is not null
    and not exists(select * from TMP_ExmM_ImportReport where studentcode=v_StudentCode and subjectcode=v_SubjectCode );
      
   
   END LOOP;
   
   ---InValidState 1.δ�ϱ� 2.�Ѿ��ϱ��Ѿ����� 3.��¼������
   merge into TMP_ExmM_ImportReport aa 
   using EAS_Expt_ExptNetExam bb on (aa.studentcode=bb.studentcode and aa.LearningCenterCode=bb.LearningCenterCode and aa.SubjectCode=bb.SubjectCode)
    when  MATCHED THEN
       update set sn=bb.sn ,InValidState=case when bb.IsReport=0 then 1 when bb.isReport=1 and  bb.FeedBackState !=0 then 2  end;
       
       update TMP_ExmM_ImportReport set InValidState=3 where sn is null;
       
    merge into EAS_Expt_ExptNetExam aa 
    using TMP_ExmM_ImportReport bb on (aa.sn=bb.sn)
    when  MATCHED THEN
       update set FeedBack=bb.FeedBack ,FeedBackState=2
       where bb.InValidState is null;
       
       v_SuccessTotalCount:= SQL%ROWCOUNT;     
 
      insert into EAS_ExmM_ImpFail(ImpFileName,StudentCode,FullName,LearningCenterCode,SubjectCode,Maintainer
       ,CreateTime,Fail)
       select i_impFile,StudentCode,FullName,LearningCenterCode,SubjectCode,Maintainer
       ,MaintainDate,InValidState from TMP_ExmM_ImportReport where InValidState is not null
       and not exists(select * from EAS_ExmM_ImpFail where ImpFileName=i_impFile and studentcode=TMP_ExmM_ImportReport.studentcode and 
       SubjectCode=TMP_ExmM_ImportReport.SubjectCode)
       ;
   
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
END PR_EXPT_IMPORTREPORT;

END PK_EXPT;
/

