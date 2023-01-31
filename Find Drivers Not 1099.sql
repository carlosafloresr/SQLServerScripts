-- SELECT * FROM PM00200

SELECT	'GIS' AS Company
		,VendorId
		,VendName
		,Ten99Type
FROM	PM00200
WHERE	VendStts = 1
		AND VndClsId = 'DRV'
		AND Ten99Type = 1
UNION
SELECT	'IMC' AS Company
		,VendorId
		,VendName
		,Ten99Type
FROM	IMC.dbo.PM00200
WHERE	VendStts = 1
		AND VndClsId = 'DRV'
		AND Ten99Type = 1
UNION
SELECT	'NDS' AS Company
		,VendorId
		,VendName
		,Ten99Type
FROM	NDS.dbo.PM00200
WHERE	VendStts = 1
		AND VndClsId = 'DRV'
		AND Ten99Type = 1