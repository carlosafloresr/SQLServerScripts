/*
select	LTRIM(RTRIM(a2.dOCnUMBR))
from	AIS_History a1
		inner join AIS.DBO.PM30200 a2 on a1.Voucher = a2.VchrNmbr and abs(a1.amount) = a2.docamnt
ORDER BY a2.dOCnUMBR
--WHERE	Voucher NOT IN (SELECT VchrNmbr FROM AIS.DBO.PM30200)
select * from AIS_History
select * from ilsint01.integrations.dbo.integrations_ap
SELECT * FROM AIS.DBO.PM30200
*/
insert into ilsint01.integrations.dbo.integrations_ap
	([Integration]
           ,[Company]
           ,[BatchId]
           ,[VCHNUMWK]
           ,[VENDORID]
           ,[DOCNUMBR]
           ,[DOCTYPE]
           ,[DOCAMNT]
           ,[DOCDATE]
           ,[PSTGDATE]
           ,[CHRGAMNT]
           ,[TEN99AMNT]
           ,[PRCHAMNT]
           ,[TRXDSCRN]
           ,[CURNCYID]
           ,[RATETPID]
           ,[EXCHDATE]
           ,[RATEEXPR]
           ,[CREATEDIST]
           ,[DISTTYPE]
           ,[ACTNUMST]
           ,[DEBITAMT]
           ,[CRDTAMNT]
           ,[DISTREF]
           ,[RecordId])
select	'PDM' AS Integration,
		'AIS' ,
		'AIS_HISTRECOVRY' AS BatchId,
		a2.[VCHRNMBR],
		A1.VENDORID,
		A2.DOCNUMBR,
		A2.DOCTYPE,
		A2.DOCAMNT,
		A2.DOCDATE,
		'11/19/2010' AS PSTGDATE,
		A2.DOCAMNT,
		0 AS TEN99AMNT,
		A2.DOCAMNT,
		A2.TRXDSCRN,
		'USD2',
		1001,
		'1/1/2007',
		0,
		0,
		6,
		'0-00-2102',
		A2.DOCAMNT,
		0,
		A2.TRXDSCRN,
		0
from	AIS_History a1
		inner join AIS.DBO.PM30200 a2 on a1.Voucher = a2.VchrNmbr and abs(a1.amount) = a2.docamnt
UNION
select	'PDM' AS Integration,
		'AIS' ,
		'AIS_HISTRECOVRY' AS BatchId,
		a2.VCHRNMBR,
		A1.VENDORID,
		A2.DOCNUMBR,
		A2.DOCTYPE,
		A2.DOCAMNT,
		A2.DOCDATE,
		'11/19/2010' AS PSTGDATE,
		A2.DOCAMNT,
		0 AS TEN99AMNT,
		A2.DOCAMNT,
		A2.TRXDSCRN,
		'USD2',
		1001,
		'1/1/2007',
		0,
		0,
		6,
		'0-00-2102',
		0,
		A2.DOCAMNT,
		A2.TRXDSCRN,
		0
from	AIS_History a1
		inner join AIS.DBO.PM30200 a2 on a1.Voucher = a2.VchrNmbr and abs(a1.amount) = a2.docamnt

/*		
select * from ilsint01.integrations.dbo.integrations_ap
SELECT * FROM AIS..PM10100
*/

