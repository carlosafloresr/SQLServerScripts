-- EXECUTE USP_OOS_Escrow_Repayment 'IMC', 'CFLORES'
-- SELECT * FROM IMC.dbo.PM00200 WHERE VNDCLSID = 'DRV'

--ALTER PROCEDURE USP_OOS_Escrow_Repayment
DECLARE	@Company	Char(5),
		@UserId		Varchar(25)
--AS
DECLARE	@DedCode1		Char(10),
		@DedCode2		Char(10),
		@MaxBalance		Money,
		@AmntOOSTD		Money,
		@AmntOOMYT		Money,
		@AmntRePay		Money,
		@DrvDedCode		Char(10),
		@StartDate		Datetime,
		@TermDate		Datetime,
		@Deducted		Money,
		@DedNumber		Int,
		@Ded1Inactive	Bit,
		@Balance		Money,
		@VendorType		Int,
		@Deduction1Id	Int,
		@Deduction2Id	Int,
		@Query			Varchar(2000)
		
-- EXECUTE USP_OOS_RestoreHistory
SET	@Company = 'IMC'
SET @UserId = 'cflores'
SET	@Query = 'SELECT * INTO ##Tmp_Vendor FROM ' + RTRIM(@Company) + '.dbo.PM00200 WHERE VNDCLSID = ''DRV'''

EXECUTE(@Query)

SELECT	@DedCode1 = VarC
FROM	Parameters
WHERE	ParameterCode = 'ESCROW_OOACCT'

SELECT	@DedCode2 = VarC
FROM	Parameters
WHERE	ParameterCode = 'ESCROW_STNDRD'

SELECT	@MaxBalance = VarN
FROM	Parameters
WHERE	ParameterCode = 'MAXESCROWBALANCE'
		AND Company = @Company

SELECT	BA.Balance,
		CAST(CASE WHEN VE.VendStts = 1 THEN 1 ELSE 0 END AS Bit) AS Status,
		OO.*
FROM	VendorMaster VM
		INNER JOIN ##Tmp_Vendor VE ON VM.VendorId = VE.VendorId
		LEFT JOIN View_OOS_Deductions OO ON VM.VendorId = OO.VendorId AND VM.Company = OO.Company
		LEFT JOIN View_GeneralEscrowBalance BA ON OO.VendorId = BA.VendorId AND OO.Company = BA.CompanyId
WHERE	VM.TerminationDate IS Null
		AND (OO.DeductionCode = 'CESC' OR OO.DeductionCode IS Null)
		AND VM.Company = 'IMC'
		AND (BA.Balance < OO.MaxDeduction OR OO.NumberOfDeductions >= OO.DeductionNumber)
		AND OO.DeductionInactive = 0
		AND BA.Balance < @MaxBalance
		AND VM.VendorId NOT IN (SELECT Vendorid FROM View_OOS_Deductions WHERE DeductionCode NOT IN ('CESC','ESCA') AND Company = 'IMC')
ORDER BY VM.VendorId

DROP TABLE [##Tmp_Vendor]

-- SELECT * FROM View_OOS_Deductions WHERE Vendorid = '9462'