--
-- EXAMTIME  (Type Body) 
--
CREATE OR REPLACE TYPE BODY OUCHNSYS.EXAMTIME AS 
member function GetExamDatelist(i_Operate IN number) return arrExamDate as
 vExamDate_array arrExamDate := arrExamDate();
 v_count number;
 BEGIN
  vExamDate_array.Delete;
   if i_Operate=1 then -- ��ʼ��
          dbms_output.put_line('��ʼ����ʼ');
             for i in 1..NEWENDDATE-NEWBEGINDATE+1
             loop
              vExamDate_array.extend;
               vExamDate_array(i):= NEWBEGINDATE+i-1;
             end loop;
     else    --���ӳ�ʼ��v_iOperateType=2
          dbms_output.put_line('������ʼ����ʼ');
               ----�ж� �ӳ���ʱ�䲻����ԭʱ�䷶Χ��
              if (NEWBEGINDATE>EXISTBEGINDATE and NEWBEGINDATE<EXISTENDDATE) or (NEWENDDATE>EXISTBEGINDATE and NEWENDDATE<EXISTENDDATE ) then
                 
                  dbms_output.put_line('�������ã��¿�ʼʱ����ԭʱ�䷶Χ�ڣ����½���ʱ����ԭʱ�䷶Χ�ڡ���ʱ�䣺'||NEWBEGINDATE||'~~'||NEWENDDATE||'~ԭʱ��~'||EXISTBEGINDATE||'~~'||EXISTENDDATE);
              else   -- ������ʱ��ο���ʱ��
                 if NEWBEGINDATE>EXISTENDDATE or NEWENDDATE<EXISTBEGINDATE then
                      for i in 1..NEWENDDATE-NEWBEGINDATE+1
                      loop
                       vExamDate_array.extend;
                         vExamDate_array(i):=NEWBEGINDATE+i-1;
                      end loop;
                   
                else
                 if NEWBEGINDATE<EXISTBEGINDATE then  ---�¿�ʼʱ����ԭ��ʼʱ��֮ǰ
                     for i in 1..EXISTBEGINDATE-NEWBEGINDATE --ʱ����ǰ�ӳ�
                     loop
                      vExamDate_array.extend;
                      vExamDate_array(i):=NEWBEGINDATE+i-1;
                     end loop;
                 end if ;
                 v_count := vExamDate_array.count; -- ǰһ�ο���
                 if NEWENDDATE>EXISTENDDATE then           --ʱ�����
                    for j in 1..NEWENDDATE-EXISTENDDATE        --ʱ���Ӻ�
                     loop
                      vExamDate_array.extend;
                      vExamDate_array(v_count+j):=EXISTENDDATE+j;
                      end loop;
                  end if;
                end if;
              end if;
     
     end if;
     
    return vExamDate_array;

END ;
End;
/

