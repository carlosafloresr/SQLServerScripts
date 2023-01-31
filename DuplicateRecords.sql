CREATE FUNCTION dbo.DuplicateRecords (@Table varchar(40), @Field varchar(40))
RETURNS @DupRecords Table (DupField [varchar] (50))
AS
BEGIN
	DECLARE	@Query	Varchar(1000)

	SET		@Query = 'INSERT INTO @DupRecords (DupField) '
	SET		@Query = @Query + 'SELECT ' + RTRIM(@Field) + ' AS MainField FROM ' + RTRIM(@Table) + ' Table01 INNER JOIN ('
	SET		@Query = @Query + 'SELECT ' + RTRIM(@Field) + ' AS MainField, COUNT(' + RTRIM(@Field) + ') AS Counter '
	SET		@Query = @Query + 'FROM ' + RTRIM(@Table) + ' GROUP BY ' + RTRIM(@Field)
	SET		@Query = @Query + ' HAVING COUNT(' + RTRIM(@Field) + ') > 1) Table02 ON Table01.' + RTRIM(@Field) + ' = Table02.MainField'

	EXECUTE(@Query)

	RETURN
END
GO