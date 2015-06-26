--
-- PRO_EXAM_TYPEORDER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pro_exam_typeorder(examplancode in varchar2,
                                               res          out number) is
  v_sql1_create varchar2(150) := 'insert into EAS_ExmM_TempTypeOrder ';
  v_sql_select  varchar2(3000);
  v_sql_in      varchar2(1000);

begin

  if instr(examplancode, ',') > 0 then
    --�����('','','')����
    v_sql_in := ' in (' || examplancode || ')'; --����where column in ('','','')
  else
    v_sql_in := ' =  ''' || examplancode || ''''; --�������where column = ''
  end if;

  EXECUTE IMMEDIATE 'truncate table EAS_ExmM_TempTypeOrder'; --��ձ�����

  v_sql_select := v_sql1_create || 'select EEOrder.examplancode,' || --���Լƻ�����
                  'EEOrder.examcategorycode,' || --�������
                  'CountAll.exampapercode,' || --�Ծ����
                  'EEOrder.ExamUnit,' || --���Ե�λ����
                  'SubjectPlan.exampapername,' || --�Ծ�����
                  'decode(EEOrder.orgtype, 2, EEOrder.orgcode) CollageCode,' || --ѧԺ����
                  'decode(EEOrder.orgtype, 1, EEOrder.orgcode) SegmentCode,' || --�ֲ�����
                  'PrintshopNameTable.Printshopname Printshopname,' || --ӡˢ�����
                  'CountAll.t1 T1,' || --T1
                  'CountAll.cou TCount ' || --���кϼ�
                  ' from (select CountLocal.*, CountLocal.t1 cou ' || --���кϼ�
                  ' from (select CountSum.sn,CountSum.exampapercode,' || --�Ծ����
                  ' sum(decode(TypeOrder.typenormcode, ''' || 't1' ||
                  ''', TypeOrder.totalorders+TypeOrder.ADJUSTMENT)) t1 ' || --T1
                  ' from EAS_ExmM_Order CountSum ' ||
                  ' inner join EAS_ExmM_TypeOrder TypeOrder ' ||
                  ' on CountSum.sn = TypeOrder.sn ' ||
                  ' where CountSum.OrderType=1 and CountSum.isReport=1 and CountSum.examplancode' || v_sql_in || --1:�������� 2��������
                  ' group by CountSum.sn,exampapercode) CountLocal) CountAll ' ||
                  ' inner join EAS_ExmM_Order EEOrder' ||
                  ' on CountAll.sn = EEOrder.sn' ||
                  ' inner join EAS_ExmM_ExamCoursePlanList@ouchnbase CoursePlanList' ||
                  ' on CoursePlanList.exampapercode = EEOrder.exampapercode' ||
                  '                                                          ' ||
                  ' inner join EAS_ExmM_SubjectPlan@ouchnbase SubjectPlan' ||
                  ' on CountAll.exampapercode = SubjectPlan.exampapercode' || ' ' || --����ӡˢ��Ĳ�ѯ
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
end pro_exam_typeorder;

/

