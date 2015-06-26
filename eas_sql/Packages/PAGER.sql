--
-- PAGER  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.Pager
is
type curs is ref cursor;
procedure Pagination
(
inPageSize in integer, --ÿҳ��¼��
inPageIndex in integer, --��ǰҳ��
inTableName in varchar2, --����
inOutField in varchar2,--����ֶ�
inOrderField in varchar2,--�����ֶ�
inIsOrderBy in varchar2,--�����������' desc' ����' asc'
inWhere in varchar2,--��ѯ����
outRecordCount out int, --�ܼ�¼��
outPageCount out int,
outCursor out curs --�α����
);
end;
/

