SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@Company		vARCHAR(5)

DECLARE	@tblAccounts	Table (
		ACTINDX						Int,
		ACTNUMST					Varchar(15),
		ACTDESCR					Varchar(100))

DECLARE	@tblData		Table (
		Company						Varchar(10),
		NC_Trigger_account			Varchar(100),
		NC_Src_Account				Varchar(100),
		NC_Src_IC_Account			Varchar(100),
		Intercompany				Varchar(10),
		NC_Dest_Account				Varchar(150),
		NC_Dest_IC_Account			Varchar(150))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(INTERID)
FROM	DYNAMICS.dbo.View_AllCompanies
WHERE	INTERID IN ('AIS','DNJ','GIS','HMIS','IMCC','IMC','OIS','PDS')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + @Company + ''' AS Company,
		NC_Trigger_account_index = (SELECT ACTNUMST + '' '' + ACTDESCR FROM (SELECT G5.ACTINDX, RTRIM(G5.ACTNUMST) AS ACTNUMST, RTRIM(G1.ACTDESCR) AS ACTDESCR FROM ' + @Company + '.dbo.GL00105 G5 INNER JOIN ' + @Company + '.dbo.GL00100 G1 ON G5.ACTINDX = G1.ACTINDX) ACCT WHERE ACCT.ACTINDX = NCIC0003.NC_Trigger_account_index),
		NC_Src_Account_Index = (SELECT ACTNUMST + '' '' + ACTDESCR FROM (SELECT G5.ACTINDX, RTRIM(G5.ACTNUMST) AS ACTNUMST, RTRIM(G1.ACTDESCR) AS ACTDESCR FROM ' + @Company + '.dbo.GL00105 G5 INNER JOIN ' + @Company + '.dbo.GL00100 G1 ON G5.ACTINDX = G1.ACTINDX) ACCT WHERE ACCT.ACTINDX = NCIC0003.NC_Src_Account_Index),
		NC_Src_IC_Account_Index = (SELECT ACTNUMST + '' '' + ACTDESCR FROM (SELECT G5.ACTINDX, RTRIM(G5.ACTNUMST) AS ACTNUMST, RTRIM(G1.ACTDESCR) AS ACTDESCR FROM ' + @Company + '.dbo.GL00105 G5 INNER JOIN ' + @Company + '.dbo.GL00100 G1 ON G5.ACTINDX = G1.ACTINDX) ACCT WHERE ACCT.ACTINDX = NCIC0003.NC_Src_IC_Account_Index),
		INTERID,
		NC_Dest_Account_Index,
		NC_Dest_IC_Account_Index
FROM	' + @Company + '.dbo.NCIC0003
		INNER JOIN DYNAMICS.dbo.View_AllCompanies VAL ON NCIC0003.CMPANYID = VAL.CMPANYID'
	
	INSERT INTO @tblData
	EXECUTE(@Query)
	
	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Intercompany
FROM	@tblData

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblAccounts
	SET @Query = 'SELECT G5.ACTINDX, RTRIM(G5.ACTNUMST) AS ACTNUMST, RTRIM(G1.ACTDESCR) AS ACTDESCR FROM ' + @Company + '.dbo.GL00105 G5 INNER JOIN ' + @Company + '.dbo.GL00100 G1 ON G5.ACTINDX = G1.ACTINDX'
	
	INSERT INTO @tblAccounts
	EXECUTE(@Query)

	UPDATE	@tblData
	SET		NC_Dest_Account		= IIF(LEN(NC_Dest_Account) < 10, (SELECT LEFT(ACTNUMST + ' ' + ACTDESCR, 100) FROM @tblAccounts DAT WHERE DAT.ACTINDX = CAST([@tblData].NC_Dest_Account AS Int)), NC_Dest_Account),
			NC_Dest_IC_Account	= IIF(LEN(NC_Dest_IC_Account) < 10, (SELECT LEFT(ACTNUMST + ' ' + ACTDESCR, 100) FROM @tblAccounts DAT WHERE DAT.ACTINDX = CAST([@tblData].NC_Dest_IC_Account AS Int)), NC_Dest_IC_Account)
	WHERE	Intercompany = @Company
	
	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
FROM	@tblData