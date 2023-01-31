/*
** Procedure Name:  PM_Find_Dups.sql
**
** Description:
**
**	Looks for many different kinds of duplicates many that may cause PM00400 (PMKeys Table)
**	to error out.  Once Duplicates are found they will need to be dealt with on a one by 
**	one basis.  Run in TEXT Mode (CTRL - T)
**
** Database:	Company
**
** Versions:	7.00, 6.00, 5.50, 5.51, 5.00
** SQL Version:	2000, 7.0
** 
** Tables:
**
** 	SQL Table			Access Method
** 	---------------------		-------------
**	PM10000				Read
**	PM10100				Read
** 	PM10300				Read
**	PM10400				Read
**	PM20000				Read
**	PM30200				Read
**	PM30600				Read
**	Various Temp Tables		##Temp**
**               
** Revision History:
**
**       Date           Who			Comments
**       ------------   --------------------	------------------------------------------
**	??/??/????	???			Creation Date
**	02/15/2003	Chad Aberle		Added Checks for PKPM00400 possibility
**	04/22/2003	Chad Aberle		Fixed inner join scripting checks
**	06/26/2003	Chad Aberle		Added PM10100 and PM30600 Dup Check
**	7/11/2003	Chad Aberle		Use Exists function to remove subquery error
**	2/13/2004	Brent Everson		Issue with ##Temp4 script, rewrote with inner join
**
******************************************************************************************
SELECT * FROM DELETE PM10000 WHERE VCHNUMWK = '00000000000016910'
*/

/* First create a temp table to hold the PM Trans Work (PM10000) duplicates that
** are also found in the PM Trans Open (PM20000)*/
SET NOCOUNT ON

DECLARE @ERR int 
Set @ERR=0 
 
CREATE TABLE dbo.##Temp1 (
 VCHNUMWK char (17) NOT NULL ,
 VENDORID char (15) NOT NULL ,
 DOCTYPE smallint NOT NULL )

/* Next insert into the ##Temp1 the documents that are duplicates in the PM10000 
** and the PM20000*/

INSERT ##Temp1
(W.VCHNUMWK,W.VENDORID,W.DOCTYPE)
SELECT O.VCHRNMBR,O.VENDORID,O.DOCTYPE
FROM PM10000 W, PM20000 O
WHERE W.VCHNUMWK IN (SELECT O.VCHRNMBR FROM PM20000)
AND W.DOCTYPE=O.DOCTYPE

/* Create a temp table to hold the PM Payment Work (PM10300) duplicates that
** are also found in the PM Trans Open (PM20000)*/

CREATE TABLE dbo.##Temp2 (
 VCHNUMWK char (17) NOT NULL ,
 VENDORID char (15) NOT NULL ,
 DOCTYPE smallint NOT NULL )

/* Next insert into the ##Temp2 the documents that are duplicates in the PM10300
** and the PM20000*/

INSERT ##Temp2
(W.VCHNUMWK,W.VENDORID,W.DOCTYPE)
SELECT O.VCHRNMBR,O.VENDORID,O.DOCTYPE
FROM PM10300 W, PM20000 O
WHERE W.PMNTNMBR IN (SELECT O.VCHRNMBR FROM PM20000)
AND W.DOCTYPE=O.DOCTYPE

/* Create a temp table that will hold duplicates found in the PM10000 and the 
** PM30200 tables*/

CREATE TABLE dbo.##Temp3 (
 VCHNUMWK char (17) NOT NULL ,
 VENDORID char (15) NOT NULL ,
 DOCTYPE smallint NOT NULL )

/* Next insert all the duplicates that are found in the PM10000 and the PM30200
** tables*/

INSERT ##Temp3
(W.VCHNUMWK,W.VENDORID,W.DOCTYPE)
SELECT O.VCHRNMBR,O.VENDORID,O.DOCTYPE
FROM PM10000 W, PM30200 O
WHERE W.VCHNUMWK IN (SELECT O.VCHRNMBR FROM PM30200)
AND W.DOCTYPE=O.DOCTYPE

/* Create a temp table that will hold duplicates found in the PM10300 and the 
** PM30200 tables*/

CREATE TABLE dbo.##Temp4 (
 VCHNUMWK char (21) NOT NULL ,
 VENDORID char (15) NOT NULL ,
 DOCTYPE smallint NOT NULL )

/* Next insert all the duplicates that are found in the PM10300 and the PM30200
** tables*/

INSERT ##Temp4
(W.VCHNUMWK,W.VENDORID,W.DOCTYPE)
SELECT O.VCHRNMBR,O.VENDORID,O.DOCTYPE
FROM PM10300 W inner join PM30200 O
ON W.DOCTYPE=O.DOCTYPE and W.VCHRNMBR = O.VCHRNMBR

/* Create a temp table that will hold duplicates found in the PM20000 and the 
** PM30200*/

CREATE TABLE dbo.##Temp5 (
 VCHNUMWK char (17) NOT NULL ,
 VENDORID char (15) NOT NULL ,
 DOCTYPE smallint NOT NULL )

/* Next insert all the duplicates that are found in the PM20000 and the PM30200
** tables*/

INSERT ##Temp5
(W.VCHNUMWK,W.VENDORID,W.DOCTYPE)
SELECT O.VCHRNMBR,O.VENDORID,O.DOCTYPE
FROM PM20000 W, PM30200 O
WHERE W.VCHRNMBR IN (SELECT O.VCHRNMBR FROM PM30200)
AND W.DOCTYPE=O.DOCTYPE



/* Now select the information from these tables*/
if (select count(*) from ##Temp1) > 0 
begin
	set @ERR=1 
	print 'Duplicates in the PM10000 Work Table and the PM20000 Open Table'
	select * from ##Temp1
end
--******************
if (select count(*) from ##Temp2) > 0 
begin
	set @ERR=1
	print 'Duplicates in the PM10300 Payment Work Table and the PM20000 Open Table'
	select * from ##Temp2
end
--******************
if (select count(*) from ##Temp3) > 0 
begin
	set @ERR=1
	print 'Duplicates in the PM10000 Work Table and the PM30200 History Table'
	select * from ##Temp3
end
--******************
if (select count(*) from ##Temp4) > 0 
begin
	set @ERR=1
	print 'Duplicates in the PM10300 Payment Work Table and the PM30200 History Table'
	select * from ##Temp4
end
--******************
if (select count(*) from ##Temp1) > 0 
begin
	set @ERR=1
	print 'Duplicates in the PM20000 Open Table and the PM30200 History Table'
	select * from ##Temp5
end
--******************



--Duplicates among tables causing Primary Key Violation on PM00400
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp6 from PM10000 a inner join PM20000 b
on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp6) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10000 Work Table and the PM20000 Open Table'
	select * from ##Temp6
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp7 from PM10300 a inner join PM20000 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp7) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10300 PMT Work Table and the PM20000 Open Table'
	select * from ##Temp7
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp8 from PM10400 a inner join PM20000 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp8) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10400 Manual PMT Work Table and the PM20000 Open Table'
	select * from ##Temp8
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp9 from PM20000 a inner join PM30200 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp9) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM20000 Open Table and the PM30200 History Table'
	select * from ##Temp9
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp10 from PM10000 a inner join PM30200 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp10) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10000 Work Table and the PM30200 History Table'
	select * from ##Temp10
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp11 from PM10300 a inner join PM30200 b
on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp11) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10300 PMT Work Table and the PM30200 History Table'
	select * from ##Temp11
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp12 from PM10400 a inner join PM30200 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp12) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10400 Manual PMT Work Table and the PM30200 History Table'
	select * from ##Temp12
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.VENDORID into ##Temp13 from PM10300 a inner join PM10400 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP

if (select count(*) from ##Temp13) > 0 
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10300 PMT Work Table and the PM10400 Manual PMT Work Table'
	select * from ##Temp13
end
--******************
select a.VCHRNMBR, a.CNTRLTYP, a.APTVCHNM, a.VENDORID, a.SPCLDIST, a.DSTSQNUM into ##Temp14 from PM10100 a inner join PM30600 b
	on a.VCHRNMBR=b.VCHRNMBR and a.CNTRLTYP=b.CNTRLTYP and a.APTVCHNM=b.APTVCHNM
	and a.SPCLDIST=b.SPCLDIST and a.DSTSQNUM=b.DSTSQNUM

if (select count(*) from ##Temp14) > 0 
begin
	set @ERR=1
	print 'Duplicate Distribution Records in the PM10100 Work Table and the PM30600 History Table'
	select * from ##Temp14
end
--******************
select VCHRNMBR, CNTRLTYP, VENDORID into ##Temp15 from PM10100
	where VCHRNMBR not in (select VCHRNMBR from PM10000) and
	VCHRNMBR not in (select VCHRNMBR from PM20000 where CNTRLTYP = 0)
	and CNTRLTYP = 0

if (select count(*) from ##Temp15) > 0 
begin
	set @ERR=1
	print 'Distribution Records in the PM10100 but not in PM10000 or PM20000 for Invoices, Misc, Finance Docs, CM, & Returns'
	select * from ##Temp15
end
--******************

select VCHRNMBR, VENDORID into ##Temp16 from PM10100 
	where VCHRNMBR not in (select VCHRNMBR from PM10300) and
	VCHRNMBR not in (select VCHRNMBR from PM10400) and
	VCHRNMBR not in (select VCHRNMBR from PM20000 where CNTRLTYP = 1)
	and CNTRLTYP = 1

if (select count(*) from ##Temp16) > 0 
begin
	set @ERR=1
	print 'Distribution Records in the PM10100 but not in PM10300, PM10400 or PM20000 for PMT'
	select * from ##Temp16
end
--******************


--Testing Within Tables Themselves (Possibly from Migration Problems)
if exists (select count(*) from PM10000 group by VCHRNMBR,CNTRLTYP having count(*) > 1)
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10000 Work Table'
	select VCHRNMBR,CNTRLTYP,VENDORID from PM10000 group by VCHRNMBR,CNTRLTYP,VENDORID having count(*) > 1
end
--******************
if exists (select count(*) from PM10300 group by PMNTNMBR,CNTRLTYP having count(*) > 1)
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10300 PMT Work Table'
	select PMNTNMBR,CNTRLTYP,VENDORID from PM10300 group by PMNTNMBR,CNTRLTYP,VENDORID having count(*) > 1
end
--******************
if exists (select count(*) from PM10400 group by VCHRNMBR,CNTRLTYP having count(*) > 1)
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM10400 Manual PMT Work Table'
	select VCHRNMBR,CNTRLTYP,VENDORID from PM10400 group by VCHRNMBR,CNTRLTYP,VENDORID having count(*) > 1
end
--******************
if exists (select count(*) from PM20000 group by VCHRNMBR,CNTRLTYP having count(*) > 1)
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM20000 Open Table'
	select VCHRNMBR,CNTRLTYP,VENDORID from PM20000 group by VCHRNMBR,CNTRLTYP,VENDORID having count(*) > 1
end
--******************
if exists (select count(*) from PM30200 group by VCHRNMBR,CNTRLTYP having count(*) > 1)
begin
	set @ERR=1
	print 'Duplicate Voucher Number and Control Type combination in the PM30200 History Table'
	select VCHRNMBR,CNTRLTYP,VENDORID from PM30200 group by VCHRNMBR,CNTRLTYP,VENDORID having count(*) > 1
end
--******************


drop table ##Temp1
drop table ##Temp2
drop table ##Temp3
drop table ##Temp4
drop table ##Temp5
drop table ##Temp6
drop table ##Temp7
drop table ##Temp8
drop table ##Temp9
drop table ##Temp10
drop table ##Temp11
drop table ##Temp12
drop table ##Temp13
drop table ##Temp14
drop table ##Temp15
drop table ##Temp16

--******************
if @ERR=0
	begin
	print 'Completed successfully; no duplicates found'
	end
else
	begin
	print 'Completed successfully; Warning, duplicates found'
	end






