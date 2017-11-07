merge into EAS_TCP_Guidance aa
using (select   g.tcpcode,
                (select RECRUITBATCHName from EAS_TCP_RECRUITBATCH where batchcode=g.batchcode)||
                (select dicname  from EAS_Dic_StudentType where diccode=g.studenttype )||
                (select dicname from EAS_Dic_ProfessionalLevel where diccode=g.professionallevel)||
                (select spyname||''||spydirection from EAS_Spy_BasicInfo where spycode=g.spycode) tcpnamenew
from EAS_TCP_Guidance g where batchcode='201709' ) bb on (aa.tcpcode=bb.tcpcode)
when  MATCHED THEN
update set aa.tcpname=bb.tcpnamenew,state=0;


commit;

--truncate table eas_tcp_guidanceonrule;

delete eas_tcp_guidanceonrule where tcpcode  in ('170901202010400','170901211020200','170901411020106','170901411020201') 


insert into eas_tcp_guidanceonrule(sn,batchcode,tcpcode,totalcredits,moduletotalcredits,requiredtotalcredits)
select seq_TCP_GuidOnRule.nextval,a.batchcode,a.tcpcode,a.totalcredits,a.moduletotalcredits,a.requiredtotalcredits from 
(select  batchcode,tcpcode,sum(case when examunittype=1 then credit else 0 end) totalcredits,sum(credit) moduletotalcredits,
sum(case when coursenature=1 then credit else 0 end) requiredtotalcredits  from eas_tcp_modulecourses  
where batchcode='201709' and tcpcode in ('170901202010400','170901211020200','170901411020106','170901411020201') 
group by batchcode,tcpcode) a;
commit;
/*
alter Sequence seq_TCP_GuidOnRule Increment by  -1000;

alter Sequence seq_TCP_GuidOnRule Increment by  1

select  seq_TCP_GuidOnRule.nextval from dual;
*/

--truncate table EAS_TCP_GuidanceOnModuleRule;
--insert into  EAS_TCP_GuidanceOnModuleRule(OnRuleID,batchcode,tcpcode,modulecode,totalcredits,requiredtotalcredits,CenterCompulsoryCourseCredit,SegmentCompulsoryCourseCredit)

delete EAS_TCP_GuidanceOnModuleRule where tcpcode  in ('170901202010400','170901211020200','170901411020106','170901411020201') 

insert into  EAS_TCP_GuidanceOnModuleRule(OnRuleID,batchcode,tcpcode,modulecode,totalcredits,requiredtotalcredits,CenterCompulsoryCourseCredit,SegmentCompulsoryCourseCredit)
select seq_TCP_GuidModuRule.nextval,a.batchcode,a.tcpcode,a.modulecode,a.totalcredits,a.requiredtotalcredits,a.CenterCompulsoryCourseCredit,a.SegmentCompulsoryCourseCredit from 
(select  batchcode,tcpcode, modulecode
,sum(credit) totalcredits
,sum(case when examunittype=1 then credit else 0 end) requiredtotalcredits
,sum(case when coursenature=1 then credit else 0 end) CenterCompulsoryCourseCredit
,sum(case when coursenature=2 then credit else 0 end) SegmentCompulsoryCourseCredit
  from eas_tcp_modulecourses  
  where batchcode='201709' and tcpcode in ('170901202010400','170901211020200','170901411020106','170901411020201') 
   group by batchcode,tcpcode,modulecode) a;


merge into EAS_TCP_GuidanceOnModuleRule a
using (select  a.batchcode,a.tcpcode,a.modulecode,0 totalcredits,0 requiredtotalcredits,0 CenterCompulsoryCourseCredit,0 SegmentCompulsoryCourseCredit from  eas_tcp_module a 
where  tcpcode in ('170901202010400','170901211020200','170901411020106','170901411020201') and not exists(select * from EAS_TCP_GuidanceOnModuleRule where tcpcode=a.tcpcode
and modulecode=a.modulecode)) b on (a.tcpcode=b.tcpcode and a.modulecode=b.modulecode)
  when not matched then
  insert (OnRuleID,batchcode,tcpcode,modulecode,totalcredits,requiredtotalcredits,CenterCompulsoryCourseCredit,SegmentCompulsoryCourseCredit)
    values( seq_TCP_GuidModuRule.nextval,b.batchcode,b.tcpcode,b.modulecode,b.totalcredits,b.requiredtotalcredits
  ,b.CenterCompulsoryCourseCredit,b.SegmentCompulsoryCourseCredit); 



  merge into eas_tcp_guidance a 
using(with t1 as (select sn,spycode from eas_tcp_easdegreerule)
,t2 as (select tcpcode,spycode,studenttype,professionallevel from eas_tcp_guidance where studenttype='01' and professionallevel='2') 
select t2.*,t1.sn as easdegsn from t1 inner join t2 on t1.spycode=t2.spycode ) b on (a.tcpcode=b.tcpcode)
when matched then
update set  easdegsn=b.easdegsn
where a.batchcode='201709'  ;
  commit;
  
  
  
 