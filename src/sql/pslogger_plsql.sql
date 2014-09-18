set echo on
set time on
set scan off
set pagesize 500
set linesize 132

spool pslogger_plsql.log

ROLLBACK
/

WHENEVER OSERROR EXIT SQL.OSCODE
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/* Sequences */
/* Logger2 Line Nbr */
CREATE SEQUENCE logger2_seq
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE
/

/* Logger2 SessionID */
CREATE SEQUENCE logger2_session_seq
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE
/

/* LOGGER2 */

DROP TABLE PS_GENRICLOG2
/

CREATE TABLE PS_GENRICLOG2 (
   LOGMSGSRC VARCHAR2(254) NOT NULL,
   GROUPNAME VARCHAR2(254) NOT NULL,
   GROUPNAME2 VARCHAR2(254) NOT NULL,
   DTTM_STAMP TIMESTAMP,
   SEQUENCENO INTEGER NOT NULL,
   OPRID VARCHAR2(30) NOT NULL,
   GUID VARCHAR2(36) NOT NULL,
   SESSIONID VARCHAR2(9) NOT NULL,
   LOGLINELONG VARCHAR2(4000)) 
PCTFREE 10 PCTUSED 80 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 81920 NEXT 114688 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "SAAPP" 
/

CREATE UNIQUE INDEX PS_GENRICLOG2 ON PS_GENRICLOG2
 (LOGMSGSRC,
   DTTM_STAMP,
   SEQUENCENO)
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 81920 NEXT 114688 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "PSINDEX" 
/

ALTER INDEX PS_GENRICLOG2 NOPARALLEL LOGGING
/

CREATE OR REPLACE PACKAGE SYSADM.GENRICLOG2 AS -- spec
   Procedure resetSequenceNbr;
   Function createSession RETURN Number;
   Procedure writeLogLine(msgsrc in varchar2, groupname in varchar2, subgroupname in varchar2, operatorid in varchar2, transactionid in varchar2, logline in varchar2, sessionid in number default 0);
   Function getSessionId RETURN Number;
END;
/

CREATE OR REPLACE PACKAGE BODY SYSADM.GENRICLOG2 AS -- body

   Procedure writeLogLine(msgsrc in varchar2, groupname in varchar2, subgroupname in varchar2, operatorid in varchar2, transactionid in varchar2, logline in varchar2, sessionid in number default 0) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      insert into PS_GENRICLOG2(LOGMSGSRC,GROUPNAME, GROUPNAME2, DTTM_STAMP, SEQUENCENO, OPRID,GUID,SESSIONID,LOGLINELONG)
         values(msgsrc, groupname, subgroupname, SYSTIMESTAMP, logger2_seq.nextval, operatorid, transactionid, sessionid , logline);
      commit;
   END;

/*
src: http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:951269671592
*/
Procedure resetSequenceNbr
IS
      l_val number;
BEGIN
      /* reset logger line no sequence */
      EXECUTE IMMEDIATE 'select  logger2_seq.nextval from dual ' INTO l_val;
      EXECUTE IMMEDIATE 'alter sequence logger2_seq increment by ' || -1 * l_val  || 'minvalue 0';
      EXECUTE IMMEDIATE 'select  logger2_seq.nextval from dual' INTO l_val;
      EXECUTE IMMEDIATE 'alter sequence logger2_seq increment by 1 minvalue 0';
      /* reset sessionid sequence */
      EXECUTE IMMEDIATE 'select  logger2_session_seq.nextval from dual ' INTO l_val;
      EXECUTE IMMEDIATE 'alter sequence logger2_session_seq increment by ' || -1 * l_val  || 'minvalue 0';
      EXECUTE IMMEDIATE 'select  logger2_session_seq.nextval from dual' INTO l_val;
      EXECUTE IMMEDIATE 'alter sequence logger2_session_seq increment by 1 minvalue 0';
END;

Function createSession RETURN Number
IS
      l_val number;
BEGIN
      EXECUTE IMMEDIATE 'select  logger2_session_seq.nextval from dual ' INTO l_val;
      return l_val;
END;

Function getSessionId return number
IS
   l_val number;
BEGIN
         EXECUTE IMMEDIATE 'select last_number from USER_SEQUENCES where sequence_name = ''LOGGER2_SESSION_SEQ''' INTO l_val;
         return l_val;
END;

End;
/

spool off 

exit
