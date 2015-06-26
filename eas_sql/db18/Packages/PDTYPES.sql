--
-- PDTYPES  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PDTypes
as
    TYPE ref_cursor IS REF CURSOR;
end;
-- Integrity package declaration
create or replace package IntegrityPackage AS
 procedure InitNestLevel;
 function GetNestLevel return number;
 procedure NextNestLevel;
 procedure PreviousNestLevel;
 end IntegrityPackage;
/

