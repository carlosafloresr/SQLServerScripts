/*
EXECUTE USP_ReleaseAPHold 'AIS', 'OACA1352061914A'
*/
CREATE PROCEDURE USP_ReleaseAPHold
		@Company	Varchar(5),
		@DocNumber	Varchar(30)
AS
DECLARE	@tblRecord	Table (Dex_Row_Id Int)
DECLARE	@Query		Varchar(MAX),
		@RecordId	Int = 0,
		@ReturnVaue	Int = 0

SET		@Query = N'SELECT Dex_Row_Id FROM ' + @Company + '.dbo.PM20000 WHERE DOCNUMBR = ''' + @DocNumber + ''''

INSERT INTO @tblRecord
EXECUTE(@Query)

IF (SELECT COUNT(*) FROM @tblRecord) > 0
	SELECT @RecordId = Dex_Row_Id FROM @tblRecord

IF @RecordId > 0
BEGIN
	SET	@Query = N'UPDATE ' + @Company + '.dbo.PM20000 SET Hold = 0 WHERE Dex_Row_Id = ' + CAST(@RecordId AS Varchar)
	EXECUTE(@Query)
	IF @@ERROR = 0
		SET @ReturnVaue = 1
	ELSE
		SET @ReturnVaue = 0
END

RETURN @ReturnVaue