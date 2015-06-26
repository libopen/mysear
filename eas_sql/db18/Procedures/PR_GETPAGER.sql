--
-- PR_GETPAGER  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.pr_GetPager(
pageNo in number,--数据页数，从1开始
pageSize in number,--每页大小
tableName nvarchar2,--表名
whereSQL nvarchar2,--where条件
orderBY nvarchar2,
totalCount out number,--总记录数
v_cur out pkg_query.cur_query) is

strSql varchar2(2000);--获取数据的sql语句
pageCount number;--该条件下记录页数
startIndex number;--开始记录
endIndex number;--结束记录

begin
  strSql:='select count(1) from '||tableName;
  if whereSQL is not null or whereSQL<>'' then 
     strSql:=strSql||' where '||whereSQL;
  end if;  
  EXECUTE IMMEDIATE strSql INTO totalCount;
  --计算数据记录开始和结束
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

