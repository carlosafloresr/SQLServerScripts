SET NOCOUNT ON

/*
UPDATE	IntercompanyReport_Accounts
SET		Inactive = 0
FROM	(
	SELECT	RecordId
	FROM	(
			SELECT DISTINCT [Company]
				  ,[Intercompany]
				  ,[Account]
				  ,MIN(RecordId) AS RecordId
			  FROM [GPCustom].[dbo].[IntercompanyReport_Accounts]
			  WHERE Company NOT IN ('FI','GSA','NDS','PTS')
					AND Intercompany NOT IN ('FI','GSA','NDS','PTS')
			  --where Company = 'GLSO' AND INACTIVE = 0
					--AND Intercompany = 'DNJ'
			GROUP BY [Company]
				  ,[Intercompany]
				  ,[Account]
			  --ORDER BY Company, Intercompany, Account
	  ) DATA
	) TMP
WHERE	IntercompanyReport_Accounts.RecordId = TMP.RecordId
*/

/*
UPDATE [IntercompanyReport_Accounts] SET Intercompany = 'RCCL' WHERE RecordId IN (1036,1039)
*/

--DECLARE @tblData Table (Inter Varchar(5), Acct Varchar(15))


--INSERT INTO @tblData (Inter, Acct) VALUES ('AIS','0-40-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('AIS','0-40-2199')
--INSERT INTO @tblData (Inter, Acct) VALUES ('IMCC','0-80-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('IMC','0-90-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('IMC','0-90-2199')
--INSERT INTO @tblData (Inter, Acct) VALUES ('IILS','0-10-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('OIS','0-15-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('OIS','0-15-2199')
--INSERT INTO @tblData (Inter, Acct) VALUES ('HMIS','0-45-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('HMIS','0-45-2199')
--INSERT INTO @tblData (Inter, Acct) VALUES ('PDS','0-33-2199')
--INSERT INTO @tblData (Inter, Acct) VALUES ('PDS','0-33-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('GIS','0-20-2100')
--INSERT INTO @tblData (Inter, Acct) VALUES ('GIS','0-20-2199')
--INSERT INTO @tblData (Inter, Acct) VALUES ('IMCMR','0-57-2100')


--SELECT	IA.*,
--		DA.*
--FROM	[GPCustom].[dbo].[IntercompanyReport_Accounts] IA
--		LEFT JOIN @tblData DA ON IA.Intercompany = DA.Inter AND IA.Account = DA.Acct
--WHERE	IA.INACTIVE = 0 
--		--and IA.company = 'glso'
--ORDER BY IA.Company, IA.Intercompany, IA.Account

DECLARE	@RecordId		Int,
		@Company		Varchar(5),
		@Account		Varchar(15),
		@Description	Varchar(100),
		@Query			Varchar(MAX)

DECLARE @tblAccount		Table (AcctText	Varchar(100))

DECLARE @tblData		Table (
		RecordId		Int, 
		Company			Varchar(5),
		CompanyDB		Varchar(5),
		InterCompany	Varchar(5),
		InterCpyDB		Varchar(5),
		Account			Varchar(15),
		Description		Varchar(100))

INSERT INTO @tblData
SELECT	IA.RecordId,
		ISNULL(CO.CompanyAlias, CO.CompanyId) AS Company,
		IA.Company AS Company_DB,
		ISNULL(CY.CompanyAlias, CY.CompanyId) AS Intercompany,
		IA.Intercompany AS Intercompany_DB,
		IA.Account,
		IA.Description
FROM	IntercompanyReport_Accounts IA
		LEFT JOIN Companies CO ON IA.Company = CO.CompanyId
		LEFT JOIN Companies CY ON IA.Intercompany = CY.CompanyId
WHERE	IA.INACTIVE = 0 
ORDER BY IA.Company, IA.Intercompany, IA.Account


DECLARE curGLAccounts CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RecordId, CompanyDB, Account
FROM	@tblData

OPEN curGLAccounts 
FETCH FROM curGLAccounts INTO @RecordId, @Company, @Account

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblAccount

	SET @Query = N'SELECT	RTRIM(G1.ACTDESCR) AS ACTDESCR
				FROM	' + @Company+ ' .dbo.GL00100 G1
						INNER JOIN ' + @Company+ ' .dbo.GL00105 G5 on G1.ACTINDX = G5.ACTINDX
				WHERE	G5.ACTNUMST IN (''' + @Account + ''')'

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	SET @Description = (SELECT AcctText FROM @tblAccount)

	UPDATE	IntercompanyReport_Accounts
	SET		Description = @Description
	WHERE	RecordId = @RecordId

	FETCH FROM curGLAccounts INTO @RecordId, @Company, @Account
END

CLOSE curGLAccounts
DEALLOCATE curGLAccounts

SELECT	IA.RecordId,
		ISNULL(CO.CompanyAlias, CO.CompanyId) AS Company,
		IA.Company AS Company_DB,
		ISNULL(CY.CompanyAlias, CY.CompanyId) AS Intercompany,
		IA.Intercompany AS Intercompany_DB,
		IA.Account,
		IA.Description
FROM	IntercompanyReport_Accounts IA
		LEFT JOIN Companies CO ON IA.Company = CO.CompanyId
		LEFT JOIN Companies CY ON IA.Intercompany = CY.CompanyId
WHERE	IA.INACTIVE = 0 
ORDER BY IA.Company, IA.Intercompany, IA.Account