SELECT	DB_NAME() AS [database], 
		name AS [user_name], 
		type_desc,
		default_schema_name,
		create_date,
		modify_date 
FROM	sys.database_principals 
WHERE	type in ('G','S','U') 
		--AND authentication_type<>2 -- Use this filter only if you are running on SQL Server 2012 and major versions and you have "contained databases"
		AND [sid] not in (SELECT [sid] FROM sys.server_principals WHERE type in ('G','S','U') ) 
		AND name not in ('dbo','guest','INFORMATION_SCHEMA','sys','MS_DataCollectorInternalUser')