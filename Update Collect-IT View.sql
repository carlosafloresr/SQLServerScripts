
DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE	@tblExistent TABLE (Company Varchar(5) Null, Object_Id Int Null)

DECLARE curGPCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	GPCustom.dbo.Companies 
WHERE	IsTest = 0

OPEN curGPCompanies 
FETCH FROM curGPCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + RTRIM(@Company) + ''' AS Company, object_id FROM ' + RTRIM(@Company) + '.sys.views WHERE name = ''CollectITCustomerAddress'''
		
	INSERT INTO @tblExistent
	EXECUTE(@Query)

	IF @@ROWCOUNT > 0
	BEGIN
		SET @Query = N'USE [' + RTRIM(@Company) + ']'
		PRINT @Query
		EXECUTE(@Query)

		SET @Query = N'ALTER VIEW [dbo].[CollectITCustomerAddress]
AS
SELECT	''' + RTRIM(@Company) + ''' AS EnterpriseNumber
		,a.CUSTNMBR AS CustomerNumber
		,a.ADRSCODE AS ERPAddrID
		,CASE WHEN RTRIM(ISNULL(a.CNTCPRSN, '''')) = '''' THEN c.CUSTNAME
			  ELSE a.CNTCPRSN
		 END AS ContactPerson
		,a.ADDRESS1
		,a.ADDRESS2
		,a.ADDRESS3
		,a.COUNTRY
		,a.CITY
		,a.STATE
		,a.ZIP AS ZipCode
		,a.PHONE1 AS CustomerPhone1
		,a.PHONE2 AS CustomerPhone2
		,a.PHONE3 AS CustomerPhone3
		,a.FAX AS CustomerFax
		,CAST(a.DEX_ROW_TS AS DATETIME) AS ModifiedAddress
		,CASE WHEN RTRIM(ISNULL(CAST(b.EmailToAddress AS NVARCHAR(max)), '''')) = '''' THEN CAST(b.EmailToAddress AS NVARCHAR(max))
			  ELSE CAST(b.INET1 AS NVARCHAR(max))
		 END AS CustomerEmail
FROM	dbo.RM00102 a
		JOIN dbo.RM00101 c ON a.CUSTNMBR = c.CUSTNMBR
		LEFT JOIN SY01200 b ON a.CUSTNMBR = b.Master_ID AND a.ADRSCODE = b.ADRSCODE'

		EXECUTE(@Query)
	END

	FETCH FROM curGPCompanies INTO @Company
END

CLOSE curGPCompanies
DEALLOCATE curGPCompanies

--SELECT * FROM @tblExistent