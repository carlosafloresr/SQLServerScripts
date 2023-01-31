UPDATE	KarmakIntegration
SET		Processed = 2, AcctApproved = 1
WHERE	--AcctApproved = 1 AND Account1 IS NOT Null
		KIMBatchId IN ('KM1211161411')
		AND Account1 IS NOT Null
		-- KIMBatchId IS not Null
		--AND WeekEndDate = '08/11/2012'

/*
SELECT * FROM View_KarmakIntegration WHERE KIMBatchId = 'KM1211161357' AND Processed = 2 AND AcctApproved = 1 AND Account1 IS NOT Null ORDER BY InvoiceNumber
select * from KarmakIntegration order by weekenddate
WHERE	KIMBatchId IN ('KM1103280954','KM1103280954P')
		and WeekEndDate = '2010-07-24 00:00:00.000'
*/