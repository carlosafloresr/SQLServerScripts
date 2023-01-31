/*
SELECT	*
INTO	GPCustom.dbo.PM00200_NDS
FROM	PM00200
*/

SELECT	VendorId
		,VndChkNm
		,REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', '') AS VndChkNm 
FROM	PM00200
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'N'


/*
UPDATE	PM00200
SET		VndChkNm = REPLACE(LEFT(VndChkNm, PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) - 2), '#', '')
WHERE	PATINDEX('%' + RTRIM(VendorId) + '%', VndChkNm) > 0
		AND LEFT(VendorId, 1) = 'N'
		
SELECT * FROM PM00200 ORDER BY VndChkNm
*/