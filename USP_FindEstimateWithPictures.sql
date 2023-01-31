/*
EXECUTE USP_FindEstimateWithPictures '4/1/2015', '5/12/2015 11:59 PM'
EXECUTE USP_FindEstimateWithPictures '4/1/2015', '5/12/2015 11:59 PM', 'SH031'
*/
ALTER PROCEDURE USP_FindEstimateWithPictures
		@DateIni	Datetime,
		@DateEnd	Datetime,
		@Tablet		Varchar(15) = Null
AS
SELECT	Tablet, 
		InvoiceNumber 
INTO	#tmpData
FROM	Repairs 
WHERE	InvoiceNumber > 0 
		AND Pictures IS NOT Null 
		AND ReceivedOn BETWEEN @DateIni AND @DateEnd
		AND (@Tablet IS Null OR (@Tablet IS NOT Null AND Tablet = @Tablet))
ORDER BY Tablet, InvoiceNumber

SELECT	Tablet, 
		InvoiceNumber,
		TotalRecords = (SELECT COUNT(*) FROM #tmpData)
FROM	#tmpData

DROP TABLE #tmpData