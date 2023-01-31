/*
EXECUTE USP_GP_AR_DocumentBalance 'GLSO', 'C96-127802A'
*/
CREATE PROCEDURE USP_GP_AR_DocumentBalance
		@Company	Varchar(5),
		@Document	Varchar(30)
AS
DECLARE	@Query		Varchar(MAX),
		@DCStatus	Int,
		@Balance	Numeric(10,2) = 0,
		@TblLoc		Varchar(30)

DECLARE @tblDocData	Table (DCStatus Int, Balance Numeric(10,2))

SET @Query = N'SELECT DCSTATUS, 0 FROM ' + @Company + '.dbo.RM00401 WHERE DOCNUMBR = ''' + @Document + ''''

INSERT INTO @tblDocData
EXECUTE(@Query)

IF @@ROWCOUNT = 0
	SELECT 'Inexistent' AS TblLocation, @Balance AS Balance, 0 AS TblStatus
ELSE
BEGIN
	SELECT	@DCStatus	= DCStatus,
			@Balance	= Balance
	FROM	@tblDocData

	SET @TblLoc = CASE WHEN @DCStatus = 1 THEN 'Work' WHEN @DCStatus = 2 THEN 'Open' ELSE 'Historical' END

	IF @DCStatus = 2
	BEGIN
		SET @Query = N'SELECT 2, CURTRXAM FROM ' + @Company + '.dbo.RM20101 WHERE DOCNUMBR = ''' + @Document + ''''
		
		DELETE @tblDocData

		INSERT INTO @tblDocData
		EXECUTE(@Query)

		SET @Balance = (SELECT Balance FROM @tblDocData)
	END

	SELECT @TblLoc AS TblLocation, @Balance AS Balance, @DCStatus AS TblStatus
END

--SELECT TOP 10 * FROM RM20101