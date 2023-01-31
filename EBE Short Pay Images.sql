SELECT	COUNT(*)
FROM	(
SELECT	DISTINCT APP.Doc_Id
FROM	PacketIDX_ShortPay PCK
		INNER JOIN App_Billing APP ON APP.InvoiceNumber = PCK.InvoiceNumber AND APP.CustomerID = PCK.CustomerId AND APP.Division = PCK.Division
		INNER JOIN [Page] PG ON App.Doc_ID = PG.Doc_ID 
		--INNER JOIN [FileTypes] FT ON PG.FileTypeID = FT.MIMEID
WHERE	PCK.DatePaid <> ''
		AND APP.IndexDate < '01/01/2018'
		) DATA


-- ,'E:\Tributary\Images\'+SubString(RIGHT('0000000'+CAST(Page_ID as varchar),7),1,1)+'\'+SubString(RIGHT('0000000'+CAST(Page_ID as varchar),7),2,2)+'\'+SubString(RIGHT('0000000'+CAST(Page_ID as varchar),7),4,2)+'\'+CAST(Page_ID as varchar)+'.'+ft.Extension AS [Local Path]