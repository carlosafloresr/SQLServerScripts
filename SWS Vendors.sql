SELECT	PM.VendorId,
		PM.VendName,
		PM.VndChkNm,
		PM.VendShNm,
		PM.VndClsId
FROM	PM00200 PM
WHERE	VendorId IN (SELECT VendorId FROM GPCustom.dbo.GPVendorMaster WHERE Company = 'NDS' AND SWSVendor = 1)
ORDER BY 2