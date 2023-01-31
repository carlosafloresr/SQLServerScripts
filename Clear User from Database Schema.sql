SELECT s.name
FROM sys.schemas s
WHERE s.principal_id = USER_ID('ILSCLAIMS');

ALTER AUTHORIZATION ON SCHEMA::db_owner TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datareader TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datawriter TO dbo;