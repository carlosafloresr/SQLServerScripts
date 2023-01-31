/*
SELECT	* 
FROM 	EscrowTransactions 
WHERE 	CompanyID = 'AIS' AND ItemNumber = 0
SELECT * FROM AIS.dbo.PM10100 WHERE Vchrnmbr = '00000000000000386'

DELETE	EscrowTransactions 
WHERE 	CompanyID = 'AIS' AND PostingDate IS NULL

DELETE	EscrowTransactions 
WHERE 	CompanyID = 'AIS' AND VoucherNumber = '00000000000000386'

DELETE	EscrowTransactions 
WHERE 	CompanyID = 'AIS' AND AccountType = 0 AND ItemNumber = 0

SELECT * FROM AIS.dbo.PM20200
SELECT * FROM AIS.dbo.PM10100
SELECT * FROM AIS.DBO.PM10600
	LEFT JOIN AIS.dbo.PM10000 P2 ON ET.VoucherNumber = P2.VchnumWk 
	LEFT JOIN AIS.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
	LEFT JOIN AIS.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 

UPDATE 	EscrowTransactions SET Fk_EscrowModuleId = 1 WHERE Fk_EscrowModuleId = 0


SELECT * FROM AIS.DBO.PM10100 WHERE Vchrnmbr = 'STDA0060101807A'

UPDATE 	EscrowTransactions
SET	PostingDate = T1.PstgDate
FROM	(SELECT	ISNULL(P1.Vchrnmbr, P2.Vchrnmbr) AS Vchrnmbr,
		ISNULL(P1.PstgDate, P2.PstgDate) AS PstgDate
	FROM 	EscrowTransactions 
		LEFT JOIN AIS.dbo.PM10000 P1 ON EscrowTransactions.VoucherNumber = P1.Vchrnmbr 	
		LEFT JOIN AIS.dbo.PM30200 P2 ON EscrowTransactions.VoucherNumber = P2.Vchrnmbr 	
	WHERE 	CompanyID = 'AIS' AND
		ISNULL(P1.Vchrnmbr, P2.Vchrnmbr) IS NOT Null) T1
WHERE	EscrowTransactions.VoucherNumber = T1.Vchrnmbr

SELECT * FROM AIS.dbo.PM10000 WHERE Vchrnmbr = '00000000000000022'
SELECT * FROM AIS.dbo.PM20000 WHERE Vchrnmbr = '00000000000000022'
SELECT * FROM AIS.dbo.PM10100 WHERE Vchrnmbr = 'EC226_151510001'
*/

UPDATE 	EscrowTransactions
SET	ItemNumber = T1.DstSqNum,
	PostingDate = T1.PstgDate
FROM	(SELECT	ET.EscrowTransactionId,
	ISNULL(P1.Vchrnmbr, P2.Vchrnmbr) AS Vchrnmbr,
	ISNULL(P1.PstgDate, P2.PstgDate) AS PstgDate,
	ISNULL(P1.DstSqNum, P2.DstSqNum) AS DstSqNum
FROM 	EscrowTransactions ET
	LEFT JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
	LEFT JOIN AIS.dbo.PM10100 P1 ON VoucherNumber = P1.Vchrnmbr AND EA.AccountIndex = P1.DstIndx
	LEFT JOIN AIS.dbo.PM30600 P2 ON VoucherNumber = P2.Vchrnmbr AND EA.AccountIndex = P2.DstIndx
WHERE 	ET.CompanyID = 'AIS' AND
	ISNULL(P1.Vchrnmbr, P2.Vchrnmbr) IS NOT Null AND
	ET.Source = 'AP') T1
WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId
