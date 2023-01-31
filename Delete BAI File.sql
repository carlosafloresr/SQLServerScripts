DECLARE	@BAIFileName Varchar(50) = 'BAI_20160825_0220' + '.txt'

DELETE	BAI_Detail
WHERE	FK_Bank_HeaderId IN (SELECT BAI_HeaderId FROM BAI_Header WHERE BaiFileName = @BAIFileName)

DELETE	BAI_Header
WHERE	BaiFileName = @BAIFileName