USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GP_BOA_Export_Customers]    Script Date: 6/8/2022 11:20:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GP_BOA_Export_Customers
*/
ALTER PROCEDURE [dbo].[USP_GP_BOA_Export_Customers]
AS
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
		Customer_Group			Varchar(30))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyID) AS CompanyId
FROM	DYNAMICS.dbo.View_Companies
WHERE	CompanyID IN (SELECT CompanyId FROM Companies_Parameters WHERE ParameterCode = 'BOA_CUSTOMER' AND ParBit = 1)
ORDER BY 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @CompanyAlias = ISNULL((SELECT CompanyAlias FROM View_CompaniesAndAgents WHERE CompanyId = @Company), @Company)

	SET @Query = 'SELECT RTRIM(CUSTNMBR), 
	RTRIM(CUSTNAME), 
	RTRIM(IIF(STMTNAME = '''', CUSTNMBR, STMTNAME)), 
	''' + @CompanyAlias + ''',
	RTRIM(CPRCSTNM),
	RTRIM(ADDRESS1),
	RTRIM(ADDRESS2) + '' '' + RTRIM(ADDRESS3),
	RTRIM(CITY),
	RTRIM(STATE),
	RTRIM(ZIP),
	''''
	FROM ' + @Company + '.dbo.RM00101 
	WHERE LEN(RTRIM(CUSTNMBR)) > 1 
	AND Inactive = 0 
	ORDER BY 1'

	INSERT INTO @tblCustomers
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DROP TABLE IF EXISTS ##tmpBOACustomers;

SELECT	*
INTO	##tmpBOACustomers
FROM	(
		SELECT	Customer_Number + '|' +
				Customer_Name + '|' +
				Customer_StatementName + '|' +
				Company_Code + '|' +
				National_Account + '|' +
				Address_Line1 + '|' +
				Address_Line2 + '|' +
				City + '|' +
				State + '|' +
				Zip_Code + '|' +
				Customer_Group AS TextValue,
				ROW_NUMBER() OVER(ORDER BY Company_Code, Customer_Number) AS RowNumber
		FROM	@tblCustomers
		) DATA
ORDER BY 2

SET @Query = '"SELECT ''Customer_Number|Customer_Name|Customer_StatementName|Company_Code|National_Account|Address_Line1|Address_Line2|City|State|Zip_Code|Customer_Group'' '
SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpBOACustomers" QUERYOUT \\priapint01p\bankfiles$\Outbound\Customer\IMCC_Customers_' + @DatePortion + '.txt -c -t, -T'
--PRINT @DOSCommand
EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output

DROP TABLE IF EXISTS ##tmpBOACustomers;

-- select * from ais.dbo.rm00101