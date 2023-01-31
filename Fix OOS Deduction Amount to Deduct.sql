UPDATE	OOS_Deductions
SET		OOS_Deductions.DeductionAmount = 100
FROM	(
		SELECT	*
		FROM	View_OOS_Deductions
		WHERE	Company = 'GIS'
				AND DeductionCode = 'CESC'
		) DATA
WHERE	OOS_Deductions.OOS_DeductionId = DATA.DeductionId