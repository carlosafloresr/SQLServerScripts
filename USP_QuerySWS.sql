/*
EXECUTE USP_QuerySWS 'SELECT code, description FROM public.dmsite WHERE code <> '''' ORDER BY description'
*/
ALTER PROCEDURE [dbo].[USP_QuerySWS] (@Request Varchar(MAX))
AS
DECLARE	@Query			Varchar(MAX)

SET	@Query = N'SELECT * FROM OPENQUERY(PostgreSQLPROD,''' + REPLACE(@Request, '''', '''''') + ''')'

EXECUTE(@Query)