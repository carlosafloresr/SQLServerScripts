DECLARE	@CompanyId	Varchar(5),
		@Exist		Bit,
		@Query		Varchar(MAX)

DECLARE @tblTrigger Table (TrgName Varchar(50))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT RTRIM(CompanyId) FROM DYNAMICS.dbo.View_Companies

OPEN curCompanies 
FETCH FROM curCompanies INTO @CompanyId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Company: ' + @CompanyId

	DELETE @tblTrigger

	SET @Query = 'SELECT Name FROM ' + @CompanyId + '.SYS.OBJECTS WHERE Name = ''TRG_SY06000'''

	INSERT INTO @tblTrigger
	EXECUTE(@Query)

	SET @Exist = IIF((SELECT COUNT(*) FROM @tblTrigger) > 0, 1, 0)

	SET @Query = IIF(@Exist = 1, 'ALTER','CREATE') + ' TRIGGER ' + @CompanyId + '.dbo.TRG_SY06000 ON dbo.SY06000
   FOR INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @VendorId	Varchar(12),
			@Company	Varchar(5) = DB_NAME(),
			@DataDate	Date,
			@RecordId	Int

	SELECT	@VendorId = RTRIM(VendorId),
			@DataDate = EFTPrenoteDate
	FROM	Inserted

	IF EXISTS(SELECT GP_EFT_VendorId FROM GPCustom.dbo.GP_EFT_Vendors WHERE Company = @Company AND VendorId = @VendorId)
    BEGIN
		IF @DataDate > ''01/01/2000''
			UPDATE	GPCustom.dbo.GP_EFT_Vendors
			SET		EFTPrenoteDate = @DataDate,
					Changed	 = 1
			WHERE	Company = @Company
					AND VendorId = @VendorId
	END
END'

	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @CompanyId
END

CLOSE curCompanies
DEALLOCATE curCompanies
