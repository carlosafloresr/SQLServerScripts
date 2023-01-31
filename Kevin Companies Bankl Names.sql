SET NOCOUNT ON

DECLARE @Company			Varchar(5),
		@Query				Varchar(2500)

DECLARE	@tblBanks			Table
		(Company			Varchar(5),
		Series				Int,
		CustomerVendor_ID	Varchar(15),
		ADRSCODE			Varchar(20),
		VendorId			Varchar(15),
		VendName			Varchar(100),
		BankName			Varchar(50),
		EFTTransitRoutingNo	Varchar(30))

DECLARE curBankNames CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId)
FROM	DYNAMICS.dbo.View_AllCompanies

OPEN curBankNames 
FETCH FROM curBankNames INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ''' + @Company + ''', Series, CustomerVendor_ID, ADRSCODE,
	E.VENDORID, V.VENDNAME, E.BANKNAME, EFTTransitRoutingNo
FROM SY06000 E JOIN PM00200 V ON V.vendorID = E.VENDORID'
		
	INSERT INTO @tblBanks
	EXECUTE(@Query)

	FETCH FROM curBankNames INTO @Company
END

CLOSE curBankNames
DEALLOCATE curBankNames

SELECT	*
FROM	@tblBanks
ORDER BY 1, 2,3