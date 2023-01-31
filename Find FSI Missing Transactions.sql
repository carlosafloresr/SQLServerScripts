SELECT	* 
FROM	FSI_ReceivedDetails 
WHERE	InvoiceNumber IN (SELECT RTRIM(Invoice) FROM FSI_IMC_Missin)
		OR BillToRef IN (SELECT RTRIM(Invoice) FROM FSI_IMC_Missin)