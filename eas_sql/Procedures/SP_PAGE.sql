--
-- SP_PAGE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.sp_Page(p_PageSize int, --每页记录数
p_PageNo int, --当前页码,从 1 开始
p_SqlSelect varchar2, --查询语句,含排序部分
p_OutRecordCount out int,--返回总记录数
p_OutCursor out refCursorType)
as
v_sql varchar2(3000);
v_count int;
v_heiRownum int;
v_lowRownum int;
begin
----取记录总数
v_sql := 'select count(*) from (' || p_SqlSelect || ')';
execute immediate v_sql into v_count;
p_OutRecordCount := v_count;
----执行分页查询
v_heiRownum := p_PageNo * p_PageSize;
v_lowRownum := v_heiRownum - p_PageSize + 1;

v_sql := 'SELECT * 
FROM (
SELECT A.*, rownum rn 
FROM ('|| p_SqlSelect ||') A
WHERE rownum <= '|| to_char(v_heiRownum) || '
) B
WHERE rn >= ' || to_char(v_lowRownum) ;
--注意对rownum别名的使用,第一次直接用rownum,第二次一定要用别名rn

OPEN p_OutCursor FOR v_sql;

end sp_Page;
/

