SELECT	*
FROM	RM00106
WHERE	GPCustom.dbo.AT('@', Email_Recipient, 2) > 0
		OR GPCustom.dbo.AT('@', Email_Recipient, 1) = 0
		--CUSTNMBR = '8036'

/*
SELECT	*
FROM	RM00101
WHERE	CUSTNAME LIKE '%SADDLE %'

UPDATE	RM00106
SET		Email_Recipient = 'kgorman@extremelinen.com;derrickfinley@extremelinen.com'
WHERE	DEX_ROW_ID = 1581

UPDATE	RM00106
SET		Email_Recipient = REPLACE(Email_Recipient, '@@', '@')
WHERE	GPCustom.dbo.AT('@@', Email_Recipient, 1) > 0

DELETE	RM00106
WHERE	GPCustom.dbo.AT('@', Email_Recipient, 1) = 0
*/