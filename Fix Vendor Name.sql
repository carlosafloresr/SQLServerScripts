/*
DROP TABLE GPCustom.dbo.PM00200_IMC
GO

SELECT	*
INTO	GPCustom.dbo.PM00200_IMC
FROM	PM00200
GO

UPDATE	PM00200
SET		VndChkNm = VendName
WHERE	VndClsId = 'DRV'

UPDATE	PM00200
SET		PM00200.VndChkNm = PM00200_IMC.VndChkNm
FROM	GPCustom.dbo.PM00200_IMC
WHERE	PM00200.VendorId = PM00200_IMC.VendorId
*/

SELECT	VendorId
		,VndChkNm
		,REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 1), '#', '') AS VndChkNm 
FROM	PM00200
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND VndClsId = 'DRV'


/*
UPDATE	PM00200
SET		VndChkNm = REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 1), '#', '')
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND VndClsId = 'DRV'
		
SELECT * FROM PM00200 ORDER BY VndChkNm
*/