/*
DROP TABLE GPCustom.dbo.PM00200_AIS
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_AIS
FROM	PM00200
GO

SELECT	*
FROM	GPCustom..PM00200_AIS
WHERE	VndClsId = 'DRV'

SELECT	GPCustom.dbo.PROPER(VendName)
		,VendName
		,VndChkNm
FROM	GPCustom..PM00200_AIS
WHERE	VndClsId = 'DRV'


UPDATE	PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	AIS_December2010.dbo.PM00200 PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND PM00200.VndClsId = 'DRV'
*/

SELECT	VendorId
		,VndChkNm
		,GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', '')) AS VndChkNm 
FROM	PM00200
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'D'
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
		AND LEFT(VendorId, 1) = 'A'
		AND VndClsId = 'DRV'