UPDATE	UF_Invoice
SET		EquipmentNo = Null
FROM	(
		SELECT	CS_Invoice.InvoiceId
				,CS_Enterprise.EnterpriseNumber
				,RTRIM(CS_Invoice.InvoiceNum) AS InvoiceNum
				,UF_Invoice.EquipmentNo
		FROM	CS_Invoice
				INNER JOIN CS_Enterprise ON CS_Invoice.EnterpriseId = CS_Enterprise.EnterpriseId
				INNER JOIN UF_Invoice ON UF_Invoice.InvoiceId = CS_Invoice.InvoiceId
		WHERE	CS_Invoice.InvoiceNum LIKE '%-%'
				AND dbo.AT('-', CS_Invoice.InvoiceNum, 1) < 5
				AND CS_Invoice.DocDate > DATEADD(dd, -90, GETDATE())
				AND UF_Invoice.EquipmentNo = ''
				AND CS_Invoice.InvoiceNum NOT LIKE 'D %'
		) DATA
WHERE	UF_Invoice.InvoiceId = DATA.InvoiceId

--EXECUTE USP_FindContainer 'DNJ', '96-49940'

--SELECT	Cm.*
--FROM	GPCustom.dbo.SalesInvoices SI
--		LEFT JOIN GPCustom.dbo.CustomerMaster CM ON SI.CustomerId = CM.CustNmbr
--WHERE	SI.InvoiceNumber = '96-49940'