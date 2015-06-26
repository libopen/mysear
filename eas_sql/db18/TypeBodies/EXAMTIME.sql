--
-- EXAMTIME  (Type Body) 
--
CREATE OR REPLACE TYPE BODY OUCHNSYS.EXAMTIME AS 
member function GetExamDatelist(i_Operate IN number) return arrExamDate as
 vExamDate_array arrExamDate := arrExamDate();
 v_count number;
 BEGIN
  vExamDate_array.Delete;
   if i_Operate=1 then -- 初始化
          dbms_output.put_line('初始化开始');
             for i in 1..NEWENDDATE-NEWBEGINDATE+1
             loop
              vExamDate_array.extend;
               vExamDate_array(i):= NEWBEGINDATE+i-1;
             end loop;
     else    --增加初始化v_iOperateType=2
          dbms_output.put_line('增量初始化开始');
               ----判断 延长的时间不能在原时间范围内
              if (NEWBEGINDATE>EXISTBEGINDATE and NEWBEGINDATE<EXISTENDDATE) or (NEWENDDATE>EXISTBEGINDATE and NEWENDDATE<EXISTENDDATE ) then
                 
                  dbms_output.put_line('错误设置：新开始时间在原时间范围内，或新结束时间在原时间范围内。新时间：'||NEWBEGINDATE||'~~'||NEWENDDATE||'~原时间~'||EXISTBEGINDATE||'~~'||EXISTENDDATE);
              else   -- 设置新时间段考试时间
                 if NEWBEGINDATE>EXISTENDDATE or NEWENDDATE<EXISTBEGINDATE then
                      for i in 1..NEWENDDATE-NEWBEGINDATE+1
                      loop
                       vExamDate_array.extend;
                         vExamDate_array(i):=NEWBEGINDATE+i-1;
                      end loop;
                   
                else
                 if NEWBEGINDATE<EXISTBEGINDATE then  ---新开始时间在原开始时间之前
                     for i in 1..EXISTBEGINDATE-NEWBEGINDATE --时间向前延长
                     loop
                      vExamDate_array.extend;
                      vExamDate_array(i):=NEWBEGINDATE+i-1;
                     end loop;
                 end if ;
                 v_count := vExamDate_array.count; -- 前一段开数
                 if NEWENDDATE>EXISTENDDATE then           --时间后延
                    for j in 1..NEWENDDATE-EXISTENDDATE        --时间延后
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

