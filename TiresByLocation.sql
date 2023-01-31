SELECT	*
FROM	TiresByLocation

UPDATE	TiresByLocation
SET		TireCategory = CASE LEFT(PartNumber, 2) WHEN 'FI' THEN 'FI' WHEN 'CM' THEN 'POOL' ELSE 'CONSIGMENT' END

UPDATE	TiresByLocation
SET		TireType = 'NEW'
WHERE	RIGHT(RTRIM(PartNumber), 1) = 'N' OR PATINDEX('%New%', PartDescription) > 0

UPDATE	TiresByLocation
SET		TireType = 'RECAP'
WHERE	RIGHT(RTRIM(PartNumber), 1) = 'R' 
		OR PATINDEX('%Recap%', PartDescription) > 0 
		OR LEFT(RIGHT(RTRIM(PartNumber), 2), 1) = 'R'
		
/*
INSERT INTO TiresByLocation

SELECT	'Houston',
		Part_No,
		'',
		CASE LEFT(Part_No, 2) WHEN 'FI' THEN 'FI' WHEN 'CM' THEN 'POOL' ELSE 'CONSIGMENT' END,
		CASE WHEN RIGHT(RTRIM(Part_No), 1) = 'N' OR PATINDEX('%New%', Descript) > 0 THEN 'NEW' ELSE 'RECAP' END
FROM	(
SELECT	DISTINCT SAL.Part_No, PAR.Descript
FROM	SaleItems SAL
		LEFT JOIN DeaParts PAR ON SAL.part_no = PAR.Part_No
WHERE	UserId = 'CFLORES'
		AND TireCategory IS NULL 
		AND LEFT(SAL.Part_No, 2) IN ('CC', 'DC', 'FI', 'MW')
		) RECS
*/