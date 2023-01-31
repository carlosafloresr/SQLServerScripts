/*
-- SELECT * FROM EscrowTransactions WHERE ChangedOn > '7/1/2008' AND EnteredBy = 'HDOYLE' EnteredOn <> ChangedOn AND ChangedBy = 'APP_RECOVER'

SELECT * FROM IMC.dbo.PM00200 where VndClsId = ''

-- UPDATE IMC.dbo.PM00200 SET VndClsId = 'OTH' where VndClsId = ''
*/

SELECT	VoucherNumber,
		AccountNumber,
		ModuleDescription,
		VendorId,
		Amount,
		TransactionDate 
FROM	EscrowTransactions ET
		INNER JOIN EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
WHERE	ChangedOn > '7/1/2008' 
		AND EnteredBy = 'HDOYLE'

Select * 
from imc.dbo.PM30200 
	where DocNumbr in (
select	DocNumbr from (
Select	DocNumbr, count(DocNumbr) as counter from imc.dbo.PM30200 group by DocNumbr having count(DocNumbr) > 1) CNT)
order by DocNumbr

Select	BachNumb,
		VchrNmbr,
		VendorId,
		DocDate,
		DocNumbr,
		DocAmnt,
		TrxDscrn,
		DueDate,
		PostEddt,
		MdfUsrid
from imc.dbo.PM30200 
	where DocNumbr + VendorId in (
select	DocNumbr + VendorId from (
Select	DocNumbr, VendorId, count(DocNumbr) as counter from imc.dbo.PM30200 group by DocNumbr, VendorId having count(DocNumbr) > 1) CNT)
order by DocNumbr

UPDATE imc.dbo.PM30200 SET DocNumbr = 'RB0005a' WHERE VchrNmbr = '00000000000003509    ' AND VendorId = '3452'
'080611AC01'

/*
select * from imc.dbo.PM30200 where VchrNmbr = '00000000000003509    ' AND VendorId = '3452'
select * from imc.dbo.PM00400 where docnumbr = 'RC0003a' AND VendorId = '3452'

select	PM1.VchrNmbr, PM1.DocDate, PM1.DocNumbr, PM1.TrxSorce, PM2.*
from	imc.dbo.PM30200 PM1
		INNER JOIN imc.dbo.PM00400 PM2 ON PM1.VchrNmbr = PM2.CntrlNum AND PM1.TrxSorce = PM2.TrxSorce
where	PM1.VendorId = '3452'

select * from imc.dbo.PM00400 where VendorId = '3452'

update imc.dbo.PM00400 set docnumbr = 'RC0003a' where VchrNmbr = '00000000000003509    ' AND VendorId = '3452'
'080611AC01'
*/

UPDATE	imc.dbo.PM00400
SET		PM00400.DocNumbr = PM20000.DocNumbr
FROM	imc.dbo.PM20000
WHERE	PM00400.CntrlNum = PM20000.VchrNmbr AND PM00400.TrxSorce = PM20000.TrxSorce AND PM00400.VendorId = '3452'

UPDATE	imc.dbo.PM00400
SET		PM00400.DocNumbr = PM30200.DocNumbr
FROM	imc.dbo.PM30200
WHERE	PM00400.CntrlNum = PM30200.VchrNmbr AND PM00400.TrxSorce = PM30200.TrxSorce AND
		PM00400.DocNumbr <> PM30200.DocNumbr

select	PM1.VchrNmbr, PM1.DocDate, PM1.DocNumbr, PM1.TrxSorce, PM2.*
from	imc.dbo.PM20000 PM1
		INNER JOIN imc.dbo.PM00400 PM2 ON PM1.VchrNmbr = PM2.CntrlNum AND PM1.TrxSorce = PM2.TrxSorce
where	PM1.DocNumbr <> PM2.DocNumbr

Select	DocNumbr, VendorId, count(DocNumbr) as counter from imc.dbo.PM20000 group by DocNumbr, VendorId having count(DocNumbr) > 1

select * from imc.dbo.PM30200 where VchrNmbr in (SELECT CntrlNum FROM imc.dbo.PM00400 WHERE DocNumbr = 'RC0003a' and VendorId in ('3452','15639','11959'))
and VendorId in ('3452','15639','11959')

SELECT * FROM imc.dbo.PM00400 WHERE DocNumbr = 'RC0003a' and VendorId in ('3452','15639','11959')

delete imc.dbo.PM00400 WHERE DocNumbr = 'RC0003a' and VendorId in ('3452','15639','11959') and trxsorce = ''

select * from imc.dbo.PM00300 where vendorid in (select VendorId from imc.dbo.PM00200 where vaddcdpr not in (select adrscode from imc.dbo.PM00300))