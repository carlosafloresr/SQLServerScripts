SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@CompanyAlias	Varchar(10),
		@Query			Varchar(MAX),
		@DOSCommand		Varchar(4000),
		@DatePortion	Char(6) = dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(dbo.PADL(YEAR(GETDATE()), 4, '0'), 2)
		 
DECLARE	@tblCustomers	Table	(
		Customer_Number			Varchar(20),
		Customer_Name			Varchar(100),
		Customer_StatementName	Varchar(100),
		Company_Code			Varchar(5),
		National_Account		Varchar(20),
		Address_Line1			Varchar(100),
		Address_Line2			Varchar(100),
		City					Varchar(50),
		State					Varchar(30),
		Zip_Code				Varchar(30),
		Customer_Group			Varchar(30),
		PayTermsId				Varchar(30),
		DueDays					Varchar(10))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyID) AS CompanyId
FROM	DYNAMICS.dbo.View_Companies
WHERE	CompanyID IN ('AIS', 'DNJ', 'GIS', 'HMIS', 'IMC', 'OIS', 'PDS', 'GLSO')
ORDER BY 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @CompanyAlias = (SELECT CompanyAlias FROM View_CompaniesAndAgents WHERE CompanyId = @Company)

	SET @Query = 'SELECT RTRIM(RM.CUSTNMBR), 
	RTRIM(RM.CUSTNAME), 
	RTRIM(IIF(RM.STMTNAME = '''', RM.CUSTNMBR, RM.STMTNAME)), 
	''' + @CompanyAlias + ''',
	RTRIM(RM.CPRCSTNM),
	RTRIM(RM.ADDRESS1),
	RTRIM(RM.ADDRESS2) + '' '' + RTRIM(RM.ADDRESS3),
	RTRIM(RM.CITY),
	RTRIM(RM.STATE),
	RTRIM(RM.ZIP),
	'''',
	RM.PYMTRMID,
	SY.DUEDTDS
	FROM ' + @Company + '.dbo.RM00101 RM
		LEFT JOIN ' + @Company + '.dbo.SY03300 SY ON RM.PYMTRMID = SY.PYMTRMID
	WHERE LEN(RTRIM(RM.CUSTNMBR)) > 1 
	AND RM.Inactive = 0 
	ORDER BY 1'

	INSERT INTO @tblCustomers
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	Company_Code,
		Customer_Number,
		Customer_Name,
		PayTermsId,
		ISNULL(DueDays,'') AS DueDays
FROM	@tblCustomers
ORDER BY 1,2