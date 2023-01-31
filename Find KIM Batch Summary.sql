/*
SELECT	KIMBatchId,
		PostingDate,
		SUM(Total) AS BatchTotal
FROM	KarmakIntegration
WHERE	KIMBatchId IS NOT Null
		--AND AcctApproved = 1
GROUP BY KIMBatchId, PostingDate
*/

SELECT	KIM.KIMBatchId,
		KIM.PostingDate,
		SUM(KIM.Total) AS BatchTotal
FROM	KarmakIntegration KIM
WHERE	RTRIM(InvoiceNumber) + '/' + RTRIM(UnitNumber) + '/' + LEFT(Description1, 30) IN (
		SELECT	DSCRIPTN
		FROM	IMC.dbo.GL20000
		WHERE	SOURCDOC = 'GJ'
				AND LASTUSER = 'KIM_Integration'
				AND GPCustom.dbo.OCCURS('/', DSCRIPTN) > 1
				AND YEAR(ORPSTDDT) > 2009)
		OR RTRIM(InvoiceNumber) + '/' + RTRIM(UnitNumber) + '/' + LEFT(Description1, 30) IN (
		SELECT	DSCRIPTN
		FROM	IMC.dbo.GL30000
		WHERE	SOURCDOC = 'GJ'
				AND LEFT(ORGNTSRC, 2) = 'KM'
				AND GPCustom.dbo.OCCURS('/', DSCRIPTN) > 1
				AND YEAR(ORPSTDDT) > 2009)
GROUP BY KIMBatchId, PostingDate

SELECT	ORGNTSRC,
		ORPSTDDT,
		SUM(ORCRDAMT) AS TOTAL
FROM	IMC.dbo.GL20000
WHERE	SOURCDOC = 'GJ'
		AND LEFT(ORGNTSRC, 2) = 'KM'
		AND YEAR(ORPSTDDT) > 2009
		AND DSCRIPTN IN (SELECT	RTRIM(InvoiceNumber) + '/' + RTRIM(UnitNumber) + '/' + LEFT(Description1, 30)
						 FROM	KarmakIntegration)
GROUP BY ORGNTSRC,
		ORPSTDDT
UNION
SELECT	ORGNTSRC,
		ORPSTDDT,
		SUM(ORCRDAMT) AS TOTAL
FROM	IMC.dbo.GL30000
WHERE	SOURCDOC = 'GJ'
		AND LEFT(ORGNTSRC, 2) = 'KM'
		AND YEAR(ORPSTDDT) > 2009
		AND DSCRIPTN IN (SELECT	RTRIM(InvoiceNumber) + '/' + RTRIM(UnitNumber) + '/' + LEFT(Description1, 30)
						 FROM	KarmakIntegration)
GROUP BY ORGNTSRC,
		ORPSTDDT