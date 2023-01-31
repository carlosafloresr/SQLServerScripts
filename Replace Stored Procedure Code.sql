DECLARE	@TextToSearch	Varchar(500) = 'ILSGP01'

SELECT	b.Name                                                                      AS [ObjectName],
		CASE WHEN b.type ='p' THEN 'Stored Procedure'
			 WHEN b.type ='v' THEN 'View' 
			 ELSE b.TYPE 
		END                                                                         AS [ObjectType]
		--,a.definition                                                               AS [Definition]
		,REPLACE ((REPLACE(definition,'ILSGP01','PRISQL01P')),'Create','ALTER')   AS [ModifiedDefinition]
FROM	sys.sql_modules a
		JOIN (	SELECT	type, name,object_id
				FROM	sys.objects
				WHERE	type in ('P', 'V')
						AND is_ms_shipped = 0 
			) b ON a.object_id = b.object_id
WHERE	a.definition LIKE '%' + RTRIM(@TextToSearch) + '%'