/*
DROP TABLE GPCustom.dbo.PM00200_PTS
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_PTS
FROM	PTS.dbo.PM00200
GO

UPDATE	PTS.dbo.PM00200
SET		VndChkNm = UPPER(REPLACE(IIF(GPCustom.dbo.AT(RTRIM(LEFT(VendorId, 4)), VndChkNm, 1) > 1, LEFT(VndChkNm, GPCustom.dbo.AT(RTRIM(LEFT(VendorId, 4)), VndChkNm, 1) - 1), VndChkNm), '#', ''))
		--GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', ''))
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		--AND LEFT(VendorId, 1) = 'A'
		AND VndClsId = 'DRV'
GO
*/

/*
UPDATE	PTS.dbo.PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	GPCustom.dbo.PM00200_PTS PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND PM00200.VndClsId = 'DRV'
*/
