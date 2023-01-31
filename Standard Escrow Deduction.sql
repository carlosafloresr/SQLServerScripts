-- SELECT * FROM VendorMaster

DECLARE	@DedCode	Char(10),
		@Company	Char(6),
		@Account	Char(10)

SET		@DedCode = (SELECT RTRIM(VarC) FROM Parameters WHERE ParameterCode = 'ESCROW_OOACCT')
SET		@Company = 'IMC'
SET		@Account = (SELECT RTRIM(CreditAccount) FROM OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = @DedCode)

SELECT	*
FROM	(
SELECT	EST.VendorId
		,OOS.DeductionCode
		,OOS.DeductionInactive
		,OOS.Completed
		,OOS.NumberOfDeductions
		,VEM.HireDate
		,SUM(EST.Amount) AS Balance
FROM	EscrowTransactions EST
		LEFT JOIN VendorMaster VEM ON EST.CompanyId = VEM.Company AND EST.VendorId = VEM.VendorId
		LEFT JOIN View_OOS_Deductions OOS ON EST.CompanyId = OOS.Company AND EST.VendorId = OOS.VendorId AND EST.AccountNumber = OOS.CreditAccount AND OOS.DeductionCode IN (@DedCode,'ESCA')
WHERE	EST.CompanyId = @Company
		AND EST.AccountNumber = @Account
		AND EST.Fk_EscrowModuleId <> 10
		AND EST.PostingDate IS NOT Null
		AND VEM.TerminationDate IS Null
GROUP BY 
		EST.VendorId
		,OOS.DeductionCode
		,OOS.DeductionInactive
		,OOS.Completed
		,OOS.NumberOfDeductions
		,VEM.HireDate) ESC
WHERE	Balance < 1500
		AND DeductionCode IS Null