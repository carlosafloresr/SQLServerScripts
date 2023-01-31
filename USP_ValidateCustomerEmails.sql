/*
EXECUTE USP_ValidateCustomerEmails
*/
CREATE PROCEDURE USP_ValidateCustomerEmails
AS
SELECT	*
FROM	(
		SELECT	'AIS' AS Company
				,CUSTNMBR
				,Email_Recipient
		FROM	AIS.dbo.RM00106
		UNION
		SELECT	'DNJ' AS Company
				,CUSTNMBR
				,Email_Recipient
		FROM	DNJ.dbo.RM00106
		UNION
		SELECT	'GIS' AS Company
				,CUSTNMBR
				,Email_Recipient
		FROM	GIS.dbo.RM00106
		UNION
		SELECT	'IMC' AS Company
				,CUSTNMBR
				,Email_Recipient
		FROM	IMC.dbo.RM00106
		UNION
		SELECT	'NDS' AS Company
				,CUSTNMBR
				,Email_Recipient
		FROM	NDS.dbo.RM00106
		) RECS
WHERE	NOT (CHARINDEX(' ',LTRIM(RTRIM(Email_Recipient))) = 0
		AND LEFT(LTRIM(Email_Recipient),1) <> '@' 
		AND RIGHT(RTRIM(Email_Recipient),1) <> '.'
		AND CHARINDEX('.',Email_Recipient, CHARINDEX('@',Email_Recipient))- CHARINDEX('@', Email_Recipient) > 1
		AND LEN(LTRIM(RTRIM(Email_Recipient)))- LEN(REPLACE(LTRIM(RTRIM(Email_Recipient)),'@','')) = 1
		AND CHARINDEX('.',REVERSE(LTRIM(RTRIM(Email_Recipient)))) >= 3
		AND (CHARINDEX('.@', Email_Recipient) = 0 AND CHARINDEX('..', Email_Recipient) = 0))
ORDER BY Company, CUSTNMBR