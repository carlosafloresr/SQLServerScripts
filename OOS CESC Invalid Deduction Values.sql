SELECT	OOS.Company,
		RTRIM(OOS.VendorId) AS DriverId,
		OOS.DeductionCode,
		OOS.Balance,
		CASE WHEN OOS.Perpetual = 1 THEN 'Y' ELSE 'N' END AS Perpetual,
		CASE WHEN OOS.Perpetual = 1 THEN 0 ELSE OOS.MaxDeduction END AS MaxDeduction,
		PAR.VarN AS CompanyRequiredBalance,
		OOS.AmountToDeduct,
		OOS.Deducted AS DeductedToDate,
		OOS.MaintainBalance,
		ISNULL(VMA.Agent,'') AS Agent,
		VMA.Division,
		OOS.DeductionId
FROM	View_OOS_Deductions OOS
		INNER JOIN VendorMaster VMA ON OOS.Company = VMA.Company AND OOS.VendorId = VMA.VendorId AND VMA.TerminationDate IS Null
		LEFT JOIN Parameters PAR ON OOS.Company = PAR.Company AND PAR.ParameterCode = 'MAXESCROWBALANCE'
WHERE	DeductionInactive = 0
		AND DedTypeInactive = 0
		--AND DeductionCode = 'CESC'
		--AND (Perpetual = 1 OR OOS.MaxDeduction > PAR.VarN)
		--AND Perpetual = 0
		AND OOS.Company = 'AIS'
ORDER BY
		OOS.Company,
		OOS.VendorId

/*
UPDATE	OOS_Deductions
SET		--OOS_Deductions.MaxDeduction = 1500, --DATA.CompanyRequiredBalance,
		OOS_Deductions.Perpetual	= 0
FROM	(
		SELECT	OOS.Company,
				RTRIM(OOS.VendorId) AS DriverId,
				OOS.Balance,
				CASE WHEN OOS.Perpetual = 1 THEN 'Y' ELSE 'N' END AS Perpetual,
				CASE WHEN OOS.Perpetual = 1 THEN 0 ELSE OOS.MaxDeduction END AS MaxDeduction,
				PAR.VarN AS CompanyRequiredBalance,
				OOS.AmountToDeduct,
				OOS.Deducted AS DeductedToDate,
				OOS.DeductionId
		FROM	View_OOS_Deductions OOS
				INNER JOIN VendorMaster VMA ON OOS.Company = VMA.Company AND OOS.VendorId = VMA.VendorId AND VMA.TerminationDate IS Null
				LEFT JOIN Parameters PAR ON OOS.Company = PAR.Company AND PAR.ParameterCode = 'MAXESCROWBALANCE'
		WHERE	DeductionInactive = 0
				AND DedTypeInactive = 0
				AND DeductionCode = 'CESC'
				AND (Perpetual = 1 OR OOS.MaxDeduction > PAR.VarN)
				AND OOS.Company = 'NDS'
		) DATA
WHERE	OOS_Deductions.OOS_DeductionId = DATA.DeductionId
*/