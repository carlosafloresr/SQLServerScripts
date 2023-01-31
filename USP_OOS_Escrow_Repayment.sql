/* 

EXECUTE USP_OOS_Escrow_Repayment 'IMC', 'CFLORES'

SELECT * FROM View_OOS_Deductions WHERE VendorId = '9549' AND DeductionId = 2629
SELECT * FROM View_GeneralEscrowBalance WHERE VendorId = '9549'
SELECT * FROM IMC.dbo.PM00200 WHERE VNDCLSID = 'DRV'

UPDATE OOS_Deductions SET VendorId = '9549b' WHERE OOS_DeductionId = 2629 -- Was 3
*/

ALTER PROCEDURE USP_OOS_Escrow_Repayment
		@Company		Char(5),
		@UserId			Varchar(25)
AS
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
		@DedRepayAmnt	Money,
		@DeductionId	Int,
		@Query			Varchar(2000)
		
SET	@Query = 'SELECT * INTO ##Tmp_Vendors FROM ' + RTRIM(@Company) + '.dbo.PM00200 WHERE VNDCLSID = ''DRV'''

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

SELECT	@DedRepayAmnt = VarN
FROM	Parameters
WHERE	ParameterCode = 'DED_REPAYMENT'

SELECT	@DeductionId = OOS_DeductionTypeId
FROM	OOS_DeductionTypes
WHERE	Company = @Company
		AND DeductionCode = @DedCode2

INSERT INTO OOS_Deductions
           (Fk_OOS_DeductionTypeId
           ,Vendorid
           ,StartDate
           ,DeductionAmount
           ,Frequency
           ,MaxDeduction
           ,NumberOfDeductions
           ,Perpetual
           ,Inactive
           ,Completed
           ,Notes
           ,CurrentDeductions
           ,Deducted
           ,DeductionNumber
           ,Balance
           ,LastBatchId
           ,LastAmount
           ,LastPeriod
           ,CreatedOn
           ,CreatedBy
           ,ModifiedOn
           ,ModifiedBy)
SELECT	@DeductionId
		,VendorId
		,GETDATE()
		,AmountToDeduct
		,'W'
		,@MaxBalance
		,@MaxBalance / AmountToDeduct
		,0
		,0
		,0
		,Null
		,0
		,0
		,0
		,Balance
		,''
		,0
		,''
		,GETDATE()
		,@UserId
		,GETDATE()
		,@UserId
FROM	(
SELECT	VM.VendorId
		,VM.HireDate
		,VM.TerminationDate
		,BA.Balance
		,CAST(CASE WHEN VE.VendStts = 1 THEN 1 ELSE 0 END AS Bit) AS VendorStatus
		,@DedRepayAmnt AS AmountToDeduct
		,@MaxBalance - BA.Balance AS MaxDeduction
		,O1.NumberOfDeductions
		,O1.Deducted
		,O1.DeductionNumber
		,ROUND((@MaxBalance - BA.Balance) / @DedRepayAmnt, 0) AS NumDeductions
		,OO.DeductionCode
		,O1.DeductionInactive
FROM	VendorMaster VM
		INNER JOIN ##Tmp_Vendors VE ON VM.VendorId = VE.VendorId
		INNER JOIN View_OOS_Deductions O1 ON VM.VendorId = O1.VendorId AND VM.Company = O1.Company AND O1.DeductionCode = @DedCode1
		LEFT JOIN View_OOS_Deductions OO ON VM.VendorId = OO.VendorId AND VM.Company = OO.Company AND OO.DeductionCode = @DedCode2
		LEFT JOIN View_GeneralEscrowBalance BA ON VM.VendorId = BA.VendorId AND VM.Company = BA.CompanyId
WHERE	VM.TerminationDate IS Null
		AND OO.DeductionCode IS Null
		AND VM.Company = @Company
		AND ISNULL(BA.Balance, 0) BETWEEN 0 AND (@MaxBalance - .01)
		AND OO.VendorId IS Null
		AND O1.VendorId IS NOT Null
		AND (O1.Deducted >= O1.MaxDeduction OR (O1.DeductionNumber >= O1.NumberOfDeductions AND O1.NumberOfDeductions > 0))
		AND O1.Deducted > 0
		AND VM.SubType IS NOT Null
		AND VE.VendStts = 1) DED

DROP TABLE ##Tmp_Vendors
/*
SELECT * FROM View_OOS_Deductions WHERE VendorId = '9573'
SELECT * FROM View_GeneralEscrowBalance WHERE VendorId = '9442'
SELECT * FROM EscrowTransactions WHERE VendorId = '9699' AND AccountNumber = '0-00-2790'
DELETE OOS_Deductions WHERE Fk_OOS_DeductionTypeId NOT IN (SELECT OOS_DeductionTypeId FROM OOS_DeductionTypes)

SELECT	*
FROM	Parameters
WHERE	ParameterCode = 'DED_REPAYMENT'
CREATE VIEW View_EscrowAccountsBalance
AS
SELECT	CompanyId,
					VendorId,
					AccountNumber,
					Fk_EscrowModuleId,
					SUM(Amount) AS Balance
			FROM	EscrowTransactions
			WHERE	PostingDate IS NOT Null
			GROUP BY
					CompanyId,
					VendorId,
					AccountNumber,
					Fk_EscrowModuleId
*/