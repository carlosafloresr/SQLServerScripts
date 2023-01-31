SELECT	DISTINCT FSIT.Company, 
		CAST(CASE WHEN DATENAME(Weekday, FSIH.WeekendDate) = 'Saturday' THEN FSIH.WeekendDate 
		ELSE dbo.DayFwdBack(FSIH.WeekendDate, 'P', 'Saturday') END AS Date) AS WeekendDate,
		FSIH.BatchId
FROM	FSI_TransactionDetails FSIT
		INNER JOIN FSI_ReceivedHeader FSIH ON FSIT.Company = FSIH.Company AND FSIT.BatchId = FSIH.BatchId
WHERE	FSIH.WeekendDate >= DATEADD(DD, -10, GETDATE())
		AND FSIT.BatchId NOT LIKE '%_SUM'
ORDER BY 2, 1, 3
		