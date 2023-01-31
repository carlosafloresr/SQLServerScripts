SELECT	'AIS' AS Company
		,AR.LinkedCompany AS BillToCompany
		,RM.CustNmbr AS CustomerNo
		,RM.DocNumbr AS InvoiceNo
		,RM.DocDate AS InvoiceDate
		,RM.PostDate AS EffectiveDate
		,RM.OrTrxAmt AS InvoiceAmount
		,RM.CurTrxAm AS InvoiceBalance
		,RM.CsPorNbr AS ProNumber
		,AP.InvoiceDate AS ProNumbDate
		,AP.VendorPayTotal AS ProNumbVendorPay
		,AP.Container
FROM	ILSGP01.AIS.dbo.RM20101 RM
		INNER JOIN FSI_Intercompany_ARAP AR ON RM.CustNmbr = AR.Account AND AR.Company = 'AIS' AND AR.RecordType = 'C'
		LEFT JOIN View_TIP_Transactions_AP AP ON RM.CsPorNbr = AP.InvoiceNumber
UNION
SELECT	'IMC' AS Company
		,AR.LinkedCompany AS BillToCompany
		,RM.CustNmbr AS CustomerNo
		,RM.DocNumbr AS InvoiceNo
		,RM.DocDate AS InvoiceDate
		,RM.PostDate AS EffectiveDate
		,RM.OrTrxAmt AS InvoiceAmount
		,RM.CurTrxAm AS InvoiceBalance
		,RM.CsPorNbr AS ProNumber
		,AP.InvoiceDate AS ProNumbDate
		,AP.VendorPayTotal AS ProNumbVendorPay
		,AP.Container
FROM	ILSGP01.IMC.dbo.RM20101 RM
		INNER JOIN FSI_Intercompany_ARAP AR ON RM.CustNmbr = AR.Account AND AR.Company = 'IMC' AND AR.RecordType = 'C'
		LEFT JOIN View_TIP_Transactions_AP AP ON RM.CsPorNbr = AP.InvoiceNumber
UNION
SELECT	'GIS' AS Company
		,AR.LinkedCompany AS BillToCompany
		,RM.CustNmbr AS CustomerNo
		,RM.DocNumbr AS InvoiceNo
		,RM.DocDate AS InvoiceDate
		,RM.PostDate AS EffectiveDate
		,RM.OrTrxAmt AS InvoiceAmount
		,RM.CurTrxAm AS InvoiceBalance
		,RM.CsPorNbr AS ProNumber
		,AP.InvoiceDate AS ProNumbDate
		,AP.VendorPayTotal AS ProNumbVendorPay
		,AP.Container
FROM	ILSGP01.GIS.dbo.RM20101 RM
		INNER JOIN FSI_Intercompany_ARAP AR ON RM.CustNmbr = AR.Account AND AR.Company = 'GIS' AND AR.RecordType = 'C'
		LEFT JOIN View_TIP_Transactions_AP AP ON RM.CsPorNbr = AP.InvoiceNumber

/*
SELECT	*
FROM	View_TIP_Transactions_AP

SELECT	*
FROM	FSI_Intercompany_ARAP
WHERE	Company = 'AIS'
		AND RecordType = 'C'
*/