UPDATE	GPVendorMaster
SET		Changed = 1
WHERE	SWSVendor = 1
		AND Company IN ('AIS','OIS')

UPDATE	GPVendorMaster
SET		Changed = 0
WHERE	SWSVendor = 1
		AND Company NOT IN ('AIS','OIS')

SELECT	*
FROM	GPVendorMaster
WHERE	SWSVendor = 1
		--AND Changed = 1
		AND Company IN ('AIS','OIS') --,'GLSO')

UPDATE	PM00200
SET		UPSZONE = 'SWS'
WHERE	VNDCLSID = 'TRD'