/*
SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'DNJ'
		AND AccountNumber = '0-00-2790'
		and BatchId = 'OOSDNJ_121213'
*/
DECLARE @BatchId Varchar(15) = 'OOSDNJ_121213'

SELECT	*
INTO	#tmpData
FROM	(
			SELECT	OOS.Company,
					OOS.Vendorid,
					OOS.CreditAccount,
					OOS.Invoice,
					OOS.DedAmount,
					PMH.DOCDATE,
					PMH.POSTEDDT,
					PMH.PTDUSRID,
					PMD.DSTSQNUM,
					PMD.DISTTYPE,
					ESA.Fk_EscrowModuleId
			FROM	View_OOS_Transactions OOS
					INNER JOIN EscrowAccounts ESA ON OOS.Company = ESA.CompanyId AND OOS.CreditAccount = ESA.AccountNumber
					INNER JOIN DNJ..PM20000 PMH ON OOS.Invoice = PMH.VCHRNMBR
					INNER JOIN DNJ..PM10100 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE AND PMD.DSTINDX = OOS.CrdAcctIndex
					LEFT JOIN EscrowTransactions ESC ON OOS.Company = ESC.CompanyId AND OOS.Invoice = ESC.VoucherNumber AND OOS.Vendorid = ESC.Vendorid AND OOS.DedAmount = ESC.Amount
			WHERE	OOS.BatchId = @BatchId
					AND ESC.PostingDate IS NULL
			UNION
			SELECT	OOS.Company,
					OOS.Vendorid,
					OOS.CreditAccount,
					OOS.Invoice,
					OOS.DedAmount,
					PMH.DOCDATE,
					PMH.POSTEDDT,
					PMH.PTDUSRID,
					PMD.DSTSQNUM,
					PMD.DISTTYPE,
					ESA.Fk_EscrowModuleId
			FROM	View_OOS_Transactions OOS
					INNER JOIN EscrowAccounts ESA ON OOS.Company = ESA.CompanyId AND OOS.CreditAccount = ESA.AccountNumber
					INNER JOIN DNJ..PM30200 PMH ON OOS.Invoice = PMH.VCHRNMBR
					INNER JOIN DNJ..PM30600 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE AND PMD.DSTINDX = OOS.CrdAcctIndex
					LEFT JOIN EscrowTransactions ESC ON OOS.Company = ESC.CompanyId AND OOS.Invoice = ESC.VoucherNumber AND OOS.Vendorid = ESC.Vendorid AND OOS.DedAmount = ESC.Amount
			WHERE	OOS.BatchId = @BatchId
					AND ESC.PostingDate IS NULL
		) DATE

INSERT INTO EscrowTransactions (CompanyId, Source, VoucherNumber, ItemNumber, Fk_EscrowModuleId, AccountNumber, AccountType, VendorId, Amount, TransactionDate, PostingDate, EnteredBy, ChangedBy, BatchId)
SELECT	Company,
		'AP',
		Invoice,
		DSTSQNUM,
		Fk_EscrowModuleId,
		CreditAccount,
		DISTTYPE,
		Vendorid,
		DedAmount,
		DOCDATE,
		POSTEDDT,
		PTDUSRID,
		PTDUSRID,
		@BatchId
FROM	#tmpData

DROP TABLE #tmpData