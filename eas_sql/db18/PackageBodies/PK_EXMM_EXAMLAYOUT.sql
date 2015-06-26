--
-- PK_EXMM_EXAMLAYOUT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_EXMM_ExamLayOut AS
----�����Ž��д��������
PROCEDURE PRO_Exam_InsertArrangeResult
(
InExamPlanCode varchar2,
InCreateOrgCode varchar2,
strXml varchar2,
InMaintainer varchar2,
outCount out int
)
 IS
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

--�������
x_ExamCategoryCode varchar(3);
x_ExamSiteCode varchar2(10);
x_ExamRoomCode  VARCHAR2(5) ;
x_ExamPaperCode varchar(10);
x_ExamSessionUnit varchar2(3);
x_SecretNumber varchar2(50);
x_NumOfRoom int;
x_IsLastRoom int;
x_IsKeepRoom int;
x_NumOfKeep int;
x_ExamUnitType varchar(10);
x_SeatNo  int;
x_IsLeft    int;
x_IsNew int;
 
BEGIN
   --�������
   XMLPARSER.PARSECLOB(xmlPar,strXml);
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
     
    x_ExamCategoryCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ExamSiteCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_ExamRoomCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_ExamPaperCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    x_ExamSessionUnit := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    x_SecretNumber := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
    x_NumOfRoom := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,6)));
    x_IsLastRoom := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,7)));
    x_NumOfKeep := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,8)));
    x_IsKeepRoom := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,9)));
    x_ExamUnitType := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,10)));
    x_IsNew := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,11)));
    
    --
    if x_IsNew = 1 then
        insert into EAS_ExmM_ArrangeResult(SN,ExamPlanCode,CreateOrgCode,ExamCategoryCode,ExamSiteCode,ExamRoomCode,ExamPaperCode,ExamSessionUnit,SecretNumber,NumOfRoom,IsLastRoom,
        NumOfKeep,IsKeepRoom,ExamUnitType,CreateTime,Maintainer)values
        (seq_ExmM_ArrangeResult.nextVal,InExamPlanCode,InCreateOrgCode,x_ExamCategoryCode,x_ExamSiteCode,x_ExamRoomCode,x_ExamPaperCode,x_ExamSessionUnit,x_SecretNumber,x_NumOfRoom
        ,x_IsLastRoom,x_NumOfKeep,x_IsKeepRoom,x_ExamUnitType,sysdate,InMaintainer);
    else
        update EAS_ExmM_ArrangeResult set isLastRoom =x_IsLastRoom,numOfRoom = x_NumOfRoom where examPlanCode = InExamPlanCode 
        and examCategoryCode=x_ExamCategoryCode and examRoomCode = x_ExamRoomCode and examSiteCode = x_ExamSiteCode and examPaperCode = x_ExamPaperCode;
    end if;
    outCount:=outCount+1;
    
    END LOOP;
    COMMIT;
END PRO_Exam_InsertArrangeResult;


--�������α����е�������Ϣ
PROCEDURE Pro_Exam_UpdateSeatArrange(
strXml varchar2,
outCount out int
) IS
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

--�������
x_ExamPlanCode varchar2(50);
x_SecretNumber varchar2(50);
x_ExamRoomCode  VARCHAR2(20);
x_ExamPaperCode varchar2(50);
x_StudentCode varchar2(50);
x_SeatNo  int;
x_IsLeft    int;

BEGIN
   --�������
   XMLPARSER.PARSECLOB(xmlPar,strXml);
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
     
    x_ExamPlanCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_SecretNumber := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_ExamRoomCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_ExamPaperCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    x_SeatNo := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
    x_IsLeft := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,6)));
    
    --
     update Eas_ExmM_SeatArrange seatArrange set seatArrange.SEATNO = x_SeatNo, seatArrange.EXAMROOMCODE=x_ExamRoomCode,seatArrange.ISLEFT = x_IsLeft,seatArrange.secretNumber = x_secretNumber 
     where seatArrange.examPlanCode = x_ExamPlanCode and seatArrange.studentCode=x_StudentCode and seatArrange.examPaperCode = x_ExamPaperCode;
    COMMIT;
    outCount:=outCount+1;
   
   END LOOP;
END Pro_Exam_UpdateSeatArrange;
END PK_EXMM_ExamLayOut;
/

