/*Revised June 2014 to work with SmartList Designer*/
/*This script is supported with Microsoft Dynamics GP 10.0, 2010, 2015 and 2016*/

/* Remove all references in the company master (SY01500)
   for databases that do not exist on the SQL Server */
set nocount on
use master

declare @dbNames char(5), @GPSystem char(15), @Statement char(3400)
create table ##GPSystem (GPSystem char(15))

declare FindGPSystem cursor for
  select name from sysdatabases where len(name) <= 5 and name not in ('model','msdb') order by name
open FindGPSystem
fetch next from FindGPSystem into @dbNames
while (@@fetch_status <> -1) begin
  set @Statement = 'if exists (select 1 from ' + rtrim(@dbNames) + '..sysobjects
    where type = ''U'' and name = ''SY00100'') 
    insert into ##GPSystem (GPSystem)
    select DBNAME from ' + rtrim(@dbNames) + '..SY00100'
  exec (@Statement)
  fetch next from FindGPSystem into @dbNames
end
close FindGPSystem
deallocate FindGPSystem

if not exists (select 1 from ##GPSystem)
  insert into ##GPSystem (GPSystem) select 'DYNAMICS'
delete from ##GPSystem where GPSystem not in (select name from sysdatabases)

declare CleanGPSystem cursor for
  select GPSystem from ##GPSystem order by GPSystem
open CleanGPSystem
fetch next from CleanGPSystem into @GPSystem
while (@@fetch_status <> -1) begin
  set @Statement = 'use ' + rtrim(@GPSystem) + '
declare @statement char(150)
delete SY01500 where INTERID not in (select name from master..sysdatabases)

declare CMPANYID_Cleanup CURSOR for 
  select ''delete '' + o.name + '' where CMPANYID not in (0,-32767)
    and CMPANYID not in (select CMPANYID from SY01500)''
  from sysobjects o join syscolumns c on o.id = c.id and o.type = ''U''
  where c.name = ''CMPANYID'' and o.name <> ''SY01500''
  and o.name <> ''ADH00100''
  order by o.name
open CMPANYID_Cleanup
fetch next from CMPANYID_Cleanup into @statement
while (@@fetch_status <> -1) begin
  exec (@statement)
  fetch next from CMPANYID_Cleanup into @statement
end
close CMPANYID_Cleanup
deallocate CMPANYID_Cleanup

declare companyID_Cleanup1 CURSOR for 
  select ''delete '' + rtrim(o.name) + '' where companyID not in (0,-32767)
    and companyID not in (select CMPANYID from SY01500)'' 
  from sysobjects o join syscolumns c on o.id = c.id and o.type = ''U''
  where c.name = ''companyID'' and o.name <> ''SY01500'' and o.name <> ''syDeployedReports''
  order by o.name
open companyID_Cleanup1
fetch next from companyID_Cleanup1 into @statement
while (@@fetch_status <> -1) begin
  exec (@statement)
  fetch next from companyID_Cleanup1 into @statement
end
close companyID_Cleanup1
deallocate companyID_Cleanup1

declare companyID_Cleanup2 CURSOR for 
  select ''delete '' + rtrim(o.name) + '' where companyID <> ''''' + rtrim(@GPSystem) + '''''
    and companyID <>'''''''' and companyID not in (select INTERID from SY01500)'' 
  from sysobjects o join syscolumns c on o.id = c.id and o.type = ''U''
  where c.name = ''companyID'' and o.name <> ''SY01500'' and o.name = ''syDeployedReports''
  order by o.name
open companyID_Cleanup2
fetch next from companyID_Cleanup2 into @statement
while (@@fetch_status <> -1) begin
  exec (@statement)
  fetch next from companyID_Cleanup2 into @statement
end
close companyID_Cleanup2
deallocate companyID_Cleanup2

declare db_name_Cleanup CURSOR for 
  select ''delete '' + rtrim(o.name) + '' where db_name <> ''''' + rtrim(@GPSystem) + '''''
    and db_name <> '''''''' and db_name not in (select INTERID from SY01500)'' 
  from sysobjects o join syscolumns c on o.id = c.id and o.type = ''U''
  where c.name = ''db_name''
  order by o.name
open db_name_Cleanup
fetch next from db_name_Cleanup into @statement
while (@@fetch_status <> -1) begin
  exec (@statement)
  fetch next from db_name_Cleanup into @statement
end
close db_name_Cleanup
deallocate db_name_Cleanup

declare dbname_Cleanup CURSOR for 
  select ''delete '' + rtrim(o.name) + '' where DBNAME <> ''''' + rtrim(@GPSystem) + '''''
    and DBNAME <> '''''''' and DBNAME not in (select INTERID from SY01500)'' 
  from sysobjects o join syscolumns c on o.id = c.id and o.type = ''U''
  where c.name = ''DBNAME'' and o.name not in (''SLB10100'',''ERB10100'',''NLB10100'')
  order by o.name
open dbname_Cleanup
fetch next from dbname_Cleanup into @statement
while (@@fetch_status <> -1) begin
  exec (@statement)
  fetch next from dbname_Cleanup into @statement
end
close dbname_Cleanup
deallocate dbname_Cleanup

delete SY40502 where BARULEID not in (select BARULEID from SY40500)
delete SY40503 where BARULEID not in (select BARULEID from SY40500)
delete SY40504 where BARULEID not in (select BARULEID from SY40500)
delete SY40505 where BARULEID not in (select BARULEID from SY40500)
delete SY40506 where BARULEID not in (select BARULEID from SY40500)'
  exec (@Statement)
  fetch next from CleanGPSystem into @GPSystem
end
close CleanGPSystem
deallocate CleanGPSystem

drop table ##GPSystem
set nocount off
go
