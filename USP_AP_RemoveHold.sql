USE GPCustom
GO

/*
EXECUTE USP_AP_RemoveHold 'IMC'
*/
ALTER PROCEDURE USP_AP_RemoveHold
		@Company		Varchar(5)
AS
-- Remove the HOLD of those transactions now with documents under FileBound
SET NOCOUNT ON

DECLARE	@ProjectId		Int,
		@Vendor			Varchar(15),
		@InvoiceNo		Varchar(30),
		@Counter		Int,
		@Found			Int,
		@Query			Varchar(MAX)

DECLARE	@tblHoldData	Table (
		Company			Varchar(5),
		VendorId		Varchar(15),
		Document		Varchar(30),
		WithDocs		Bit)

DECLARE @tblAPRecs		Table (
		VendorId		Varchar(15),
		Document		Varchar(30))

SET	@ProjectId	= (SELECT ProjectId FROM GPCustom.dbo.DexCompanyProjects WHERE ProjectType = 'AP' AND Company = @Company)

SET @Query = N'SELECT RTRIM(VENDORID), RTRIM(DOCNUMBR) FROM ' + @Company + '.dbo.PM20000 WHERE HOLD = 1 AND VOIDED = 0 AND BACHNUMB LIKE ''%FSI%'''

INSERT INTO @tblAPRecs
EXECUTE(@Query)

DECLARE curAPOnHold CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblAPRecs

OPEN curAPOnHold 
FETCH FROM curAPOnHold INTO @Vendor, @InvoiceNo

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	@Counter = COUNT(*)
	FROM	PRIFBSQL01P.FB.dbo.Files 
	WHERE	ProjectId = @ProjectId
			AND	Field8 = @Vendor
			AND	Field4 = @InvoiceNo

	IF @Counter > 0
		INSERT INTO @tblHoldData (Company, VendorId, Document, WithDocs) VALUES (@Company, @Vendor, @InvoiceNo, @Counter)

	FETCH FROM curAPOnHold INTO @Vendor, @InvoiceNo
END

CLOSE curAPOnHold
DEALLOCATE curAPOnHold

SET @Found = (SELECT COUNT(*) FROM @tblHoldData)

IF @Found > 0
BEGIN
	PRINT @Company + ' on hold found: ' + CAST(@Found AS Varchar)

	DECLARE curAPOnHold CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	VendorId, Document
	FROM	@tblHoldData

	OPEN curAPOnHold 
	FETCH FROM curAPOnHold INTO @Vendor, @InvoiceNo

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Query = N'UPDATE ' + @Company + '.dbo.PM20000 SET HOLD = 0 WHERE VENDORID = ''' + @Vendor + ''' AND DOCNUMBR = ''' + @InvoiceNo + ''''
	
		EXECUTE(@Query)

		FETCH FROM curAPOnHold INTO @Vendor, @InvoiceNo
	END

	CLOSE curAPOnHold
	DEALLOCATE curAPOnHold
END