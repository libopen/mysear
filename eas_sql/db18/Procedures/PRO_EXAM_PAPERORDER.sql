--
-- PRO_EXAM_PAPERORDER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pro_exam_paperorder(examplancode in varchar2,res out number --1Ϊ�ɹ���0Ϊʧ��
                                           ) is
  v_sql1_create varchar2(150) := 'insert into EAS_ExmM_TempPaperOrder ';
  v_sql_select  varchar2(10000);
  v_sql_in      varchar2(1000);

begin

  if instr(examplancode, ',') > 0 then
    --�����('','','')����
    v_sql_in := ' in (' || examplancode || ')'; --����where column in ('','','')
  else
    v_sql_in := ' =  ''' || examplancode || ''''; --�������where column = ''
  end if;

  EXECUTE IMMEDIATE 'truncate table EAS_ExmM_TempPaperOrder';        --�������


  v_sql_select := v_sql1_create ||
                  ' select distinct EEOrder.examplancode ExamPlanCode,' ||
                  ' EEOrder.examcategorycode,' || --�������
                  ' CountAll.exampapercode,' || --�Ծ����
                  ' EEOrder.ExamUnit,' || --���Ե�λ����
                  ' SubjectPlan.exampapername,' || --�Ծ�����
                  ' decode(EEOrder.orgtype, 2, EEOrder.orgcode) CollageCode,' || --ѧԺ����
                  ' decode(EEOrder.orgtype, 1, EEOrder.orgcode) SegmentCode,' || --�ֲ�����
                  ' PrintshopNameTable.Printshopname Printshopname,' ||
                  ' CountAll.e1            D31,' || ' CountAll.e2            D26,' ||
                  ' CountAll.e3            D11,' || ' CountAll.e4            D5,' ||
                  ' CountAll.cou           DCount' || ' from (select CountLocal.*,' ||
                  ' CountLocal.e1 * (select e.num' ||
                  ' from EAS_ExmM_PaperOrderNorm e' ||
                  ' where e.PaperNormCode = ''e1'') +' ||
                  ' CountLocal.e2 * (select e.num' ||
                  ' from EAS_ExmM_PaperOrderNorm e' ||
                  ' where e.PaperNormCode = ''e2'') +' ||
                  ' CountLocal.e3 * (select e.num' ||
                  ' from EAS_ExmM_PaperOrderNorm e' ||
                  ' where e.PaperNormCode = ''e3'') +' ||
                  ' CountLocal.e4 * (select e.num' ||
                  ' from EAS_ExmM_PaperOrderNorm e' ||
                  ' where e.PaperNormCode = ''e4'') cou' ||
                  ' from (select CountSum.sn,' || ' CountSum.exampapercode,' ||
                  ' decode(sum(decode(PaperOrder.PAPERSTANDARDCODE,' || ' ''e1'',' ||
                  ' PaperOrder.TOTALORDERS + PaperOrder.adjustment)),' || ' '''',' ||
                  ' ''0'',' || ' sum(decode(PaperOrder.PAPERSTANDARDCODE,' ||
                  ' ''e1'',' || ' PaperOrder.TOTALORDERS + PaperOrder.adjustment))) e1,' ||
                  ' decode(sum(decode(PaperOrder.PAPERSTANDARDCODE,' || ' ''e2'',' ||
                  ' PaperOrder.TOTALORDERS + PaperOrder.adjustment)),' || ' '''',' ||
                  ' ''0'',' || ' sum(decode(PaperOrder.PAPERSTANDARDCODE,' ||
                  ' ''e2'',' || ' PaperOrder.TOTALORDERS + PaperOrder.adjustment))) e2,' ||
                  ' decode(sum(decode(PaperOrder.PAPERSTANDARDCODE,' || ' ''e3'',' ||
                  ' PaperOrder.TOTALORDERS + PaperOrder.adjustment)),' || ' '''',' ||
                  ' ''0'',' || ' sum(decode(PaperOrder.PAPERSTANDARDCODE,' ||
                  ' ''e3'',' || ' PaperOrder.TOTALORDERS + PaperOrder.adjustment))) e3,' ||
                  ' decode(sum(decode(PaperOrder.PAPERSTANDARDCODE,' || ' ''e4'',' ||
                  ' PaperOrder.TOTALORDERS + PaperOrder.adjustment)),' || ' '''',' ||
                  ' ''0'',' || ' sum(decode(PaperOrder.PAPERSTANDARDCODE,' ||
                  ' ''e4'',' || ' PaperOrder.TOTALORDERS + PaperOrder.adjustment))) e4' ||
                  ' from EAS_ExmM_Order CountSum' ||
                  ' join EAS_EXMM_PAPERORDER PaperOrder' || ' on CountSum.sn = PaperOrder.sn' ||
                  ' where CountSum.OrderType=1 and CountSum.isReport=1 and CountSum.examplancode' || v_sql_in ||
                  ' group by CountSum.sn, CountSum.exampapercode) CountLocal) CountAll' ||--ͳ�ƿ��Ծ����

                  ' inner join EAS_ExmM_Order EEOrder' ||
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
                  ' on EEOrder.Orgcode = PrintshopNameTable.Segmentcode';

  EXECUTE IMMEDIATE v_sql_select;

  res := 1;
  exception
  when others then
    res := 0;

end pro_exam_paperorder;

/

