DECLARE	@Client			Varchar(10) = 'NDS',
		@Year			Smallint = 2018,
		@Month			Smallint = 7
AS
DECLARE	@DateIni		Datetime,
		@DateEnd		Datetime,
		@PrevIni		Datetime,
		@PrevEnd		Datetime

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
		,Reserved_Claims
		,Incurred_Claims
		,Paid_Claims
		,Reserved_Claims AS PrevReserved_Escrow -- = ISNULL((SELECT SUM((CLA.dir_pay_reserve + CLA.deduct_reserve) - CLA.deduct_incurred) FROM claim_detail_audit CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year AND CAST(CLA.entry_date AS Date) < @PrevIni AND CLA.dir_pay_reserve <> 0), 0)
		,Payments_Escrow = ISNULL((SELECT SUM(CLA.deduct_incurred - (CLA.dir_pay_reserve + CLA.deduct_reserve)) FROM claim_detail_audit CLA WHERE CLA.client = DAT.client AND CLA.Claim_Id = DAT.Claim_Id AND CLA.Claim_Year = DAT.Claim_Year AND CAST(CLA.entry_date AS Date) BETWEEN @PrevIni AND @PrevEnd), 0)
		,0.00 AS CashRcpts_Escrow
		,0.00 AS ReserveAdj_Escrow
		,Reserved_Claims AS Balance_Escrow
		,Reserved_Claims AS ResBal_in_Acct
		,0.00 AS Account
		,0.00 AS IMCC
		,0.00 AS Acct_1803
		,0.00 AS Acct_6181 
		,Paid_Claims AS Paid
		,Incurred_Claims AS Accrued
		--,[Description]
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
				,CLM.[description]
				,CLM.client
				,CLM.claim_year
				,CLM.claim_id
				,CLM.claim_status
				,CLM.claim_class
				,CLM.event_type
		FROM	Claim_Master CLM
				INNER JOIN View_Claim_Identifiers VCL ON CLM.client = VCL.Client AND CLM.claim_year = VCL.Claim_Year AND CLM.claim_id = VCL.Claim_Id
				LEFT JOIN Claim_Detail CLD ON CLM.client = CLD.client AND CLM.Claim_Id = CLD.Claim_Id AND CLM.Claim_Year = CLD.Claim_Year --AND CLD.entry_date <= @DateEnd
				LEFT OUTER JOIN event_type EVT ON CLM.event_type = EVT.ID
				LEFT OUTER JOIN incident_codes INC ON CLM.incident_code = INC.ID
		WHERE	CLM.client = @Client
				AND CAST(CLM.claim_year AS Int) >= @Year
				AND CLM.event_type = 1
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