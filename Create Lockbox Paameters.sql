--SELECT * FROM PARAMETERS

DECLARE @Company Varchar(5) = 'PDS'

INSERT INTO Parameters (Company, ParameterCode, [Description], VarType, VarC)
SELECT	@Company,
		'CHECKID_BOA',
		'Check book Id for Bank of America',
		'C' AS VarType,
		RTRIM(CHEKBKID) AS VarC
FROM	PDS.dbo.CM00100
WHERE	CHEKBKID = 'BOA DEPOSIT'

INSERT INTO Parameters (Company, ParameterCode, [Description], VarType, VarC)
SELECT	@Company,
		'CHECKID_REGIONS',
		'Check book Id for Regions',
		'C',
		RTRIM(CHEKBKID) 
FROM	PDS.dbo.RM40101

SELECT	*
FROM	Parameters
WHERE	ParameterCode in ('CHECKID_BOA','CHECKID_REGIONS')
ORDER BY Company