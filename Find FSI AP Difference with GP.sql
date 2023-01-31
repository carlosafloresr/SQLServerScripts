DECLARE	@tblData	Table (VendorId Varchar(12), FSIAmount Numeric(10,2), GPAmount Numeric(10,2) Null)

INSERT INTO @tblData 
SELECT	VENDORID, SUM(DOCAMNT) AS DOCAMNT, 0
FROM	PM20000
WHERE	BACHNUMB = '1FSI20201202_10'
GROUP BY VENDORID
ORDER BY VENDORID
		--DOCNUMBR = 'MSDU112786/22273117'

/*
SELECT	distinct DetailId
FROM	FSI_ReceivedSubDetails
WHERE	BatchId = '9FSI20201202_1556'
		--AND DetailId = 3079
*/
UPDATE	@tblData
SET		GPAmount = ISNULL(DATA.Amount,0)
FROM	(
SELECT	RecordCode, SUM(ChargeAmount1) AS Amount
FROM	(
		SELECT	BatchId,
				InvoiceNumber,
				RecordCode,
				ChargeAmount1,
				AccCode,
				VendorDocument,
				PrePay,
				ICB_AP,
				ICB_AR,
				PerDiemType,
				PierPassType,
				VndIntercompany
		FROM	PRISQL004P.Integrations.dbo.View_Integration_FSI_Full
		WHERE	BatchId = '1FSI20201202_1056'
				AND RecordType = 'VND'
				AND PrePay = 0
				AND ICB_AP = 0
				) DATA
		GROUP BY RecordCode
		) DATA
WHERE	VendorId = RecordCode

SELECT	*
FROM	@tblData
WHERE	FSIAmount <> GPAmount


PRINT 43196.81 - 43733.30000