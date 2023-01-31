SELECT	CM1.CustNmbr,
		CM1.CustName,
		CM1.BillType,
		CM1.DoesBillPerDiem,
		CM1.SCAC_Code,
		CM1.FreightBillTo,
		CM1.BillToAllLocations,
		CM2.BillType AS BillType_Backup,
		CM2.DoesBillPerDiem AS DoesBillPerDiem_Backup,
		CM2.SCAC_Code AS SCAC_Code_Backup,
		CM2.FreightBillTo AS FreightBillTo_Backup,
		CM2.BillToAllLocations AS BillToAllLocations_Backup,
		CM1.ChangedBy
FROM	CustomerMaster CM1
		LEFT JOIN CustomerMasterBackup CM2 ON CM1.CompanyId = CM2.CompanyId AND CM1.CustNmbr = CM2.CustNmbr
WHERE	CM1.BillType <> CM2.BillType
		OR CM1.DoesBillPerDiem <> CM2.DoesBillPerDiem
		OR CM1.SCAC_Code <> CM2.SCAC_Code