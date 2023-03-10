SELECT	ISNULL(PMO.DocNumbr,PMH.DocNumbr) AS DocNumbr,
		ISNULL(PMO.BachNumb, PMH.BachNumb) AS BatchId,
		EXR.*
FROM	ExpenseRecovery EXR
		LEFT JOIN AIS..PM20000 PMO ON EXR.DocNumber = PMO.DocNumbr
		LEFT JOIN AIS..PM30200 PMH ON EXR.DocNumber = PMH.DocNumbr
WHERE	Company = 'AIS'
		AND ISNULL(PMO.DocNumbr,PMH.DocNumbr) IS not Null
		AND ISNULL(PMO.BachNumb, PMH.BachNumb) = 'AIS_HISTRECOVRY'
		AND EffDate > '10/30/2010'
		AND ItemNumber <> 0
ORDER BY DocNumber

-- SELECT * FROM AIS..PM20000
-- DELETE ExpenseRecovery WHERE Company = 'AIS'
SELECT * FROM GIS..PM10000
SELECT * FROM GIS..PM10100 WHERE VchrNmbr IN ('00000000000017844','00000000000017845')

00000000000021074

