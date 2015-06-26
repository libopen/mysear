--
-- PR_GETPAGER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pr_GetPager(
pageNo in number,--����ҳ������1��ʼ
pageSize in number,--ÿҳ��С
tableName nvarchar2,--����
whereSQL nvarchar2,--where����
orderBY nvarchar2,
totalCount out number,--�ܼ�¼��
v_cur out pkg_query.cur_query) is

strSql varchar2(2000);--��ȡ���ݵ�sql���
pageCount number;--�������¼�¼ҳ��
startIndex number;--��ʼ��¼
endIndex number;--������¼

begin
  strSql:='select count(1) from '||tableName;
  if whereSQL is not null or whereSQL<>'' then 
     strSql:=strSql||' where '||whereSQL;
  end if;  
  EXECUTE IMMEDIATE strSql INTO totalCount;
  --�������ݼ�¼��ʼ�ͽ���
  pageCount:=totalCount/pageSize+1;
  startIndex:=(pageNo-1)*pageSize+1;
  endIndex:=pageNo*pageSize;
  
  strSql:='select rownum ro, t.* from '||tableName||' t';  
  strSql:=strSql||' where rownum<='||endIndex;
  
  if whereSQL is not null or whereSQL<>'' then 
     strSql:=strSql||' and '||whereSQL;
  end if;
  
  if  orderBY is not null or orderBY<>'' then 
     strSql:=strSql||' order by '||orderBY;
  end if;
  
  strSql:='select * from ('||strSql||') where ro >='||startIndex;  
  DBMS_OUTPUT.put_line(strSql);

  OPEN v_cur FOR strSql; 
end pr_GetPager; 
/

