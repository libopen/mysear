-- SQL Loader Control and Data File created by TOAD
-- Variable length, terminated enclosed data formatting
-- 
-- The format for executing this file with SQL Loader is:
-- SQLLDR control=<filename> Be sure to substitute your
-- version of SQL LOADER and the filename for this file.
--
-- Note: Nested table datatypes are not supported here and
--       will be exported as nulls.
LOAD DATA
INFILE *
BADFILE './OUCHNSYS.EAS_DIC_EDUCOMMSPEC.BAD'
DISCARDFILE './OUCHNSYS.EAS_DIC_EDUCOMMSPEC.DSC'
REPLACE INTO TABLE EAS_DIC_EDUCOMMSPEC
Fields terminated by ',' 
trailing nullcols
(
  
  DICNAME,
  diccode,
  GROUPID,
  scope,
  subjectcode
)
BEGINDATA
