--
-- EXAMTIME  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."EXAMTIME"                                                                                   AS OBJECT
(
  PARTSNUM NUMBER,    ---������
  NEWBEGINDATE DATE,       --�¿��Կ�ʼ����
  NEWENDDATE DATE,         --�¿��Խ�������
  EXISTBEGINDATE DATE,     --���ڵĿ��Կ�ʼ����
  EXISTENDDATE DATE,       --���ڵĿ��Խ�������
  BeginNumber  number,     --�ܲ���ʼʱ�䵥Ԫ��
  SegmentBeginNumber number ,--�ֲ���ʼ��Ԫ��
  member function GetExamDateList(i_Operate IN number) return arrExamDate  --i_Operate 1 ֻʹ����ʱ��� 2 ʹ����չʱ���
);
/

