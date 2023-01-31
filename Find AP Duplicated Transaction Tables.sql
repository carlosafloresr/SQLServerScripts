print '----- start of query -----'

declare @debitdoc as varchar(30)
declare @credtdoc as varchar(30)
set @debitdoc = 'DPYA0172100911069' -- replace with appropriate invoice / finance charge / miscellaenous charge voucher number
set @credtdoc = 'DPYA0172100911069' -- replace with corresponding return / credit memo voucher number or check payment number

/*
'
SELECT * FROM PM30600
SELECT * FROM PM10100

SELECT DISTINCT VCHRNMBR FROM PM30600 WHERE VCHRNMBR IN (SELECT VCHRNMBR FROM PM30200_11182010) AND DOCTYPE = 1
SELECT VCHRNMBR FROM PM30200_11182010 WHERE VCHRNMBR NOT IN (SELECT VCHRNMBR FROM PM30600 where DOCTYPE = 1)
DELETE PM10100 WHERE VCHRNMBR = '00000000000016910'
DELETE PM00400 WHERE CNTRLNUM = '00000000000016910'
UPDATE PM20000 SET DOCNUMBR = 'PIP00000000000000006' WHERE VCHRNMBR = '00000000000016910'

************** DELETE HISTORY DOCUMENT ************
DELETE PM30200 WHERE VCHRNMBR = '00000000000022042'
DELETE PM30600 WHERE VCHRNMBR = '00000000000022042'
DELETE PM00400 WHERE CntrlNum = '00000000000022042'
***************************************************
*/

print '----------------'
print 'transaction info'
print '----------------'

print 'PM20000 / OPEN:'
select 'PM20000:Open' AS DataTable, VENDORID, DOCTYPE, VCHRNMBR, DOCNUMBR, DOCAMNT, CURTRXAM, DOCDATE, * from PM20000 
where VCHRNMBR in (@debitdoc, @credtdoc)

print 'PM30200  / HIST:' 
select 'PM30200:History' AS DataTable, VENDORID, DOCTYPE, VCHRNMBR, DOCNUMBR, DOCAMNT, CURTRXAM, DOCDATE, * from PM30200 
where VCHRNMBR in (@debitdoc, @credtdoc)

print 'PM00400 / PM Keys:' 
select 'PM00400:PM Keys' AS DataTable, CNTRLTYP, DCSTATUS, DOCTYPE, CNTRLNUM, DOCNUMBR, VENDORID, TRXSORCE from PM00400 
where CNTRLNUM in (@debitdoc, @credtdoc)

print '------------------------------------'
print 'apply record info based on debit doc'
print '------------------------------------'

print 'PM10200 / OPEN:' 
select 'PM10200:Open' AS DataTable, VENDORID, DOCTYPE, VCHRNMBR, APFRDCNM, APTVCHNM, APTODCNM, APTODCTY, 
APPLDAMT, ORAPPAMT, APFRMAPLYAMT, ActualApplyToAmount, * from PM10200 
where APTODCTY in (1, 2, 3) and APTVCHNM in (@debitdoc)

print 'PM20100' 
Select 'PM20100' AS DataTable,* from PM20100
where APTODCTY in (1, 2, 3) and APTVCHNM in (@debitdoc)

print ' PM30300  / HIST:' 
select 'PM30300:History' AS DataTable, VENDORID, DOCTYPE, VCHRNMBR, APFRDCNM, APTVCHNM, APTODCNM, APTODCTY, 
APPLDAMT, ORAPPAMT, APFRMAPLYAMT, ActualApplyToAmount, * from PM30300 
where APTODCTY in (1, 2, 3) and APTVCHNM in (@debitdoc)

print '-------------------------------------'
print 'apply record info based on credit doc'
print '-------------------------------------'

print 'PM10200  / OPEN:' 
select 'PM10200:Work to Open-Apply To' AS DataTable, VENDORID, DOCTYPE, VCHRNMBR, APFRDCNM, APTVCHNM, APTODCNM, APTODCTY, 
APPLDAMT, ORAPPAMT, APFRMAPLYAMT, ActualApplyToAmount, * from PM10200 
where DOCTYPE in (4, 5, 6) and VCHRNMBR in (@credtdoc)

print 'PM20100:Open to Open-Apply To' 
select 'PM20100' AS DataTable, * from PM20100 
where DOCTYPE in (4, 5, 6) and VCHRNMBR in (@credtdoc)

print 'PM30300 / HIST:' 
select 'PM30300:History-Apply To' AS DataTable, VENDORID, DOCTYPE, VCHRNMBR, APFRDCNM, APTVCHNM, APTODCNM, APTODCTY, 
APPLDAMT, ORAPPAMT, APFRMAPLYAMT, ActualApplyToAmount, * from PM30300 
where DOCTYPE in (4, 5, 6) and VCHRNMBR in (@credtdoc)

print '-------------------------------------'
print '        distributions                '
print '-------------------------------------'

print 'PM10100/INVOICE'
select 'PM10100:Work-Invoice' AS DataTable,* from PM10100 
where VCHRNMBR in (@debitdoc)

print 'PM10100/PAYMENT'
select'PM10100:Work-Payment' AS DataTable, * from PM10100 
where VCHRNMBR in (@credtdoc)

print 'PM30600/INVOICE'
select 'PM30600:History-Invoice' AS DataTable,* from PM30600
where VCHRNMBR in (@debitdoc)

print 'PM30600/PAYMENT'
select 'PM30600:History-Payment' AS DataTable, * from PM30600
where VCHRNMBR in (@credtdoc)

print 'GL10000/Work: Payment' 
select 'GL10000:Work-Payment' AS DataTable, * from GL10000 
where DTAControlNum  in (@credtdoc)

print 'GL10000/Work: Invoice' 
select 'GL10000:Work-Invoice' AS DataTable, * from GL10000 
where DTAControlNum  in (@debitdoc)

print 'GL20000/Open: Payment' 
select 'GL20000:Open-Payment' AS DataTable, * from GL20000 
where ORCTRNUM in (@credtdoc)

print 'GL20000/Open: Invoice' 
select 'GL20000:Open-Invoice', * from GL20000 
where ORCTRNUM in (@debitdoc)

print 'GL10001/Work: Invoice/MC' 
select 'GL10001:Work-Invoice/MC', * from GL10001 
where ORCTRNUM  in (@debitdoc)

print 'GL20000/Open: Invoice/MC' 
select 'GL20000:Open-Invoice/MC', * from GL20000 
where ORCTRNUM in (@debitdoc)

print 'GL10001/Work: Payment/MC' 
select 'GL10001:Work-Payment/MC' AS DataTable, * from GL10001 
where ORCTRNUM  in (@credtdoc)

print 'MC020105: Invoice/MC' 
select 'MC020105:Invoice/MC' AS DataTable, * from MC020105 
where VCHRNMBR  in (@debitdoc)

print 'MC020105: Payment/MC' 
select 'MC020105:Payment' AS DataTable, * from MC020105 
where VCHRNMBR in (@credtdoc)

print '----- end of query -----'

