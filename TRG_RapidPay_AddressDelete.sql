ALTER TRIGGER dbo.TRG_RapidPay_AddressDelete ON dbo.RapidPay_AddressDelete AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON

	DECLARE @Query		Varchar(MAX),
			@Company	Varchar(5),
			@VendorId	Varchar(15)

	SELECT	@Company	= RTRIM(Company),
			@VendorId	= RTRIM(VendorId)
	FROM	Inserted

    SET @Query = N'DELETE ' + @Company + '.dbo.SY01200 WHERE Master_ID = ''' + @VendorId + ''' AND ADRSCODE = ''REMIT'''
	EXECUTE(@Query)
		
	SET @Query = N'DELETE ' + RTRIM(@Company) + '.dbo.SY06000 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'''
	EXECUTE(@Query)

	SET @Query = N'DELETE ' + RTRIM(@Company) + '.dbo.PM00300 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'''
	EXECUTE(@Query)
END
GO
