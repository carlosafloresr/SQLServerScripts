UPDATE	[CS_Invoice]
SET		[CS_Invoice].PurchaseOrderNum = IIF([CS_Invoice].PurchaseOrderNum = '' AND DATA.ProNumber IS NOT Null, DATA.ProNumber, [CS_Invoice].PurchaseOrderNum)
FROM	(
		SELECT	ENT.EnterpriseName,
				INV.CustomerNumber,
				INV.InvoiceNum,
				INV.InvoiceId,
				SAL.ProNumber
		FROM	[CS_Invoice] INV
				INNER JOIN CS_Enterprise ENT ON INV.EnterpriseId = ENT.EnterpriseId
				LEFT JOIN GPCustom.dbo.SalesInvoices SAL ON ENT.EnterpriseName = SAL.CompanyId AND INV.CustomerNumber = SAL.CustomerId AND INV.InvoiceNum = SAL.InvoiceNumber
		WHERE	PurchaseOrderNum = ''
				AND SAL.ProNumber IS NOT Null
		) DATA
WHERE	[CS_Invoice].InvoiceId = DATA.InvoiceId

UPDATE	UF_Invoice
SET		UF_Invoice.EquipmentNo = IIF(UF_Invoice.EquipmentNo IS NUll AND DATA.TrailerNumber IS NOT Null, DATA.TrailerNumber, UF_Invoice.EquipmentNo)
FROM	(
		SELECT	INV.InvoiceId,
				SAL.TrailerNumber,
				EquipmentNo
		FROM	[CS_Invoice] INV
				INNER JOIN CS_Enterprise ENT ON INV.EnterpriseId = ENT.EnterpriseId
				LEFT JOIN UF_Invoice ON UF_Invoice.InvoiceId = INV.InvoiceId
				LEFT JOIN GPCustom.dbo.SalesInvoices SAL ON ENT.EnterpriseNumber = SAL.CompanyId AND INV.CustomerNumber = SAL.CustomerId AND INV.InvoiceNum = SAL.InvoiceNumber
		WHERE	SAL.TrailerNumber IS NOT Null
				AND EquipmentNo IS Null
		) DATA
WHERE	UF_Invoice.InvoiceId = DATA.InvoiceId

