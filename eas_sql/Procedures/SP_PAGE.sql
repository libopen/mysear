--
-- SP_PAGE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.sp_Page(p_PageSize int, --ÿҳ��¼��
p_PageNo int, --��ǰҳ��,�� 1 ��ʼ
p_SqlSelect varchar2, --��ѯ���,�����򲿷�
p_OutRecordCount out int,--�����ܼ�¼��
p_OutCursor out refCursorType)
as
v_sql varchar2(3000);
v_count int;
v_heiRownum int;
v_lowRownum int;
begin
----ȡ��¼����
v_sql := 'select count(*) from (' || p_SqlSelect || ')';
execute immediate v_sql into v_count;
p_OutRecordCount := v_count;
----ִ�з�ҳ��ѯ
v_heiRownum := p_PageNo * p_PageSize;
v_lowRownum := v_heiRownum - p_PageSize + 1;

v_sql := 'SELECT * 
FROM (
SELECT A.*, rownum rn 
FROM ('|| p_SqlSelect ||') A
WHERE rownum <= '|| to_char(v_heiRownum) || '
) B
WHERE rn >= ' || to_char(v_lowRownum) ;
--ע���rownum������ʹ��,��һ��ֱ����rownum,�ڶ���һ��Ҫ�ñ���rn

OPEN p_OutCursor FOR v_sql;

end sp_Page;
/

