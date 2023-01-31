CREATE PROCEDURE USP_EscrowAdvanceBalances
		@Company	Varchar(5),
		@VendorId	Varchar(12)
AS
DECLARE	@PayDate	Datetime,
		@WeekEnd	Datetime

SET		@PayDate	= CONVERT(Char(10), dbo.DayFwdBack(GETDATE(), 'P', 'Thursday'), 101)
SET		@WeekEnd	= dbo.DayFwdBack(@PayDate, 'P', 'Saturday')

SELECT	'Accounts Payable Balance' AS AccountAlias
		,dbo.DriverBalance(@Company, @VendorId, @PayDate) AS Balance
		,0 AS Sort
FROM	VendorMaster
WHERE	Company = @Company
		AND VendorId = @VendorId
UNION
SELECT	AccountAlias
		,Balance
		,1 AS Sort
FROM	View_EscrowAdvanceBalances
WHERE	CompanyId = @Company
		AND VendorId = @VendorId
UNION
SELECT	'Drayage'
		,Drayage + DriverFuelRebate AS Balance
		,2 AS Sort
FROM	Integration_APDetails DE
		INNER JOIN Integration_APHeader HE ON DE.BatchId = HE.BatchId
WHERE	HE.WeekEndDate = @WeekEnd
		AND DE.VendorId = @VendorId
ORDER BY 3, 1

/*
PRINT dbo.DayFwdBack(GETDATE(), 'P', 'Thursday')
PRINT dbo.DriverBalance('AIS', 'A0086', '6/18/2009')

SELECT	'Drayage'
		,Drayage + DriverFuelRebate AS Balance
FROM	Integration_APDetails DE
		INNER JOIN Integration_APHeader HE ON DE.BatchId = HE.BatchId
WHERE	HE.WeekEndDate = '6/13/2009'
		AND DE.VendorId = 'A0086'

SELECT * FROM AIS.dbo.PM30200 WHERE VENDORID = 'A0088'

SELECT	SUM(Amount - ApplyTo)
		FROM	(
				SELECT	PM1.VendorId
						,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM AIS.dbo.PM20100 PM2 WHERE PM2.ApplyToGLPostDate <= '6/11/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
				FROM	AIS.dbo.PM20000 PM1
				WHERE	PM1.PostEddt <= '6/22/2009'
						AND PM1.VendorId = 'A0106'
				UNION
				SELECT	PM1.VendorId
						,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM AIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= '6/11/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
				FROM	AIS.dbo.PM30200 PM1
				WHERE	PM1.PostEddt <= '6/22/2009'
						AND PM1.BchSourc <> 'XPM_Cchecks'
						AND PM1.VendorId = 'A0106') TRN


SELECT * FROM AIS.dbo.PM20000 WHERE VendorId = 'A0106'
SELECT * FROM AIS.dbo.PM30200 WHERE VendorId = 'A0106'
*/