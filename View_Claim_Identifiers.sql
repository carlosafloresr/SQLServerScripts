CREATE VIEW View_Claim_Identifiers
AS
SELECT	DISTINCT RTRIM(CD.client) + RIGHT(RTRIM(CD.claim_year), 2) + dbo.PADL(CM.claim_id, 3, '0') AS AccountingId,
		CASE 
			WHEN product_line = 3 THEN '3' 
			WHEN product_line = 0 THEN '1' 
			WHEN product_line IN (1,2) THEN
				CASE 
					WHEN CD.claim_type IN (1,2,3,4,5,8,9,10,13) THEN '1'
					WHEN CD.claim_type IN (6,7,11,12,14,15) THEN '2'
					ELSE '' END
			WHEN product_line = 98 THEN '5'
			WHEN product_line = 8 THEN '8'
			WHEN product_line >= 10 AND product_line <=90 THEN CAST(product_line AS varchar(3))
			ELSE '**BUG**' END 
			+ CASE WHEN division_cd < 10 THEN '0' + CAST(division_cd AS varchar(4)) ELSE CAST(division_cd AS varchar(4)) END + '.' + 
			SUBSTRING(CM.claim_year,3,2) +
			CASE 
				WHEN LEN(CAST(CM.claim_id AS varchar(3))) = 1 THEN '00' + CAST(CM.claim_id AS varchar(3)) 
				WHEN LEN(CAST(CM.claim_id AS varchar(3))) = 2 THEN '0' + CAST(CM.claim_id AS varchar(3)) 
				ELSE CAST(CM.claim_id AS varchar(3)) 
			END 
			+ '.' + CASE 
				WHEN CD.claim_type IN (1,2,3,4,5,8,9,10,13) THEN 'C'
				WHEN CD.claim_type IN (6,7,11,12,14,15) THEN 'W'
				ELSE '' END 
			+ '.' + CAST(claim_class AS varchar(4)) AS [gl_claim_number],
		CM.employee_id,
		CM.division_cd,
		CASE
			WHEN (select ID from driver_type where Code=CM.employee_type) <> 1 then 1
			ELSE 0
		END AS [employee_type],
		CM.dot_accident_type
FROM	Claims.dbo.claim_master CM
		LEFT OUTER JOIN claim_detail CD ON CM.client = CD.client and CM.claim_year = CD.claim_year and CM.claim_id = CD.claim_id
