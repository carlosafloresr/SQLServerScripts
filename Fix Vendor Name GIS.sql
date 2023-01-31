/*
DROP TABLE GPCustom.dbo.PM00200_GIS
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_GIS
FROM	PM00200
GO

UPDATE	PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	GPCustom.dbo.PM00200_GIS PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND PM00200.VndClsId = 'DRV'
*/

SELECT	VendorId
		,VndChkNm
		,GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', '')) AS VndChkNm 
FROM	PM00200
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'N'
		AND VndClsId = 'DRV'

SELECT	VendorId
		,VndChkNm
		,GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + REPLACE(RTRIM(VendorId), 'G', '') + '%', VndChkNm) - 1), '#', '')) AS VndChkNm 
FROM	PM00200
WHERE	PATINDEX('%' + REPLACE(RTRIM(VendorId), 'G', '') + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'A'
		AND VndClsId = 'DRV'
		
/*
UPDATE	PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', ''))
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'G'
		AND VndClsId = 'DRV'
		
UPDATE	PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + REPLACE(RTRIM(VendorId), 'G', '') + '%', VndChkNm) - 1), '#', ''))
WHERE	PATINDEX('%' + REPLACE(RTRIM(VendorId), 'G', '') + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'G'
		AND VndClsId = 'DRV'
		
UPDATE	PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(VndChkNm)
WHERE	LEFT(VendorId, 1) = 'G'
		
SELECT * FROM PM00200 ORDER BY VndChkNm
*/