/* ClearCompanys.sql - Script that will clear out all entrys in the DYNAMICS 
   database referencing databases that no longer exist on the SQL Server.

   Requirements: 
   Company database you wish to have cleaned out of the tables in the DYNAMICS 
   database must be removed from the SQL server before running this script.  
   Ensure that all your databases have been restored or they will be erased 
   from the DYNAMICS database.
*/

set nocount on

/* Remove all references in the company master (SY01500) for databases that
   Do not exist on the SQL Server */
delete DYNAMICS..SY01500 where INTERID not in
            (select name from master..sysdatabases)

/* Clear out all tables in DYNAMICS database that have a CMPANYID field 
   that no longer matches any Company ID's in the SY01500 */
USE DYNAMICS
declare @CMPANYID char(150)
declare CMPANYID_Cleanup CURSOR for 
select 'delete ' + o.name + ' where CMPANYID not in (0,-32767)'
+ ' and CMPANYID not in (select CMPANYID from DYNAMICS..SY01500)' 
	 from sysobjects o, syscolumns c
		where	o.id = c.id
		    and o.type = 'U'
		    and c.name = 'CMPANYID'
		    and o.name <> 'SY01500' order by o.name

OPEN CMPANYID_Cleanup
FETCH NEXT from CMPANYID_Cleanup into @CMPANYID

while (@@FETCH_STATUS <>-1)
begin

	exec (@CMPANYID)
	FETCH NEXT from CMPANYID_Cleanup into @CMPANYID

end

DEALLOCATE CMPANYID_Cleanup
go

/* Clear out all tables in DYNAMICS database that have a companyID field 
   that no longer matches any Company ID's in the SY01500 */
USE DYNAMICS
declare @companyID char(150)
declare companyID_Cleanup CURSOR for 
select 'delete ' + o.name + ' where companyID not in (0,-32767)'
+ ' and companyID not in (select CMPANYID from DYNAMICS..SY01500)' 
	 from sysobjects o, syscolumns c
		where	o.id = c.id
		    and o.type = 'U'
		    and c.name = 'companyID'
		    and o.name <> 'SY01500'
set nocount on
OPEN companyID_Cleanup
FETCH NEXT from companyID_Cleanup into @companyID
while (@@FETCH_STATUS <>-1)
begin

	exec (@companyID)
	FETCH NEXT from companyID_Cleanup into @companyID

end

DEALLOCATE companyID_Cleanup
go

/* Clear out all tables in DYNAMICS database that have a db_name field 
   that no longer matches any company names (INTERID) in the SY01500 */
USE DYNAMICS
declare @db_name char(150)
declare db_name_Cleanup CURSOR for 
select 'delete ' + o.name + ' where db_name <> ''DYNAMICS'' and db_name <> ''''
 and db_name not in (select INTERID from DYNAMICS..SY01500)' 
	 from sysobjects o, syscolumns c
		where	o.id = c.id
		    and o.type = 'U'
		    and c.name = 'db_name'

set nocount on
OPEN db_name_Cleanup
FETCH NEXT from db_name_Cleanup into @db_name

while (@@FETCH_STATUS <>-1)
begin

	exec (@db_name)
	FETCH NEXT from db_name_Cleanup into @db_name

end

DEALLOCATE db_name_Cleanup
GO
set nocount on

/* Clear out all tables in DYNAMICS database that have a dbname field 
   that no longer matches any company names (INTERID) in the SY01500 */
USE DYNAMICS
declare @dbname char(150)
declare dbname_Cleanup CURSOR for 
select 'delete ' + o.name + ' where DBNAME <> ''DYNAMICS'' and DBNAME <> ''''
 and DBNAME not in (select INTERID from DYNAMICS..SY01500)' 
	 from sysobjects o, syscolumns c
		where	o.id = c.id
		    and o.type = 'U'
		    and c.name = 'DBNAME'

set nocount on
OPEN dbname_Cleanup
FETCH NEXT from dbname_Cleanup into @dbname

while (@@FETCH_STATUS <>-1)
begin

	exec (@dbname)
	FETCH NEXT from dbname_Cleanup into @dbname

end

DEALLOCATE dbname_Cleanup
GO
set nocount on

/* Remove all stranded references from the other Business Alerts table that 
   no longer exist in the SY40500 */
delete SY40502 where BARULEID NOT IN (SELECT BARULEID FROM SY40500)
delete SY40503 where BARULEID NOT IN (SELECT BARULEID FROM SY40500)
delete SY40504 where BARULEID NOT IN (SELECT BARULEID FROM SY40500)
delete SY40505 where BARULEID NOT IN (SELECT BARULEID FROM SY40500)
delete SY40506 where BARULEID NOT IN (SELECT BARULEID FROM SY40500)
GO