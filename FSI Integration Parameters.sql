DECLARE	@tblParameters Table (
		Company			Varchar(5),
		ParameterCode	Varchar(100),
		Description		Varchar(100),
		ParValue		Varchar(100),
		Integration		Varchar(20))
 
INSERT INTO @tblParameters
SELECT	Company,
		ParameterCode,
		Description,
		VarC AS ParValue,
		'FSI' AS Integration
FROM	Parameters
WHERE	ParameterCode LIKE 'FSI%'
		AND ParameterCode NOT IN ('FSIACCRUDDEBIT','FSIACCRUDCREDIT')
		AND VarType = 'C'
ORDER BY Company, ParameterCode

INSERT INTO @tblParameters
SELECT	Company,
		ParameterCode,
		Description,
		VarC AS ParValue,
		'PIERPASS' AS Integration
FROM	Parameters
WHERE	ParameterCode LIKE 'PIERPASS_ACCT_%'
		AND VarType = 'C'
		AND Company NOT IN ('ALL','PTS')
ORDER BY Company, ParameterCode

INSERT INTO @tblParameters
SELECT	Company,
		ParameterCode,
		Description,
		VarC AS ParValue,
		'PREPAY' AS Integration
FROM	Parameters
WHERE	ParameterCode IN ('FSIACCRUDDEBIT','FSIACCRUDCREDIT')
		AND VarType = 'C'
ORDER BY Company, ParameterCode

INSERT INTO @tblParameters
SELECT	Company,
		ParameterCode,
		Description,
		VarC AS ParValue,
		'' AS Integration
FROM	Parameters
WHERE	ParameterCode = 'DEMURRAGE_ACCCODE'
		AND VarType = 'C'
ORDER BY Company, ParameterCode


INSERT INTO @tblParameters
SELECT	Company,
		ParameterCode,
		Description,
		VarC AS ParValue,
		'ICB' AS Integration
FROM	Parameters
WHERE	ParameterCode LIKE 'ICB_%'
		AND VarType = 'C'
ORDER BY Company, ParameterCode

INSERT INTO @tblParameters
SELECT	Company,
		ParameterCode,
		Description,
		VarC AS ParValue,
		'DEMURRAGE' AS Integration
FROM	Parameters
WHERE	ParameterCode like 'DEMURRAGE%'
ORDER BY Company, ParameterCode

SELECT	*
FROM	@tblParameters
WHERE	dbo.OCCURS('-', ParValue) > 1
		AND Company = 'glso'
		--AND PARAMETERCODE IN ('FSIACCRUDCREDIT','FSIACCRUDDEBIT')
ORDER BY Integration, Company, ParameterCode