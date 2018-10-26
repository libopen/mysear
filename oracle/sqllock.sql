select sess.serial#, sess.sid,lo.oracle_username,lo.locked_mode, ao.object_name,os_user_name from v$locked_object lo,dba_objects ao,v$session sess where ao.object_id=lo.object_id and lo.session_id=sess.sid;

