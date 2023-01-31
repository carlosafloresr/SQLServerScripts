/*
EXECUTE USP_FindNextVendorIdforGP
*/
ALTER PROCEDURE USP_FindNextVendorIdforGP
AS
SET NOCOUNT ON

DECLARE	@NextVendorId	Int,
		@Query			Varchar(MAX),
		@Company		Varchar(5),
		@VendorId		Int,
		@RetunrValue	Int

CREATE TABLE ##tmpCompanyVendor (
		Company			Varchar(5),
		LastVendorId	Int,
		InOtherDBs		Bit)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyId)
FROM	GPCustom.dbo.Companies 
WHERE	Trucking = 1
		AND IsTest = 0

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + @Company + ''', MAX(CAST(VendorId AS Int)) + 1 AS VendorId, 0 FROM ' + @Company + '.dbo.PM00200 WHERE ISNUMERIC(VendorId) = 1'

	INSERT INTO ##tmpCompanyVendor
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DECLARE	@tmpCompany	Varchar(5)

DECLARE curVendorCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		LastVendorId
FROM	##tmpCompanyVendor
ORDER BY
		LastVendorId DESC

OPEN curVendorCompanies 
FETCH FROM curVendorCompanies INTO @Company, @VendorId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_CheckIfVendorExistInAllGP @Company, @VendorId

	FETCH FROM curVendorCompanies INTO @Company, @VendorId
END

CLOSE curVendorCompanies
DEALLOCATE curVendorCompanies

SELECT	@RetunrValue = MIN(LastVendorId)
FROM	##tmpCompanyVendor
WHERE	InOtherDBs = 0

DROP TABLE ##tmpCompanyVendor

PRINT @RetunrValue

RETURN @RetunrValue