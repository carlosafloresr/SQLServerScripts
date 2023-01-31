/*
EXECUTE USP_ClaimsSummary_Report 'AIS', 2019, 9, 'Vehicle Accident'
EXECUTE USP_ClaimsSummary_Report 'AIS', 2019, 9, 'Vehicle Incident'
EXECUTE USP_ClaimsSummary_Report 'NDS', 2019, 7
*/
ALTER PROCEDURE USP_ClaimsSummary_Report
		@Client			Varchar(10),
		@Year			Smallint,
		@Month			Smallint,
		@EventType		Varchar(30) = 'Vehicle Accident'
AS
DECLARE	@DateIni		Datetime,
		@DateEnd		Datetime,
		@PrevIni		Datetime,
		@PrevEnd		Datetime,
		@Event_Type		Smallint

SET @Event_Type = (SELECT Id FROM event_type WHERE [Descr] = @EventType)

SELECT	@DateIni = StartDate,
		@DateEnd = EndDate
FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
WHERE	Year1 = @Year
		AND PeriodId = @Month

print @DateIni
print @DateEnd

SELECT	TOP 1
		@PrevIni = StartDate,
		@PrevEnd = EndDate
FROM	PRISQL01P.Dynamics.dbo.View_FiscalPeriod
WHERE	EndDate < @DateIni
ORDER BY EndDate DESC 

SELECT	AccountingId
		,GL_Claim_Number
		,Division
		,DriverId
		,DateOfLoss
		,IIF(claim_status = 'C', 'Y', 'N') AS [Closed]
		,claim_class AS [Class]
		,EventType
		,Reserved_Claims AS Reserved
		,Incurred_Claims AS Incurred
		,Paid_Claims AS Paid
		,PrevReserved_Claims AS [Prev Reserved]
		,Payments = ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0)
		,incurred_total AS [Cash Rcpts]
		,(Reserved_Claims - PrevReserved_Claims - ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) - incurred_total) AS [Reserve Adj]
		,(PrevReserved_Claims + 
		ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) +
		incurred_total +
		(Reserved_Claims - PrevReserved_Claims - ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) - incurred_total)) AS Balance
		,Reserved_Claims AS [Res Bal]
		,-(Reserved_Claims - PrevReserved_Claims - ISNULL((SELECT SUM(CLA.transaction_amt) FROM View_claim_payment_log CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year), 0) - incurred_total) AS Account
		,Paid_Claims AS Paid
		,Incurred_Claims AS Accrued
		,0.00 AS IMCC
		,0.00 AS Acct_1803
		,0.00 AS Acct_6181
FROM	(
		SELECT	VCL.AccountingId
				,VCL.GL_Claim_Number
				,VCL.Division
				,CLM.employee_id AS DriverId
				,CAST(CLM.date_of_loss AS Date) AS DateOfLoss
				,VCL.EventType
				,SUM(ISNULL(CLD.dir_pay_reserve + CLD.deduct_reserve, 0.00)) AS Reserved_Claims
				,SUM(ISNULL(CLD.deduct_incurred, 0.00)) AS Incurred_Claims
				,SUM(ISNULL(CLD.deduct_incurred - (CLD.dir_pay_reserve + CLD.deduct_reserve), 0.00)) AS Paid_Claims
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
				AND CAST(CLM.claim_year AS Int) >= 2018
				AND CLM.event_type = @Event_Type
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
WHERE	Reserved_Claims + Incurred_Claims + Paid_Claims <> 0 
		AND Reserved_Claims <> 0
ORDER BY
		AccountingId

GO