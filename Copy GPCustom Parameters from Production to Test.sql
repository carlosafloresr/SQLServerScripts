DELETE	Parameters
WHERE	VarType = 'C'
		AND ParameterCode in ('FSIVENDORCREACCT','FSIVENDORPREPAYDEBACCT','PIERPASS_ACCT_DEBIT','PIERPASS_ACCT_CREDIT','FSIACCRUDDEBIT','FSIACCRUDCREDIT','FSIVENDORDEBACCT')

INSERT INTO Parameters (Company, ParameterCode, Description, VarType, VarC)
SELECT	Company, ParameterCode, Description, VarType, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	VarType = 'C'
		--AND VarC NOT LIKE '%\\%'
		--AND dbo.OCCURS('-', VarC) > 1
		--AND SUBSTRING(VarC, 5, 1) = '-'
		AND ParameterCode in ('FSIVENDORCREACCT','FSIVENDORPREPAYDEBACCT','PIERPASS_ACCT_DEBIT','PIERPASS_ACCT_CREDIT','FSIACCRUDDEBIT','FSIACCRUDCREDIT','FSIVENDORDEBACCT')

/*
INSERT INTO GPCustom.dbo.Parameters (Company, ParameterCode, Description, VarType, VarC)
SELECT	Company,
		IIF(ParameterCode = 'PIERPASS_GLCODE', 'PIERPASS_ACCT_CREDIT','PIERPASS_ACCT_DEBIT') AS ParameterCode,
		IIF(ParameterCode = 'PIERPASS_GLCODE', 'PierPass Credit Account','PierPass Debit Account') AS Description,
		VarType,
		VarC
FROM	GPCustom.dbo.Parameters
WHERE	ParameterCode in ('PIERPASS_GLCODE','PIERPASS_BALANCEACCOUNT')
		--AND Company = 'PDS'
*/