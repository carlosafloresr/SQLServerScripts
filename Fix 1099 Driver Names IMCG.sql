/*
DROP TABLE GPCustom.dbo.PM00200_IMC
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_IMC
FROM	IMC.dbo.PM00200
GO

UPDATE	IMC.dbo.PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', ''))
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND VndClsId = 'DRV'
GO
*/

/*
UPDATE	IMC.dbo.PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	GPCustom.dbo.PM00200_IMC PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND PM00200.VndClsId = 'DRV'
*/