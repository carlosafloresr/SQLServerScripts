USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ValidateProNumber]    Script Date: 11/19/2021 8:12:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ValidateProNumber 8, '57-182394'
*/
ALTER PROCEDURE [dbo].[USP_ValidateProNumber]
		@CompanyNumber	Smallint,
		@ProNumber		Varchar(30)
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@Request		Varchar(MAX),
		@SplitBill		Bit = IIF(dbo.OCCURS('-', @ProNumber) > 1, 1, 0),
		@Division		Varchar(2),
		@Pro			Varchar(15),
		@Found			Bit = 0,
		@PureProNumber	Varchar(15)

DECLARE @tblResult		Table (Result Varchar(30) Null)

IF dbo.OCCURS('-', @ProNumber) > 0
BEGIN
	SET @PureProNumber = dbo.GetPureProNumber(@ProNumber)

	IF @SplitBill = 1
		SET @Request = 'SELECT Code FROM TRK.Invoice WHERE code = ''' + UPPER(RTRIM(@ProNumber)) + ''' AND cmpy_no = ' + CAST(@CompanyNumber AS Varchar)
	ELSE
		BEGIN
			SET @Division	= SUBSTRING(@PureProNumber, 1, dbo.AT('-', @PureProNumber, 1) - 1)
			SET @Pro		= SUBSTRING(@PureProNumber, dbo.AT('-', @PureProNumber, 1) + 1, 20)
			SET @Request	= 'SELECT Pro FROM TRK.Order WHERE div_code IN (''' + @Division + ''',''' + dbo.PADL(@Division, 2, '0') + ''') AND pro = ''' + @Pro + ''' AND cmpy_no = ' + CAST(@CompanyNumber AS Varchar)
		END
	
	SET	@Query = 'SELECT * FROM OPENQUERY(PostgreSQLPROD_RO,''' + REPLACE(@Request, '''', '''''') + ''')'

	INSERT INTO @tblResult
	EXECUTE(@Query)
	
	IF (SELECT COUNT(*) FROM @tblResult) > 0
		SET @Found = 1
		
	IF @Found = 0 AND @SplitBill = 1
	BEGIN
		SET @Division	= SUBSTRING(@PureProNumber, 1, dbo.AT('-', @PureProNumber, 1) - 1)
		SET @Pro		= SUBSTRING(@PureProNumber, dbo.AT('-', @PureProNumber, 1) + 1, 20)
		SET @Request	= 'SELECT Pro FROM TRK.Order WHERE div_code IN (''' + @Division + ''',''' + dbo.PADL(@Division, 2, '0') + ''') AND pro = ''' + @Pro + ''' AND cmpy_no = ' + CAST(@CompanyNumber AS Varchar)
		SET	@Query		= 'SELECT * FROM OPENQUERY(PostgreSQLPROD_RO,''' + REPLACE(@Request, '''', '''''') + ''')'
		
		INSERT INTO @tblResult
		EXECUTE(@Query)
		
		IF (SELECT COUNT(*) FROM @tblResult) > 0
			SET @Found = 1
	END
END

SELECT	Result,
		IIF(@Found = 1,'EXISTS','DOES NOT EXISTS') AS ProStatus
FROM	@tblResult