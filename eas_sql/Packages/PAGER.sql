--
-- PAGER  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.Pager
is
type curs is ref cursor;
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
);
end;
/

