DECLARE	@TextToSearch	Varchar(500) = 'USP_SalesStatement_w_SWSData'

SELECT	DISTINCT OBJ.name AS ObjectName,
		OBJ.type_desc AS ObjectType,
		SUBSTRING(MDL.definition, PATINDEX('%' + RTRIM(@TextToSearch) + '%', MDL.definition) - 30, 100) AS FoundUnder
FROM	sys.sql_modules MDL
		INNER JOIN sys.objects OBJ ON MDL.object_id = OBJ.object_id
WHERE	MDL.definition LIKE '%' + RTRIM(@TextToSearch) + '%'
		AND OBJ.type in ('P', 'V')
		--AND OBJ.type_desc = 'SQL_STORED_PROCEDURE'

-- PRIFBSQL01P
