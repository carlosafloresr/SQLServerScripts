/*
DROP TABLE GPCustom.dbo.PM00200_NDS
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_NDS
FROM	NDS.dbo.PM00200
GO

UPDATE	NDS.dbo.PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', ''))
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'N'
		AND VndClsId = 'DRV'
*/

/*
UPDATE	NDS.dbo.PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	GPCustom.dbo.PM00200_NDS PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND LEFT(PM00200.VendorId, 1) = 'N'
		AND PM00200.VndClsId = 'DRV'
*/