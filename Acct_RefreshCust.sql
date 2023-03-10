USE [Accounting]
GO
/****** Object:  StoredProcedure [dbo].[Acct_RefreshCust]    Script Date: 8/18/2016 2:49:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE Acct_RefreshCust
*/
ALTER PROCEDURE [dbo].[Acct_RefreshCust]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE	@Query			Varchar(MAX),
			@LastDate		Date = DATEADD(dd, -1, GETDATE()),
			@Company		Int

	DECLARE @tblCustomers	Table
			(Company			Int, 
			CUSTNMBR		Varchar(15), 
			CUSTNAME		Varchar(65), 
			CUSTCLAS		Varchar(15))

	DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	DYN.CmpanyId
		FROM	LENSASQL001.DYNAMICS.dbo.View_AllCompanies DYN
				INNER JOIN LENSASQL001.GPCustom.dbo.Companies COM ON DYN.InterId = COM.CompanyId
		WHERE	COM.SWSCustomers = 1
				AND COM.IsTest = 0

	OPEN curCompanies 
	FETCH FROM curCompanies INTO @Company

	-- *****************************************************
	-- * Create Temp Table from GP Databases
	-- *****************************************************
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Query = N'SELECT ''' + CAST(@Company AS Varchar) + ''' AS [Company] 
					,RTRIM(CUSTNMBR) AS [CUSTNMBR]
					,RTRIM(CUSTNAME) AS [CUSTNAME]
					,RTRIM(CUSTCLAS) AS [CUSTCLAS]
			FROM	LENSASQL001.IMC.dbo.RM00101 
			WHERE	CustClas IN (''PD'',''PDM'')
					AND ModifDT >= ''' + CONVERT(Char(10), @LastDate, 101) + ''''
		
		INSERT INTO @tblCustomers
			EXECUTE(@Query)

		FETCH FROM curCompanies INTO @Company
	END

	CLOSE curCompanies
	DEALLOCATE curCompanies

	SET NOCOUNT OFF

	-- *****************************************************
	-- * Insert Data into Customer Table
	-- *****************************************************
	INSERT INTO ILSSQL01.Accounting.dbo.Customers
	SELECT	TMP.Company
			,RTRIM(TMP.CUSTNMBR) AS [CUSTNMBR]
			,RTRIM(TMP.CUSTNAME) AS [CUSTNAME]
			,RTRIM(TMP.CUSTCLAS) AS [CUSTCLAS]
	FROM	@tblCustomers TMP
			LEFT JOIN Accounting.dbo.Customers ACC ON TMP.Company = ACC.Company AND TMP.CUSTNMBR = ACC.CUSTNMBR
	WHERE	ACC.CUSTNMBR IS NULL
END