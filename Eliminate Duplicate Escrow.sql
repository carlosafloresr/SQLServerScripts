/*

*/
CREATE PROCEDURE USP_Escrow_DeleteDuplicatedRecors (@Company Varchar(5))
AS
DECLARE	@StartDate Date

SET @StartDate = dbo.DayFwdBack(GETDATE(), 'P', 'Sunday')

PRINT @StartDate

DELETE	EscrowTransactions
WHERE	EscrowTransactionId IN (
SELECT	EscrowTransactionId
FROM	(

		SELECT	ET.CompanyId,
				ET.VoucherNumber,
				ET.VendorId,
				MIN(EscrowTransactionId) AS EscrowTransactionId
		FROM	EscrowTransactions ET
				INNER JOIN (

							SELECT	VoucherNumber
									,CompanyId
									,VendorId
									,PostingDate
									,Amount
									,COUNT(VendorId) AS Counter
							FROM	EscrowTransactions 
							WHERE	--CompanyId = 'IMC'
									--AND EnteredBy = 'ILSLISTENER'
									EnteredOn > '11/25/2014'
							GROUP BY
									VoucherNumber
									,CompanyId
									,VendorId
									,PostingDate
									,Amount
							HAVING COUNT(VendorId) > 1

							) DP ON ET.VoucherNumber = DP.VoucherNumber AND ET.VendorId = DP.VendorId
		GROUP BY
				ET.CompanyId,
				ET.VoucherNumber,
				ET.VendorId
		
) DP)

/*
SELECT * INTO EscrowTransactions_09232010 FROM EscrowTransactions 
DELETE EscrowTransactions WHERE EnteredOn > '10/8/2008' AND PostingDate IS Null AND CompanyId = 'IMC' AND EnteredBy = 'ILSLISTENER'

*/