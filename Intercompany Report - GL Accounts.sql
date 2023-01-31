DECLARE @tblAcctAlias	Table (
		Company			Varchar(5),
		Alias			Varchar(5))

SET NOCOUNT ON

INSERT INTO @tblAcctAlias VALUES ('ABS','ABS')
INSERT INTO @tblAcctAlias VALUES ('AIS','AIS')
INSERT INTO @tblAcctAlias VALUES ('DNJ','DNJ')
INSERT INTO @tblAcctAlias VALUES ('GIS','GIS')
INSERT INTO @tblAcctAlias VALUES ('GLSO','IMCNA')
INSERT INTO @tblAcctAlias VALUES ('GSA','GSA')
INSERT INTO @tblAcctAlias VALUES ('HMIS','H&M')
INSERT INTO @tblAcctAlias VALUES ('IILS','IMCC')
INSERT INTO @tblAcctAlias VALUES ('IMC','IMCG')
INSERT INTO @tblAcctAlias VALUES ('IMCC','IMCH')
INSERT INTO @tblAcctAlias VALUES ('OIS','OIS')
INSERT INTO @tblAcctAlias VALUES ('PDS','PDS')
INSERT INTO @tblAcctAlias VALUES ('PTS','PTS')
INSERT INTO @tblAcctAlias VALUES ('RCCL','RCCL')

--UPDATE	IntercompanyReport_Accounts
--SET		Intercompany = DATA.TEST
--FROM (
--SELECT	*, (SELECT TMP.Company FROM @tblAcctAlias TMP WHERE TMP.Alias = ltrim(replace(RIGHT(rtrim(description), 5), '- ', ''))) as test
--FROM	IntercompanyReport_Accounts DATA
--	) DATA
--WHERE	IntercompanyReport_Accounts.recordid = data.RecordId

SELECT	(SELECT TMP.Alias FROM @tblAcctAlias TMP WHERE TMP.Company = DATA.Company) AS Company,
		DATA.Company AS CompanyDB,
		(SELECT TMP.Alias FROM @tblAcctAlias TMP WHERE TMP.Company = DATA.Intercompany) AS Intercompany,
		DATA.Intercompany AS IntercompanyDB,
		Account,
		Description
FROM	IntercompanyReport_Accounts DATA
ORDER BY COMPANY, INTERCOMPANY