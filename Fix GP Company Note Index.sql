/* 
** FindMaxNoteIndex.SQL 
** 
** Purpose: 
** 
** Find the max value of NOTEINDX from all tables including Project Accounting. 
** 
** This script must be run against the company in which the notes are incorrect. 
** it will automatically update your SY01500 for you to the correct next note index. 
** 
*/ 

if exists (select * from tempdb..sysobjects where name = '##GPSMaxNote')

drop table dbo.##GPSMaxNote

set nocount on

create table ##GPSMaxNote (MaxNoteIndex numeric(19,5) null)

go

-----------------------

declare @cStatement varchar(255) /* Value from the t_cursor */

declare @noteidx numeric(19,5)

declare @database as varchar(5)

set @database = cast(db_name() as varchar(5))


/* Get the tables that have a column name of NOTEINDX. */

declare T_cursor cursor for

select 'declare @NoteIndex numeric(19,5) select @NoteIndex = max(' +c.name+ ') from ' + o.name + ' insert ##GPSMaxNote values(@NoteIndex)' 

from sysobjects o, syscolumns c

where o.id = c.id

and o.type = 'U'

and (c.name = 'NOTEINDX' or c.name like '%noteidx%' or c.name like '%niteidx%' or c.name ='NOTEINDX2')


/* Ok, we have the list of tables. Now get the max value of NOTEINDX from each table. */

open T_cursor

fetch next from T_cursor into @cStatement

while (@@fetch_status <> -1)

begin

exec (@cStatement)

fetch next from T_cursor into @cStatement

end

deallocate T_cursor


/* Display Maximum Note Index */

select 'Max Note Index:', max(MaxNoteIndex) from ##GPSMaxNote where MaxNoteIndex is not null


/* Update Next Note Index */

use DYNAMICS

set @noteidx = (select max(MaxNoteIndex) from ##GPSMaxNote where MaxNoteIndex is not null)

update SY01500 set NOTEINDX = (@noteidx + 1.0) where INTERID=@database 

set nocount off

