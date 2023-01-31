SELECT	BatchId,
		Company,
		InvoiceNumber,
		CustomerNumber,
		BillToRef,
		CAST(InvoiceDate AS Date) AS InvoiceDate,
		InvoiceTotal,
		InvoiceType,
		Division,
		RecordType,
		RecordCode,
		ChargeAmount1,
		ChargeAmount2,
		DemurrageAdminFee,
		AccCode,
		CASE WHEN PrePayType = 'P' AND PrePay = 1 THEN 'PrePay'
			 WHEN PrePayType = 'A' THEN 'Accrual'
			 ELSE '' END AS TransType,
		IIF(ICB_AR = 1 OR ICB_AP = 1, 'Y', 'N') AS ICB,
		Reference,
		ReferenceCode,
		VendorDocument,
		PrepayReference
FROM	View_Integration_FSI_Full
WHERE	InvoiceNumber IN ('C42-130464','C42-133894','C42-134381','C55-200570','C56-136496','C56-136871')
ORDER BY InvoiceNumber