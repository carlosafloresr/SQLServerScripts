SELECT	DISTINCT FIP.Depot_Loc AS Location
		,FIP.Acct_No AS Customer
		,ACC.acct_name AS CustomerName
		,FIP.Part_No AS PartNumber
		,FIP.Descript AS [Description]
		,FIP.Cdex_damag AS DamageCode
		,DAM.Description AS DamageCode_Description
		,FIP.Cdex_repai AS RepairCode
		,REP.Description AS RepairCode_Description
FROM	FI_Parts_365 FIP
		LEFT JOIN DamageCodes DAM ON FIP.Cdex_damag = DAM.DamageCode
		LEFT JOIN RepairCodes REP ON FIP.Cdex_repai = REP.RepairCode
		LEFT JOIN Accounts ACC ON FIP.Acct_No = ACC.acct_no