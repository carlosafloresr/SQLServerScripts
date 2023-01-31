/*
EXECUTE USP_AR_NextPaymentNumber
*/
CREATE PROCEDURE USP_AR_NextPaymentNumber
		@Company		Varchar(5)
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@CurrentId		Varchar(30),
		@NextId			Varchar(30)

DECLARE	@tblSequence	Table (DOCNUMBR Varchar(30))

SET @Query = N'SELECT RTRIM(DOCNUMBR) FROM ' + @Company + '.dbo.RM40401 WHERE DOCABREV = ''PMT'''

INSERT INTO @tblSequence
EXECUTE(@Query)

SET @CurrentId	= (SELECT DOCNUMBR FROM @tblSequence)
SET @NextId		= LEFT(@CurrentId, 8) + dbo.PADL(CAST(RIGHT(@CurrentId, 9) AS Int) + 1, 9, '0')

SET @Query = N'UPDATE ' + @Company + '.dbo.RM40401 SET DOCNUMBR = ''' + @NextId + ''' WHERE DOCABREV = ''PMT'''
EXECUTE(@Query)

SELECT @CurrentId AS NextId
