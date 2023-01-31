SELECT	DISTINCT INV.depot_loc,
		INV.acct_no,
		SAL.BIN,
		SAL.part_no,
		PAR.Descript AS Part_Description,
		SAL.cdex_damag,
		DAM.Description AS Damage_Description,
		SAL.cdex_repai,
		REP.Description AS Repair_Description
FROM	Invoices INV
		INNER JOIN Sale SAL ON INV.inv_no = SAL.inv_no
		LEFT JOIN DeaParts PAR ON SAL.part_no = PAR.Part_No
		LEFT JOIN DamageCodes DAM ON SAL.cdex_damag = DAM.DamageCode
		LEFT JOIN RepairCodes REP ON SAL.cdex_repai = REP.RepairCode
WHERE	INV.est_date BETWEEN GETDATE() - 90 AND GETDATE()
		AND estatus <> 'CANC'
		AND SAL.BIN <> ''
		AND SAL.cdex_damag <> ''
		AND SAL.cdex_repai <> ''
ORDER BY
		INV.depot_loc,
		INV.acct_no,
		SAL.BIN,
		SAL.part_no,
		SAL.cdex_damag,
		SAL.cdex_repai
--SELECT	TOP 100 *
--FROM	Sale
--WHERE	date > '10/01/2013'