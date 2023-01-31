/*
SELECT	*
INTO	GPCustom.dbo.PM00200_AIS
FROM	PM00200

UPDATE	PM00200
SET		PM00200.VndChkNm = PM2.VndChkNm
FROM	ILSGP01T.AIS.dbo.PM00200 PM2
WHERE	PM00200.VendorId = PM2.VendorId
		AND PM00200.VndClsId = 'DRV'
*/

SELECT	VendorId
		,VndChkNm
		,GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', '')) AS VndChkNm 
FROM	PM00200
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'A'
		AND VndClsId = 'DRV'


/*
UPDATE	PM00200
SET		VndChkNm = GPCustom.dbo.PROPER(REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', ''))
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'A'
		AND VndClsId = 'DRV'
		
SELECT * FROM AIS.dbo.PM00200 WHERE VndClsId = 'DRV' ORDER BY VndChkNm
*/