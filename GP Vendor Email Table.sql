DECLARE	@Company		Varchar(5),
		@Query			Varchar(MAX)

DECLARE @tblVndEmal		Table (
		Company			Varchar(5),
		VendorId		Varchar(15),
		VendorName		Varchar(75),
		VendorClass		Varchar(10),
		AddressCode		Varchar(20),
		EmailTo			Varchar(100),
		EmailCC			Varchar(100),
		EmailBCC		Varchar(100),
		OtherEmail		Varchar(100))

DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	Companies 
WHERE	IsTest = 0
		AND Trucking = 1

OPEN Transaction_Companies 
FETCH FROM Transaction_Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + @Company + ''', RTRIM(Master_ID)
		,RTRIM(VND.VENDNAME)
		,RTRIM(VNDCLSID)
		,RTRIM(ADRSCODE)
		,RTRIM(CAST(EmailToAddress AS Varchar(100)))
		,RTRIM(CAST(EmailCcAddress AS Varchar(100)))
		,RTRIM(CAST(EmailBccAddress AS Varchar(100)))
		,RTRIM(CAST(INET1 AS Varchar(100)))
FROM	' + @Company + '.dbo.PM00200 VND
		INNER JOIN ' + @Company + '.dbo.SY01200 EML ON VND.VENDORID = EML.Master_ID
WHERE	Master_Type = ''VEN''
ORDER BY 2'
		
	INSERT INTO @tblVndEmal
	EXECUTE(@Query)

	FETCH FROM Transaction_Companies INTO @Company
END

CLOSE Transaction_Companies
DEALLOCATE Transaction_Companies

SELECT	*
FROM	@tblVndEmal
WHERE	VendorClass = 'TRD'
ORDER BY 1,3