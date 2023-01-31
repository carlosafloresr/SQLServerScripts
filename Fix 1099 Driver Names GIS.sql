/*
DROP TABLE GPCustom.dbo.PM00200_GIS
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_GIS
FROM	GIS.dbo.PM00200
GO

UPDATE	GIS.dbo.PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', ''))
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'G'
		AND VndClsId = 'DRV'
GO
*/

/*
SELECT	*
FROM	GPCustom..PM00200_GIS
WHERE	VndClsId = 'DRV'

SELECT	GPCustom.dbo.PROPER(VendName)
		,VendName
		,VndChkNm
FROM	GPCustom..PM00200_GIS
WHERE	VndClsId = 'DRV'

UPDATE	GIS.dbo.PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	GPCustom.dbo.PM00200_GIS PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND PM00200.VndClsId = 'DRV'
*/