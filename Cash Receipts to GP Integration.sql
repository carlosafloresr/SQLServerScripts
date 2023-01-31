DECLARE	@Integration	Varchar(10) = 'LCKBX',
		@Company		Varchar(5),
		@BatchId		Varchar(25) = 'LCKBX010419034636',
		@IntBatch		Varchar(15)

SELECT	DISTINCT REPLACE(@BatchId, 'LCKBX', 'LB') AS Integration,
		CASH.Company,
		CASH.CustomerNumber,
		CASH.CheckNumber,
		CAST(GETDATE() AS Date) AS DOCDATE,
		Amount = (SELECT SUM(TEMP.Payment) FROM View_CashReceipt [TEMP] WHERE TEMP.Company = CASH.Company AND TEMP.BatchId = CASH.BatchId AND TEMP.CheckNumber = CASh.CheckNumber),
		CAST(GETDATE() AS Date) AS PSTGDATE,
		'' AS CHEKBKID,
		CASH.CheckNumber
FROM	View_CashReceipt CASH
WHERE	CASH.BatchId = @BatchId
		AND Status > 2

/*
SELECT	*
FROM	View_CashReceipt
WHERE	BatchId = 'LCKBX010419034636'
		AND Status > 2
*/

-- 'CH' + dbo.PADL(MONTH(UploadDate), 2, '0') + dbo.PADL(DAY(UploadDate), 2, '0') + RIGHT(YEAR(UploadDate), 2) + RIGHT(DATEPART(HOUR, UploadDate), 2) + RIGHT(DATEPART(MINUTE, UploadDate), 2) + '_' + RIGHT(DATEPART(SECOND, UploadDate), 2) AS Integration,