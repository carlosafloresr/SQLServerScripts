SELECT	*,
		SUBSTRING(ACTNUMST, 1, 1) + '-' + dbo.PADL(SUBSTRING(ACTNUMST, 3, 1), 2, '0') + '-' + RIGHT(RTRIM(ACTNUMST), 4)
FROM	Integrations_AP
WHERE	BatchId = 'EFSMC_03052018'
		AND Company = 'IMC'
		AND dbo.AT('-', ACTNUMST, 2) <> 5
order by ACTNUMST

update	Integrations_AP
set		ACTNUMST = SUBSTRING(ACTNUMST, 1, 1) + '-' + dbo.PADL(SUBSTRING(ACTNUMST, 3, 1), 2, '0') + '-' + RIGHT(RTRIM(ACTNUMST), 4)
WHERE	BatchId = 'EFSMC_03052018'
		AND dbo.AT('-', ACTNUMST, 2) <> 5
		AND Company = 'IMC'