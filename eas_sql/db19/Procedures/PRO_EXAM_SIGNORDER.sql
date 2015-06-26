--
-- PRO_EXAM_SIGNORDER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pro_exam_signorder(examplancode in varchar2,
                                               res          out number --1为成功，0为失败
                                               ) is

  v_sql1_create varchar2(150) := 'insert into EAS_ExmM_TempSignOrder ';
  v_sql_select  varchar2(3000);
  v_sql_in      varchar2(1000);
begin

  if instr(examplancode, ',') > 0 then
    --如果是('','','')类型
    v_sql_in := ' in (' || examplancode || ')'; --就用where column in ('','','')
  else
    v_sql_in := ' = ''' || examplancode || ''''; --否则就用where column = ''
  end if;
  EXECUTE IMMEDIATE 'truncate table EAS_ExmM_TempSignOrder'; --清空表数据
  v_sql_select := v_sql1_create || 'select EEOrder.examplancode,' || --考试计划代码
                  'EEOrder.examcategorycode,' || --考试类别
                  'CountAll.exampapercode,' || --试卷代码
                  'EEOrder.ExamUnit,' || --考试单位类型
                  'SubjectPlan.exampapername,' || --试卷名称
                  'decode(EEOrder.orgtype, 2, EEOrder.orgcode) CollageCode,' || --学院代码
                  'decode(EEOrder.orgtype, 1, EEOrder.orgcode) SegmentCode,' || --分部代码
                  'PrintshopNameTable.Printshopname Printshopname,' ||
                  'CountAll.s1 S1,' || --T1
                  'CountAll.cou SCount ' || --单行合计
                  ' from (select CountLocal.*, CountLocal.s1 cou ' || --单行合计
                  ' from (select CountSum.sn,CountSum.exampapercode,' || --试卷代码
                  ' sum(decode(SignOrder.signnormcode, ''' || 'l1' ||
                  ''', SignOrder.totalorders+SignOrder.ADJUSTMENT)) s1 ' || --T1
                  ' from EAS_ExmM_Order CountSum ' ||
                  ' inner join EAS_ExmM_SignOrder SignOrder ' ||
                  ' on CountSum.sn = SignOrder.sn ' ||
                  ' where CountSum.OrderType=1 and CountSum.isReport=1 and CountSum.examplancode' || v_sql_in || --1:正常订单 2：补订单
                  ' group by CountSum.sn,exampapercode) CountLocal) CountAll ' ||
                  ' inner join EAS_ExmM_Order EEOrder' ||
                  ' on CountAll.sn = EEOrder.sn' ||
                  ' inner join EAS_ExmM_ExamCoursePlanList@ouchnbase CoursePlanList' ||
                  ' on CoursePlanList.exampapercode = EEOrder.exampapercode' ||
                  '                                                          ' ||
                  ' inner join EAS_ExmM_SubjectPlan@ouchnbase SubjectPlan' ||
                  ' on CountAll.exampapercode = SubjectPlan.exampapercode' || ' ' || --加上印刷店的查询
                  ' left join (select Printshop.Printshopname,' ||
                  ' Printshop.Printshopcode,' ||
                  ' PrintshopSegment.Segmentcode' ||
                  ' from EAS_ExmM_Printshop@ouchnbase Printshop' ||
                  ' right join EAS_ExmM_PrintishopSegment@ouchnbase PrintshopSegment' ||
                  ' on Printshop.Printshopcode = PrintshopSegment.Printshopcode' ||
                  ' ) PrintshopNameTable' ||
                  ' on EEOrder.Orgcode = PrintshopNameTable.Segmentcode' ||
                  ' left join (select Printshop.Printshopname,' ||
                  ' Printshop.Printshopcode,' ||
                  ' PrintshopSegment.Segmentcode' ||
                  ' from EAS_ExmM_Printshop@ouchnbase Printshop' ||
                  ' right join EAS_ExmM_PrintishopSegment@ouchnbase PrintshopSegment' ||
                  ' on Printshop.Printshopcode = PrintshopSegment.Printshopcode' ||
                  ' ) PrintshopNameTable' ||
                  ' on EEOrder.Orgcode = PrintshopNameTable.Segmentcode' ||
                  ' left join (select Printshop.Printshopname,' ||
                  ' Printshop.Printshopcode,' ||
                  ' PrintshopSegment.Segmentcode' ||
                  ' from EAS_ExmM_Printshop@ouchnbase Printshop' ||
                  ' right join EAS_ExmM_PrintishopSegment@ouchnbase PrintshopSegment' ||
                  ' on Printshop.Printshopcode = PrintshopSegment.Printshopcode' ||
                  ' ) PrintshopNameTable' ||
                  ' on EEOrder.Orgcode = PrintshopNameTable.Segmentcode';

  EXECUTE IMMEDIATE v_sql_select;

  res := 1;
  exception
  when others then
    res := 0;
end pro_exam_signorder;

/

