DECLARE	@Company	Varchar(5) = 'OIS',
		@RunDate	Date = '02/01/2021',
		@BatchId	Varchar(15),
		@Query		Varchar(MAX)

DECLARE @tblOOSData	Table (
		Company		Varchar(5),
		BatchId		Varchar(25),
		VendorId	Varchar(15),
		CrdAccount	Varchar(12),
		Invoice		Varchar(30),
		DedAmount	Numeric(10,2),
		DedDate		Date,
		PostDate	Date,
		PostUser	Varchar(25),
		Sequence	Bigint,
		DistType	Int,
		EscModuleId	Int Null)

DECLARE curOOSBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT BatchId
FROM	View_OOS_Transactions
WHERE	Company = @Company
		AND DeductionDate >= @RunDate

OPEN curOOSBatches 
FETCH FROM curOOSBatches INTO @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT OOS.Company,
					OOS.BatchId,
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
					INNER JOIN ' + @Company + '.dbo.PM20000 PMH ON OOS.Invoice = PMH.VCHRNMBR
					INNER JOIN ' + @Company + '.dbo.PM10100 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE AND PMD.DSTINDX = OOS.CrdAcctIndex
					LEFT JOIN EscrowTransactions ESC ON OOS.Company = ESC.CompanyId AND OOS.Invoice = ESC.VoucherNumber AND OOS.Vendorid = ESC.Vendorid AND OOS.DedAmount = ESC.Amount
			WHERE	OOS.BatchId = ''' + @BatchId + '''
					AND ESC.PostingDate IS NULL
			UNION
			SELECT	OOS.Company,
					OOS.BatchId,
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
					INNER JOIN ' + @Company + '.dbo.PM30200 PMH ON OOS.Invoice = PMH.VCHRNMBR
					INNER JOIN ' + @Company + '.dbo.PM30600 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE AND PMD.DSTINDX = OOS.CrdAcctIndex
					LEFT JOIN EscrowTransactions ESC ON OOS.Company = ESC.CompanyId AND OOS.Invoice = ESC.VoucherNumber AND OOS.Vendorid = ESC.Vendorid AND OOS.DedAmount = ESC.Amount
			WHERE	OOS.BatchId = ''' + @BatchId + '''
					AND ESC.PostingDate IS NULL'

	INSERT INTO @tblOOSData
	EXECUTE(@Query)

	FETCH FROM curOOSBatches INTO @BatchId
END

CLOSE curOOSBatches
DEALLOCATE curOOSBatches

SELECT	*
FROM	@tblOOSData