USE GPCustom
GO

SELECT	ParameterCode,
		Company, 
		Description,
		VarType,
		VarC
FROM	Parameters
WHERE	Company IN ('AIS','PDS','GLSO') --AND ParameterCode = 'FSIVENDORDEBACCT'
		--AND SUBSTRING(VARC, 2, 1) = '-'
		--ParameterCode IN ('FSIVENDORPREPAYDEBACCT')
		AND ParameterCode IN ('ACCRUAL_CREDIT','FSIVENDORDEBACCT','FSIVENDORPREPAYDEBACCT','FSIVENDORPREPAYCREACCT','ICB_DEBACCT','ICB_CRDACCT','PREPAY_COMPANY','PIERPASS_ACCCODES','PIERPASS_GLCODE')
ORDER BY Company, ParameterCode

/*
UPDATE	Parameters
SET		VarC = '1-0-4199'
WHERE	ParameterCode = 'FSIVENDORPREPAYCREACCT'
		AND Company = 'GLSO'

UPDATE	Parameters
SET		VarC = '0-88-1866'
WHERE	ParameterCode = 'FSIVENDORPREPAYDEBACCT'
		AND Company = 'GLSO'

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	ParameterCode,
		'DNJ' AS Company,
		Description,
		VarType,
		VarC
FROM	Parameters
WHERE	ParameterCode IN ('FSIACCRUDCREDIT','FSIACCRUDDEBIT') --('ACCRUAL_CREDIT','FSIVENDORDEBACCT','FSIVENDORPREPAYDEBACCT','FSIVENDORPREPAYCREACCT','ICB_DEBACCT','ICB_CRDACCT','PREPAY_COMPANY','PIERPASS_ACCCODES','PIERPASS_GLCODE')
		AND COMPANY = 'GLSO'
--SELECT	'ICB_DEBACCT',
--		'GIS' AS Company,
--		'ICB Debit Account' AS Description,
--		'C' AS VarType,
--		'1-00-5199' AS VarC

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	'PIERPASS_GLCODE',
		'PTS' AS Company,
		'Pier Pass GL Account' AS Description,
		'C' AS VarType,
		'0-00-1866' AS VarC

INSERT INTO Parameters 
		(ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	ParameterCode,
		Company,
		Description,
		VarType,
		VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN ('FSIVENDORDEBACCT','FSIVENDORPREPAYDEBACCT','FSIVENDORPREPAYCREACCT','ICB_DEBACCT','ICB_CRDACCT','PREPAY_COMPANY','PIERPASS_ACCCODES','PIERPASS_GLCODE')
ORDER BY Company, ParameterCode

*/