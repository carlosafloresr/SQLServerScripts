ALTER PROCEDURE USP_CheckIfVendorExistInAllGP
		@Company		Varchar(5),
		@VendorId		Varchar(25)
AS
DECLARE	@tmpCompany		Varchar(5),
		@Query			Varchar(MAX)

DECLARE	@tblCompanies2	Table (
		Company			Varchar(5),
		LastVendorId	Int)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyId)
FROM	GPCustom.dbo.Companies 
WHERE	Trucking = 1
		AND IsTest = 0
		AND CompanyId <> @Company

OPEN curCompanies 
FETCH FROM curCompanies INTO @tmpCompany

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + @tmpCompany + ''', VendorId FROM ' + @tmpCompany + '.dbo.PM00200 WHERE VendorId = ''' + @VendorId + ''''

	INSERT INTO @tblCompanies2
	EXECUTE(@Query)
	
	FETCH FROM curCompanies INTO @tmpCompany
END

CLOSE curCompanies
DEALLOCATE curCompanies

IF EXISTS(SELECT LastVendorId FROM @tblCompanies2)
BEGIN
	UPDATE	##tmpCompanyVendor
	SET		InOtherDBs = 1
	WHERE	Company = @Company
			AND LastVendorId = @VendorId
END
