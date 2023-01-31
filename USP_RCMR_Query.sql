CREATE PROCEDURE USP_RCMR_Query (@Request Varchar(MAX))
AS
DECLARE	@Query Varchar(MAX)

SET	@Query = N'SELECT * FROM OPENQUERY(ILSRC01_VFP,''' + REPLACE(@Request, '''', '''''') + ''')'

EXECUTE(@Query)