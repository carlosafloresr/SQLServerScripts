SELECT	name
FROM	sys.procedures
WHERE	Object_definition(object_id) LIKE '%GP_XCB_Prepaid%'
		--OR Object_definition(object_id) LIKE '%IntegrationsDB%'
ORDER BY 1