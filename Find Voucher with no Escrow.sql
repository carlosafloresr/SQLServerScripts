SELECT	PMH.VchrNmbr
		,PMH.VendorId
		,PMH.DocDate
		,PMH.DocNumbr
		,PMH.DocDate
		,PMH.PstgDate
		,PMH.PtdUsrId
		,ESC.AccountNumber
FROM	PM20000 PMH
		INNER JOIN PM10100 PMD ON PMH.VchrNmbr = PMD.VchrNmbr AND PMH.TrxSorce = PMD.TrxSorce
		INNER JOIN GPCustom..EscrowTransactions ESC ON PMH.VchrNmbr = ESC.VoucherNumber
WHERE	PMH.PstgDate > '10/31/2010'
		AND PMH.Voided = 0
		AND PMD.DstIndx IN (SELECT AccountIndex FROM GPCustom..EscrowAccounts WHERE CompanyId = 'DNJ')
		AND ESC.CompanyId = 'DNJ' 
		AND ESC.Source = 'AP' 
		AND ESC.PostingDate > '10/31/2010'
		AND PMH.PtdUsrId = 'lcook'
UNION
SELECT	PMH.VchrNmbr
		,PMH.VendorId
		,PMH.DocDate
		,PMH.DocNumbr
		,PMH.DocDate
		,PMH.PstgDate
		,PMH.PtdUsrId
		,ESC.AccountNumber
FROM	PM30200 PMH
		INNER JOIN PM30600 PMD ON PMH.VchrNmbr = PMD.VchrNmbr AND PMH.TrxSorce = PMD.TrxSorce
		INNER JOIN GPCustom..EscrowTransactions ESC ON PMH.VchrNmbr = ESC.VoucherNumber
WHERE	PMH.PstgDate > '10/31/2010'
		AND PMH.Voided = 0
		AND PMD.DstIndx IN (SELECT AccountIndex FROM GPCustom..EscrowAccounts WHERE CompanyId = 'DNJ')
		AND ESC.CompanyId = 'DNJ' 
		AND ESC.Source = 'AP' 
		AND ESC.PostingDate > '10/31/2010'
		AND PMH.PtdUsrId = 'lcook'
ORDER BY ESC.AccountNumber, PMH.VchrNmbr
/*
SELECT	*
FROM	RM20101

SELECT * FROM pm10100 WHERE VchrNmbr = '96-00384'
SELECT * FROM GL20000
SELECT	* 
FROM	PM20000 
WHERE	VchrNmbr IN (SELECT VoucherNumber FROM GPCustom..EscrowTransactions WHERE cOMPANYiD = 'DNJ' AND Source = 'AP' AND PostingDate > '10/31/2010')
		AND PstgDate > '10/31/2010'
		
SELECT	* 
FROM	GPCustom..EscrowTransactions 
WHERE	CompanyId = 'DNJ'
		AND AccountNumber = '0-00-1106'
		AND Source = 'AR'
		--AND VoucherNumber = '00000000000017534'
		
SELECT	distinct enteredby 
FROM	EscrowTransactions 
WHERE	PostingDate > '11/20/2010'
		AND Source = 'AP'
		
		
WHERE	CompanyId = 'DNJ' 
		AND AccountNumber = '0-00-1106'
		AND Source = 'AP'
ORDER BY PostingDate
*/