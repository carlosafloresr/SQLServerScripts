USE [FI]
GO
/****** Object:  StoredProcedure [dbo].[USP_REPAP_Notification]    Script Date: 1/18/2018 11:28:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_REPAP_Notification 'REPAR_011718', 1
EXECUTE USP_REPAP_Notification 'REPAR_011718', 0
*/
ALTER PROCEDURE [dbo].[USP_REPAP_Notification]
		@BatchId		Varchar(15),
		@JustSummary	Bit = 0
AS
DECLARE	@DatePortion	Varchar(12),
		@BatchDate		Datetime = (SELECT TOP 1 Import_Date FROM Staging.MSR_Import WHERE BatchId = @BatchId)

SET @DatePortion	= dbo.PADL(MONTH(@BatchDate), 2, '0') + dbo.PADL(DAY(@BatchDate), 2, '0') + RIGHT(dbo.PADL(YEAR(@BatchDate), 4, '0'), 2)

DECLARE	@tblCustomers	Table (
		CustNmbr		Varchar(15),
		BatchBilling	Bit)

DECLARE	@tblTIP			Table (
		LinkedCompany	Varchar(5),
		CustomerId		Varchar(15))

INSERT INTO @tblTIP
SELECT	DISTINCT LinkedCompany,
		Account AS CustomerId
FROM	ILSINT02.Integrations.dbo.FSI_Intercompany_ARAP
WHERE	Company = 'FI' 
		AND RecordType = 'C'

INSERT INTO @tblCustomers
SELECT	DISTINCT CMA.CustNmbr,
		CMA.BatchBilling
FROM	LENSASQL001.GPCustom.dbo.CustomerMaster CMA
WHERE	CMA.CompanyId IN ('FI','IMCMR')
		AND CMA.CustNmbr <> ''

IF @JustSummary = 0
BEGIN
	SELECT	DISTINCT MSR.acct_no AS Customer, 
			MSR.inv_no AS Invoice, 
			MSR.inv_date AS InvDate, 
			MSR.inv_total AS Amount, 
			CASE WHEN MSR.Intercompany = 1 THEN 'Yes' ELSE 'No' END AS Intercompany,
			ISNULL(TIP.LinkedCompany,'') AS Company
	FROM	Staging.MSR_Import MSR
			LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
			LEFT JOIN @tblTIP TIP ON MSR.acct_no = TIP.CustomerId
	WHERE	MSR.BatchId = @BatchId
			AND MSR.depot_loc <> 'MEMREFURB'
			AND ISNULL(CUS.BatchBilling, 0) = 0
	UNION
	SELECT	DISTINCT MSR.acct_no AS Customer, 
			CASE WHEN MSR.inv_batch = 'B0' THEN 'B' + @DatePortion ELSE MSR.inv_batch END AS Invoice, 
			MAX(MSR.inv_date) AS invdate, 
			SUM(MSR.inv_total) AS Amount, 
			CASE WHEN MSR.Intercompany = 1 THEN 'Yes' ELSE 'No' END AS Intercompany,
			ISNULL(TIP.LinkedCompany,'') AS Company
	FROM	Staging.MSR_Import MSR
			LEFT JOIN @tblCustomers CUS ON MSR.acct_no = CUS.CustNmbr
			LEFT JOIN @tblTIP TIP ON MSR.acct_no = TIP.CustomerId
	WHERE	MSR.BatchId = @BatchId
			AND MSR.depot_loc <> 'MEMREFURB'
			AND CUS.BatchBilling = 1
	GROUP BY
			MSR.acct_no,
			MSR.inv_batch,
			MSR.Intercompany,
			TIP.LinkedCompany
	ORDER BY 1, 2
END
ELSE
BEGIN
	SELECT	'Sales' AS Company,
			'ALL' AS Customer,
			SUM(MSR.inv_total) AS Amount
	FROM	Staging.MSR_Import MSR
			LEFT JOIN @tblTIP TIP ON MSR.acct_no = TIP.CustomerId
	WHERE	MSR.BatchId = @BatchId
			AND MSR.depot_loc <> 'MEMREFURB'
			AND TIP.CustomerId IS Null
	UNION
	SELECT	TIP.LinkedCompany AS Company,
			TIP.CustomerId AS Customer,
			SUM(MSR.inv_total) AS Amount
	FROM	Staging.MSR_Import MSR
			INNER JOIN @tblTIP TIP ON MSR.acct_no = TIP.CustomerId
	WHERE	MSR.BatchId = @BatchId
			AND MSR.depot_loc <> 'MEMREFURB'
			AND TIP.CustomerId IS NOT Null
	GROUP BY
			TIP.LinkedCompany,
			TIP.CustomerId
	ORDER BY 1, 2
END