Select s.SID,
       s.username,
       s.program,
       s.status,
       sw.EVENT, 
       sw.STATE,
       case when sw.STATE = 'WAITING' then '正在等待...' 
            when sw.state = 'WAITED UNKNOWN TIME' then '等待完成, 但时间很短'
            when sw.state = 'WAITED SHORT TIME' THEN '等待完成, 但时间更短'
            when sw.state = 'WAITED KNOWN TIME' then '等待完成,等待时间(单位10ms)'||sw.wait_time end state_memo,
       case when sw.STATE = 'WAITING' then sw.SECONDS_IN_WAIT else 0 end seconds_in_wait,
       sw.WAIT_TIME,
       case when sw.WAIT_TIME = -1 then '等待完成, 最后一次等待时间小于10ms...' 
            when sw.WAIT_TIME = -2 then '等待完成, 统计时间未置为可用'
            when sw.WAIT_TIME > 0 then '等待完成, 最后一次等待时间(单位10ms)'||sw.WAIT_TIME
            when sw.WAIT_TIME = 0 then '正在等待' end wait_time_memo,
       st.PIECE,
       st.SQL_TEXT,
       sw.P1TEXT,sw.p1, sw.P2TEXT,sw.p2, sw.P3TEXT, sw.P3
  from v$session s, v$session_wait sw, v$sqltext st
 Where s.sid = sw.sid
   and s.sql_address = st.address(+)
   And sw.event not like 'SQl*Net%'
   And s.status = 'ACTIVE'
   And s.username is not null
 order by sw.state,s.sid,st.PIECE;