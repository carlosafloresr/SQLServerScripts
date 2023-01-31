SELECT	DISTINCT Company
FROM	GPVendorMaster

UPDATE	OIS.dbo.PM00200
SET		UPSZONE = 'SWS'
WHERE	VendorId IN (	SELECT	VendorId
						FROM	GPVendorMaster
						WHERE	Company = 'OIS'
								AND SWSVendor = 1)