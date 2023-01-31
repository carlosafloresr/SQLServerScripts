SELECT	APP.InvoiceNumber
FROM	PacketIDX_ShortPay PCK
		INNER JOIN App_Billing APP ON APP.InvoiceNumber = PCK.InvoiceNumber AND APP.CustomerID = PCK.CustomerId AND APP.Division = PCK.Division
		INNER JOIN [Page] PG ON APP.Doc_ID = PG.Doc_ID 
WHERE	APP.InvoiceNumber IN ('11-130264-A','D2-210893')


SELECT	*
FROM	App_Billing APP
		INNER JOIN [Page] PG ON APP.Doc_ID = PG.Doc_ID 
WHERE	APP.InvoiceNumber IN ('11-130264-A','D2-210893')