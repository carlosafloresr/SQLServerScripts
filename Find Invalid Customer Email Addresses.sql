USE imc
GO

SELECT	DB_NAME() AS Company,
		R6.CUSTNMBR,
		R1.CUSTNAME,
		R6.Email_Recipient,
		R6.DEX_ROW_ID
FROM	RM00106 R6
		INNER JOIN RM00101 R1 ON R6.CUSTNMBR = R1.CUSTNMBR
WHERE	GPCustom.dbo.IsEmailAddressValid(R6.Email_Recipient) = 0
		--AND R6.CUSTNMBR in ('ANHSTL','HONONT','LUMTOA','MATNAV','PANSUW')


/*
SELECT	*
FROM	RM00106
WHERE	CUSTNMBR = '11304'
--Email_Recipient = 'almadhrahi@apllogistics.com'

UPDATE	RM00106
SET		Email_Recipient = 'revenue_accounting@imcg.com'
WHERE	DEX_ROW_ID = 1234
*/