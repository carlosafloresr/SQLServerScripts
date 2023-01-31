/*
SELECT	* 
FROM	ILSGP01.FI.dbo.RM20101
WHERE	RmdTypal = 1
*/

DROP TABLE OpenFIInvoices

SELECT	Inv_No
		,Inv_Date
		,Inv_Total
		,Chassis
		,Container
		,Acct_No AS InvoiceCustNo
INTO	#OpenInvoices
FROM	Invoices
WHERE	Inv_No IN (	SELECT	CAST(REPLACE(DocNumbr, 'I', '') AS Int)
					FROM	ILSGP01.FI.dbo.RM20101
					WHERE	RmdTypal = 1
							AND LEFT(DocNumbr, 1) = 'I')
		AND Chassis NOT IN ('CHASSIS COUNT','REEFER','REEFERS','SCRAP CHASSIS')
order by chassis
SELECT	TMP.Inv_No AS OpenInvoice
		,TMP.Inv_Date AS InvoiceDate
		,TMP.Inv_Total AS InvoiceTotal
		,TMP.Chassis AS InvChassis
		,TMP.Container AS InvContainer
		,TMP.InvoiceCustNo
		,INV.Inv_No
		,INV.Inv_Date
		,INV.Inv_Total
		,INV.Chassis
		,INV.Container
		,INV.Acct_No AS CustNo
INTO	OpenFIInvoices
FROM	Invoices INV
		INNER JOIN #OpenInvoices TMP ON ((INV.Chassis = TMP.Chassis AND INV.Chassis <> '' AND INV.Container = '') OR (INV.Container = TMP.Container AND INV.Container <> '' AND INV.Chassis = '')) AND INV.Inv_Date BETWEEN TMP.Inv_Date - 15 AND TMP.Inv_Date + 15 AND INV.Inv_No <> TMP.Inv_No
WHERE	INV.Inv_No > 0
		AND ((INV.Chassis = '' AND INV.Container <> '')
		OR (INV.Chassis <> '' AND INV.Container = ''))

DROP TABLE #OpenInvoices