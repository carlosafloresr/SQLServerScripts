/*

SELECT	*
FROM	RM20101

SELECT	*
FROM	RM00101

SELECT	*
FROM	CN30100

SELECT	*
FROM	ILSINT01.Integrations.dbo.View_Integration_FSI_Full FSI
*/

SELECT	CN1.CustNmbr
		,CN1.Cprcstnm
		,CUS.CustName
		,CUS.Address1
		,CUS.Address2
		,CUS.City
		,CUS.State
		,CUS.Zip
		,CUS.Phone1
		,CN1.DocNumbr
		,CN1.DocDate
		,CN1.OrTrxAmt
		,CN1.CurTrxAm
		,CN1.TrxDscrn
		,CN3.Amount_Promised
		,CN3.Action_Promised
		,CN3.Note_Display_String
		,CN3.CntCPrsn
		,CN3.UserId
		,CN1.BachNumb
FROM	RM20101 CN1
		LEFT JOIN CN20100 CN2 ON CN1.CustNmbr = CN2.CustNmbr AND CN1.Cprcstnm = CN2.Cprcstnm AND CN1.DocNumbr = CN2.DocNumbr
		LEFT JOIN CN00100 CN3 ON CN1.CustNmbr = CN3.CustNmbr AND CN1.Cprcstnm = CN3.Cprcstnm AND CN2.NoteIndx = CN3.NoteIndx
		LEFT JOIN RM00101 CUS ON CN1.CustNmbr = CUS.CustNmbr
		LEFT JOIN ILSINT01.Integrations.dbo.View_Integration_FSI_Full FSI ON FSI.Company = DB_NAME() AND CN1.DocNumbr = FSI.InvoiceNumber
WHERE	CN1.DocDate < GETDATE() - 90
		AND CN1.CurTrxAm > 0
		AND CN1.RmdTypal = 1