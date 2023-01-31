SELECT	*,
		CASE WHEN Perpetual = 1	THEN 1
			 WHEN NumberOfDeductions > 0 AND Counter < NumberOfDeductions THEN 1
			 WHEN MaxDeduction <> 0  AND NumberOfDeductions = 0 AND IIF(MaintainBalance = 1, Balance, Deducted) < MaxDeduction THEN 1
			 WHEN NumberOfDeductions <> 0 AND Counter < NumberOfDeductions THEN 1
			 ELSE 0 END AS PeriodActive
FROM	(
		SELECT	DED.VendorId,
				DED.DeductionCode,
				DED.MaxDeduction,
				DED.NumberOfDeductions,
				DED.Perpetual,
				--DED.Deducted,
				DED.Balance,
				DED.MaintainBalance,
				DED.DeductionId,
				VMA.Agent,
				VMA.SubType,
				VMA.TerminationDate,
				ISNULL(SUM(LST.DeductionAmount),0) AS Deducted,
				ISNULL(COUNT(LST.DeductionAmount),0) AS Counter
		FROM	View_OOS_Deductions DED
				INNER JOIN VendorMaster VMA ON DED.Company = VMA.Company AND DED.VendorId = VMA.VendorId
				LEFT JOIN View_OOS_Transactions LST ON DED.Company = LST.Company AND DED.VendorId = LST.VendorId AND DED.DeductionCode = LST.DeductionCode
		WHERE	DED.Company = 'AIS'
				AND DED.DeductionInactive = 0
				AND DED.DeductionTypeInactive = 0
				AND DED.DeductionCode <> 'MANT'
				AND DED.Vendorid = 'A0976'
				--AND DED.MaxDeduction > 1500
				--AND DED.DeductionCode = 'CESC'
				--AND VMA.TerminationDate IS Null
		GROUP BY
				DED.VendorId,
				DED.DeductionCode,
				DED.MaxDeduction,
				DED.NumberOfDeductions,
				DED.Perpetual,
				--DED.Deducted,
				DED.Balance,
				DED.MaintainBalance,
				DED.DeductionId,
				VMA.Agent,
				VMA.SubType,
				VMA.TerminationDate
		) DATA
ORDER BY 
		VendorId,
		DeductionCode

/*
UPDATE	OOS_Deductions
SET		MaxDeduction = 1500
WHERE	OOS_DeductionId = 26994
*/