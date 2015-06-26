--
-- PAGER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.Pager
is
procedure Pagination
(
inPageSize in integer, --每页记录数
inPageIndex in integer, --当前页数
inTableName in varchar2, --表名
inOutField in varchar2,--输出字段
inOrderField in varchar2,--排序字段
inIsOrderBy in varchar2,--排序类别，输入' desc' 或者' asc'
inWhere in varchar2,--查询条件
outRecordCount out int, --总记录数
outPageCount out int,
outCursor out curs --游标变量
)
is
v_sql varchar2(3000); --总的sql 语句
v_sql_count varchar2(3000); --总记录的sql 语句
v_sql_order varchar2(2000); --排序的sql 语句
v_outField varchar2(3000); --总的sql 语句
v_count int; -- --总记录数
v_endrownum int; --结束行
v_startrownum int; --开始行
begin
if inOrderField!='NO' then
v_sql_order :=' ORDER BY '|| inOrderField ||' '||inIsOrderBy;
else
v_sql_order :='';
end if;
if inWhere is not null then
v_sql_count:='SELECT COUNT(ROWNUM) FROM '||inTableName||' where '||inWhere;
else
v_sql_count:='SELECT COUNT(ROWNUM) FROM '||inTableName;
end if;

if inOutField is  null then
v_outField := inTableName||'.*';
else
v_outField :=inOutField;
end if;

execute immediate v_sql_count into v_count;
outRecordCount := v_count;
if mod(v_count,inPageSize)=0 then
outPageCount:= v_count/inPageSize;
else
outPageCount:= v_count/inPageSize+1;
end if;
v_startrownum:= 1+(inPageIndex-1)*inPageSize;
v_endrownum:= inPageIndex*inPageSize;

if inWhere is not null then
v_sql := 'SELECT * FROM (SELECT '||v_outField||', row_number() over ('||v_sql_order||')
num FROM '||inTableName||' WHERE '|| inWhere||'
) WHERE num between '||to_char(v_startrownum)||' and '||to_char(v_endrownum)||'';

else

v_sql := 'SELECT * FROM (SELECT '||v_outField||', row_number() over ('||v_sql_order||')
num FROM '||inTableName||'
) WHERE num between '||to_char(v_startrownum)||' and '||to_char(v_endrownum)||'';

end if;
dbms_output.put_line(v_sql);
open outCursor for v_sql;
end;
end;
/

