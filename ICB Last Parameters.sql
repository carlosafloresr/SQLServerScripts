SELECT	Company,
		ParameterCode,
		IIF(ParameterCode = 'ICB_DEBACCT', 'Payable', 'Receivable') AS ParameterType,
		VarC AS Value
FROM	PARAMETERS
WHERE	ParameterCode IN ('ICB_CREDIT_ACCT','ICB_DEBIT_ACCT','ICB_DEBACCT')
		--ParameterCode like '%icb%'
ORDER BY company, 4, ParameterCode

