--
-- EXAMTIME  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."EXAMTIME"                                                                                   AS OBJECT
(
  PARTSNUM NUMBER,    ---考几场
  NEWBEGINDATE DATE,       --新考试开始日期
  NEWENDDATE DATE,         --新考试结束日期
  EXISTBEGINDATE DATE,     --存在的考试开始日期
  EXISTENDDATE DATE,       --存在的考试结束日期
  BeginNumber  number,     --总部起始时间单元号
  SegmentBeginNumber number ,--分部起始单元号
  member function GetExamDateList(i_Operate IN number) return arrExamDate  --i_Operate 1 只使用新时间段 2 使用扩展时间段
);
/

