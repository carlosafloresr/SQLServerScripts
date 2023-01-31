UPDATE	OOS_Deductions
SET		OOS_Deductions.Deducted			= DATA.TotalDeducted,
		OOS_Deductions.LastAmount		= DATA.LastDeduction,
		OOS_Deductions.DeductionNumber	= DATA.LastDeductionNumber
FROM	(
		SELECT	*,
				LastDeduction = (SELECT TOP 1 OOS.DeductionAmount FROM View_OOS_Transactions OOS WHERE OOS.Company = VOT.Company AND OOS.VendorId = VOT.VendorId AND OOS.DeductionCode = VOT.DeductionCode AND OOS.DeductionNumber = VOT.LastDeductionNumber)
		FROM	(
				SELECT	Company
						,VendorId
						,DeductionCode
						,DeductionId
						,COUNT(*) AS Counter
						,SUM(DeductionAmount) AS TotalDeducted
						,MAX(DeductionNumber) AS LastDeductionNumber
				FROM	View_OOS_Transactions
				WHERE	Trans_DeletedBy IS Null
						AND Company = 'OIS'
				GROUP BY
						Company
						,VendorId
						,DeductionCode
						,DeductionId
				) VOT
		) DATA
WHERE	OOS_Deductions.OOS_DeductionId = DATA.DeductionId