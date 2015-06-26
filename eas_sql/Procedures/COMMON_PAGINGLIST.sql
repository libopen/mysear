--
-- COMMON_PAGINGLIST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Common_PagingList(
 CurrentPage in number, --��ʼ��¼��  
 PageSize in number, --��¼��   
 SortExpression in varchar(1000) , --�����ֶ� 
 WhereExpression in varchar(1000) ,
 TableExpression in varchar(1000) ,
 TotalCount in number,
 paging_cursor out pagingPackage.paging_cursor) is
 v_sql varchar2(5000);
 v_begin number:=(pageNow-1)*pageSizes+1;
 v_end number:=pageNow*pageSizes;
 v_sqlcount varchar2(1000);
 begin 
 /*����ִ��Where Sort*/
 
 if WhereExpression is null then 
     v_sql := ' select *,rownum as RN from '||TableExpression||' where 1=1 '||WhereExpression;
     v_sqlcount := 'select count(*) from '||TableExpression||' where 1=1 '||WhereExpression; 
 end if;
 if SortExpression is null then
    v_sql :=v_sql||' order by ' ||SortExpression;
 
    v_sql := 'select * from ('||v_sql||') where RN>= '||v_begin ||' AND RN<'||v_end ;
 open paging_cursor for v_sql;
 
 execute immediate v_sql into TotalCount; 
 --close paging_cursor
 end if;
/

