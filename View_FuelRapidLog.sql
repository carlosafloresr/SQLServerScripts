/*
Example Line: "07/30/2001","00:02:00","","Fuel","SHORTER, AL","BATEJ","1518885175","" 

Field Name Field Position Notes/Format 
Date 0 MM/DD/YYYY 
Time 1 HH:MM:SS 
Reserved 2 Always "" (Blank) 
Source 3 Type of record "Fuel", "Dispatch" 
Location 4 Visual cue, usually “City, State”. For user to identify where the driver was. 
Driver 5 Must equal RapidLog's Driver ID (or SSN, if overriding with MatchVia option) 
FuelCard 6 Only used if overriding with MatchVia option 
Reserved 7 Always "" (Blank) 

SELECT	*
FROM	View_FuelRapidLog
WHERE	BatchId IN (SELECT	TOP 2 BatchId
					FROM	FPT_ReceivedHeader
					WHERE	Company = 'GIS'
					ORDER BY BatchId DESC)
		AND BatchId <> '2_FPT_20090801'

UPDATE	View_Integration_FPT
SET		RapidLog = 1
WHERE	TransTime IS Null

SELECT	*
FROM	View_Integration_FPT
WHERE	BatchId = '10FPT140520090502'

SELECT	*
FROM	View_FuelRapidLog
WHERE	BatchId = '1_FPT_20090502'
*/
ALTER VIEW View_FuelRapidLog
AS
SELECT	Company
		,BatchId
		,'"' + CONVERT(Char(10), TransDate, 101) + '","' + TransTime + ':00","","Fuel","' + RTRIM(Location) + '","' + RTRIM(VendorId) + '","' + RTRIM(Card) + '",""' AS Record
		,WeekEndDate
		,RapidLog
FROM	View_Integration_FPT

