DECLARE	@Company	Varchar(5) = 'PDS'

SELECT	*, 
		CAST(RecordId AS Varchar) + ',' AS Record,
		'''' + DocRef + ''',' AS Document6
FROM	MissingIntegrations
where	Company = @Company
		--batchid = '9FSI20200604_1633'
ORDER BY 
		Company, 
		BatchId, 
		Integration, 
		CustVnd

/*
SELECT	DISTINCT Company,
		BatchId,
		Integration
FROM	MissingIntegrations
ORDER BY
		Company,
		BatchId,
		Integration
*/