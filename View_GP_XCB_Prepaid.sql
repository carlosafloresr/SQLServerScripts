USE GPCustom
GO

ALTER VIEW dbo.View_GP_XCB_Prepaid 
AS
SELECT	XCB.RecordId
		,XCB.Company
		,XCB.TrxDate
		,XCB.JournalNo
		,XCB.Reference
		,XCB.DocumentNo
		,XCB.Vendor
		,XCB.Amount
		,XCB.ProNumber
		,XCB.GPPeriod
		,FiscalPeriod = CASE LEFT(XCB.GPPeriod, 3)
			 WHEN 'JAN' THEN '01-20'
			 WHEN 'FEB' THEN '02-20'
			 WHEN 'MAR' THEN '03-20'
			 WHEN 'APR' THEN '04-20'
			 WHEN 'MAY' THEN '05-20'
			 WHEN 'JUN' THEN '06-20'
			 WHEN 'JUL' THEN '07-20'
			 WHEN 'AGU' THEN '08-20'
			 WHEN 'SEP' THEN '09-20'
			 WHEN 'OCT' THEN '10-20'
			 WHEN 'NOV' THEN '11-20'
			 ELSE '12-20' END + RIGHT(XCB.GPPeriod, 2)
		,CAST(FIP.EndDate AS Date) AS FP_EndDate
		,XCB.GLAccount
		,XCB.Matched
		,XCB.SWSVendor
		,XCB.SWSVndName
		,XCB.SWSVndInvoice
		,XCB.SWSVndCost
		,XCB.SWSPayType
		,XCB.SWSManifestDate
		,XCB.SWSStatus
		,XCB.ProcessingDate
FROM	GPCustom.dbo.GP_XCB_Prepaid XCB
		INNER JOIN DYNAMICS.dbo.View_Fiscalperiod FIP ON FIP.GP_Period = CASE LEFT(XCB.GPPeriod, 3)
			 WHEN 'JAN' THEN '01-20'
			 WHEN 'FEB' THEN '02-20'
			 WHEN 'MAR' THEN '03-20'
			 WHEN 'APR' THEN '04-20'
			 WHEN 'MAY' THEN '05-20'
			 WHEN 'JUN' THEN '06-20'
			 WHEN 'JUL' THEN '07-20'
			 WHEN 'AGU' THEN '08-20'
			 WHEN 'SEP' THEN '09-20'
			 WHEN 'OCT' THEN '10-20'
			 WHEN 'NOV' THEN '11-20'
			 ELSE '12-20' END + RIGHT(XCB.GPPeriod, 2)

GO