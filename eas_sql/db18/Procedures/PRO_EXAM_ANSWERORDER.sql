--
-- PRO_EXAM_ANSWERORDER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pro_exam_answerorder(examplancode in varchar2,res out number) is
  v_sql1_create varchar2(150) := 'insert into EAS_EXMM_TEMPANSWERORDER ';
  v_sql_select  varchar2(3000);
  v_sql_in varchar2(1000);
begin
   if instr(examplancode, ',') > 0 then
    --�����('','','')����
    v_sql_in := ' in (' || examplancode || ')'; --����where column in ('','','')
  else
    v_sql_in := ' =  ''' || examplancode || ''''; --�������where column = ''
  end if;
  EXECUTE IMMEDIATE 'truncate table EAS_EXMM_TEMPANSWERORDER'; --��ձ�����
  v_sql_select := v_sql1_create || 'select EEOrder.examplancode,' || --���Լƻ�����
                  'EEOrder.examcategorycode,' || --�������
                  'CountAll.exampapercode,' || --�Ծ����
                  'EEOrder.ExamUnit,' || --���Ե�λ����
                  'SubjectPlan.exampapername,' || --�Ծ�����
                  'decode(EEOrder.orgtype, 2, EEOrder.orgcode) CollageCode,' || --ѧԺ����
                  'decode(EEOrder.orgtype, 1, EEOrder.orgcode) SegmentCode,' || --�ֲ�����
                  'PrintshopNameTable.Printshopname Printshopname,' ||
                  'CountAll.a10 A10,' || --a10
                  'CountAll.a5 A5,' || --a5
                  'CountAll.cou ACount ' || --���кϼ�
                  ' from (select CountLocal.*, CountLocal.a10 * (select e.num from EAS_ExmM_AnswerNorm e where e.ANSWERNORMCODE = '''||'a1'||''') + CountLocal.a5 * (select e.num from EAS_ExmM_AnswerNorm e where e.ANSWERNORMCODE = '''||'a2'||''') cou ' ||
                  ' from (select CountSum.sn,CountSum.exampapercode,' ||
                  'decode(sum(decode(AnswerOrder.answernormcode,' ||
                  '                  ''a1'',' ||
                  '                  AnswerOrder.TOTALORDERS + AnswerOrder.ADJUSTMENT)),' ||
                  '       '''',' ||
                  '       ''0'',' ||
                  '       sum(decode(AnswerOrder.answernormcode,' ||
                  '                  ''a1'',' ||
                  '                  AnswerOrder.TOTALORDERS + AnswerOrder.ADJUSTMENT))) a10,' ||
                  'decode(sum(decode(AnswerOrder.answernormcode,' ||
                  '                  ''a2'',' ||
                  '                  AnswerOrder.TOTALORDERS + AnswerOrder.ADJUSTMENT)),' ||
                  '       '''',' ||
                  '       ''0'',' ||
                  '       sum(decode(AnswerOrder.answernormcode,' ||
                  '                  ''a2'',' ||
                  '                  AnswerOrder.TOTALORDERS + AnswerOrder.ADJUSTMENT))) a5' ||
                  ' from EAS_ExmM_Order CountSum ' ||
                  ' inner join EAS_ExmM_AnswerOrder AnswerOrder' || ' on CountSum.sn = AnswerOrder.sn' ||
                  ' where CountSum.OrderType=1 and CountSum.isReport=1 and CountSum.examplancode' || v_sql_in ||--1:�������� 2��������
                  ' group by CountSum.sn,exampapercode) CountLocal) CountAll ' || --��������
                  ' inner join EAS_ExmM_Order EEOrder' || --�����ܱ�
                  ' on CountAll.sn = EEOrder.sn' ||
                  ' inner join EAS_ExmM_ExamCoursePlanList@ouchnbase CoursePlanList' ||
                  ' on CoursePlanList.exampapercode = EEOrder.exampapercode' ||
                  '                                                          ' ||
                  ' inner join EAS_ExmM_SubjectPlan@ouchnbase SubjectPlan' ||
                  ' on CountAll.exampapercode = SubjectPlan.exampapercode' ||
                  ' ' || --����ӡˢ��Ĳ�ѯ
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
end pro_exam_answerorder;

/

