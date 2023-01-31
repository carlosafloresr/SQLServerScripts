

DECLARE @tblAcctAlias	Table (
		Company			Varchar(5),
		Alias			Varchar(5))

INSERT INTO @tblAcctAlias VALUES ('ABS','ABS')
INSERT INTO @tblAcctAlias VALUES ('AIS','AIS')
INSERT INTO @tblAcctAlias VALUES ('DNJ','DNJ')
INSERT INTO @tblAcctAlias VALUES ('GIS','GIS')
INSERT INTO @tblAcctAlias VALUES ('GLSO','IMCNA')
INSERT INTO @tblAcctAlias VALUES ('GSA','GSA')
INSERT INTO @tblAcctAlias VALUES ('HMIS','H&M')
INSERT INTO @tblAcctAlias VALUES ('HMIS','HMIS')
INSERT INTO @tblAcctAlias VALUES ('IILS','IMCC')
INSERT INTO @tblAcctAlias VALUES ('IMC','IMCG')
INSERT INTO @tblAcctAlias VALUES ('IMCC','IMCH')
INSERT INTO @tblAcctAlias VALUES ('OIS','OIS')
INSERT INTO @tblAcctAlias VALUES ('PDS','PDS')
INSERT INTO @tblAcctAlias VALUES ('PTS','PTS')
INSERT INTO @tblAcctAlias VALUES ('RCCL','RCCL')
INSERT INTO @tblAcctAlias VALUES ('GLSO','IGS')
INSERT INTO @tblAcctAlias VALUES ('NDS','NDS')
INSERT INTO @tblAcctAlias VALUES ('IMC','IMC')

--UPDATE	IntercompanyReport_Accounts
--SET		Description = REPLACE(Description, 'HMIS-', 'H&M')
--WHERE	Description LIKE '%hmis-%'

UPDATE	IntercompanyReport_Accounts
SET		Intercompany = DATA.TEXTS
FROM	(
SELECT	RecordId, (SELECT Company FROM @tblAcctAlias TMP WHERE TMP.Alias = LTRIM(RTRIM(REPLACE(RIGHT(Description, 4), '-', '')))) AS TEXTS
FROM	IntercompanyReport_Accounts DAT
WHERE	Account LIKE '%99'
		) DATA
WHERE	IntercompanyReport_Accounts.RecordId = DATA.RecordId