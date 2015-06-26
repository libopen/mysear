--
-- PK_EXMM_SESSIONUNIT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_ExmM_SessionUnit AS
    PROCEDURE UpdateSessionUnitInSubjectPlan(InXml IN varchar2,OutCount out int)
     IS
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
            x_SN    int ;
            x_SessionUnit  VARCHAR2(30) ;
            
            
        begin
           XMLPARSER.PARSECLOB(xmlPar,InXml);
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
             
            x_SN := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
            x_SessionUnit := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
            
            --
            update EAS_ExmM_SubjectPlan plan set plan.ExamSessionUnit = x_SessionUnit,ArrangeState = 1 where plan.SN =x_SN;
            outCount:=outCount+1;
            commit;
           END LOOP;
           
           XMLDOM.FREEDOCUMENT(doc);
           EXCEPTION
           WHEN OTHERS THEN 
           DBMS_OUTPUT.PUT_LINE(SQLERRM);
    end UpdateSessionUnitInSubjectPlan;
END PK_ExmM_SessionUnit;
/

