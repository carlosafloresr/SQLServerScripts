USE [Claims]
GO
/****** Object:  StoredProcedure [dbo].[USP_ClaimsSummary_Report_New]    Script Date: 9/10/2020 1:20:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ClaimsSummary_Report_New 'DNJ', 'Vehicle Accident'
EXECUTE USP_ClaimsSummary_Report_New 'IMCG', 'ALL', 'Month End'
EXECUTE USP_ClaimsSummary_Report_New 'AIS', 'Vehicle Incident', 1
EXECUTE USP_ClaimsSummary_Report_New 'HMIS', 'ALL', 'Life to Date'
EXECUTE USP_ClaimsSummary_Report_New 'OIS', 'ALL', 'Life to Date'
EXECUTE USP_ClaimsSummary_Report_New 'NDS', 'ALL', 'Fiscal to Date'
EXECUTE USP_ClaimsSummary_Report_New 'NDS', 'ALL', 'Current'
*/
ALTER PROCEDURE [dbo].[USP_ClaimsSummary_Report_New]
		@Client			Varchar(10),
		@EventType		Varchar(30) = 'Vehicle Accident',
		@Period			Varchar(20) = 'Life to Date'
AS
DECLARE	@DateIni		Datetime,
		@DateEnd		Datetime,
		@PrevIni		Char(10),
		@PrevEnd		Char(10),
		@Event_Type		Smallint,
		@StartDate		Date,
		@CurrentYear	Int,
		@PeriodType		Smallint = 1

SET @PeriodType = CASE @Period WHEN 'Life to Date' THEN 1 WHEN 'Fiscal to Date' THEN 2 WHEN 'Month End' THEN 3 ELSE 4 END

SELECT	@CurrentYear = Year1,
		@StartDate	 = DATEADD(dd, -1, StartDate)
FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
WHERE	GETDATE() BETWEEN StartDate AND EndDate

IF @EventType = 'ALL'
	SET @Event_Type = -1
ELSE
	SET @Event_Type = (SELECT Id FROM event_type WHERE [Descr] = @EventType)

SELECT	@DateIni = StartDate,
		@DateEnd = EndDate
FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
WHERE	Year1 = YEAR(GETDATE())
		AND PeriodId = MONTH(GETDATE())

IF @PeriodType = 1
	SET @StartDate	= '01/01/2010'
ELSE
	IF @PeriodType = 2
		SELECT	@StartDate = DATEADD(dd, -1, StartDate)
		FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
		WHERE	Year1 = @CurrentYear
				AND PeriodId = 1
	ELSE
		IF @PeriodType = 4
			SELECT	@StartDate = DATEADD(dd, -1, StartDate)
			FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
			WHERE	Year1 = @CurrentYear
					AND EndDate < @DateIni

SELECT	TOP 1
		@PrevIni = CONVERT(Char(10), StartDate, 101),
		@PrevEnd = CONVERT(Char(10), EndDate, 101)
FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
WHERE	EndDate < @DateIni
ORDER BY EndDate DESC 

PRINT 'Start Date: ' + CONVERT(Char(10), @StartDate, 101)
PRINT 'Date Ini: ' + CONVERT(Char(10), @DateIni, 101)
PRINT 'Date End: ' + CONVERT(Char(10), @DateEnd, 101)
PRINT 'Prev Ini: ' + CONVERT(Char(10), @PrevIni, 101)
PRINT 'Prev End: ' + CONVERT(Char(10), @PrevEnd, 101)

SELECT	*
FROM	(
		SELECT	AccountingId
				,GL_Claim_Number
				,Division
				,DriverId
				,DateOfLoss
				,IIF(claim_status = 'C', 'Y', 'N') AS [Closed]
				,claim_class AS [Class]
				,EventType
				,IIF(Reserved_Claims < 0, 0, Reserved_Claims) AS Reserved
				,Incurred_Claims AS Incurred
				,Paid = ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0)
				,PrevReserved_Claims AS [Prev Reserved]
				,Payments = ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year AND CLA.invoice_date BETWEEN @PrevIni AND @PrevEnd), 0)
				,incurred_total AS [Cash Rcpts]
				,[Reserve Adj] = (Incurred_Claims + (ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year AND CLA.invoice_date BETWEEN @PrevIni AND @PrevEnd), 0)) - ABS(PrevReserved_Claims) - incurred_total)
				,(PrevReserved_Claims + ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) + incurred_total + (Reserved_Claims - PrevReserved_Claims - ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) - incurred_total)) AS Balance
				,IIF(Reserved_Claims < 0, 0, Reserved_Claims) AS [Res Bal]
				,-(Reserved_Claims - PrevReserved_Claims - ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) - incurred_total) AS Account
				,Paid_Claims AS Paid_Sum
				,Incurred_Claims AS Accrued
				,0.00 AS IMCC
				,0.00 AS Acct_1803
				,0.00 AS Acct_6181
				,Other = ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year AND CLA.invoice_date BETWEEN @PrevIni AND @PrevEnd), 0)
		FROM	(
				SELECT	VCL.AccountingId
						,VCL.GL_Claim_Number
						,VCL.Division
						,CLM.employee_id AS DriverId
						,CAST(CLM.date_of_loss AS Date) AS DateOfLoss
						,VCL.EventType
						,SUM(ISNULL(CLD.dir_pay_reserve + CLD.deduct_reserve, 0.00)) AS Reserved_Claims
						,SUM(ISNULL(CLD.deduct_incurred, 0.00)) AS Incurred_Claims
						--,SUM(ISNULL(CLD.deduct_incurred - (CLD.dir_pay_reserve + CLD.deduct_reserve), 0.00)) AS Paid_Claims
						,ISNULL((SELECT SUM(ISNULL(CDA.deduct_incurred - (CDA.dir_pay_reserve + CDA.deduct_reserve), 0.00)) FROM Claim_Detail_Audit CDA WHERE CDA.client = CLM.client AND CDA.Claim_Id = CLM.Claim_Id AND CDA.Claim_Year = CLM.Claim_Year AND CDA.entry_date BETWEEN @StartDate AND @DateIni), 0) AS Paid_Claims
						,ISNULL((SELECT TOP 1 CDA.dir_pay_reserve + CDA.deduct_reserve FROM Claim_Detail_Audit CDA WHERE CDA.client = CLM.client AND CDA.Claim_Id = CLM.Claim_Id AND CDA.Claim_Year = CLM.Claim_Year AND CDA.entry_date < @DateIni ORDER BY CDA.entry_date DESC), 0) AS PrevReserved_Claims
						,CLM.client
						,CLM.claim_year
						,CLM.claim_id
						,CLM.claim_status
						,CLM.claim_class
						,CLM.event_type
						,MAX(CLD.incurred_total) AS incurred_total
				FROM	Claim_Master CLM
						INNER JOIN View_Claim_Identifiers VCL ON CLM.client = VCL.Client AND CLM.claim_year = VCL.Claim_Year AND CLM.claim_id = VCL.Claim_Id AND CLM.employee_id = VCL.employee_id
						LEFT JOIN Claim_Detail CLD ON CLM.client = CLD.client AND CLM.Claim_Id = CLD.Claim_Id AND CLM.Claim_Year = CLD.Claim_Year --AND CLM.employee_id = CDL.EM
						LEFT OUTER JOIN event_type EVT ON CLM.event_type = EVT.ID
						LEFT OUTER JOIN incident_codes INC ON CLM.incident_code = INC.ID
				WHERE	CLM.client = @Client
						AND CAST(CLM.claim_year AS Int) >= 2016
						AND (CLM.event_type = @Event_Type OR @Event_Type = -1)
				GROUP BY
						VCL.AccountingId
						,VCL.GL_Claim_Number
						,VCL.Division
						,CLM.employee_id
						,CLM.date_of_loss
						,CLM.[description]
						,VCL.EventType
						,CLM.client
						,CLM.claim_year
						,CLM.claim_id
						,CLM.claim_status
						,CLM.claim_class
						,CLM.event_type
				) DAT
		) CLAIMS
WHERE	Closed = 'N'
		--Incurred + Paid <> 0
		--AND Reserved <> 0
ORDER BY
		EventType, AccountingId
		--AccountingId
