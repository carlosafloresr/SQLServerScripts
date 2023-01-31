DECLARE	@Company	Varchar(5) = 'NDS',
		@Account	Varchar(20) = '22-11-1107',
		@DateIni	Date = '02/01/2017',
		@DateEnd	Date = '02/16/2017',
		@Amount		Numeric(10,2),
		@Pros		Int,
		@Docs		Int,
		@ProNumber	Varchar(25),
		@Amount1	Numeric(10,2),
		@Amount2	Numeric(10,2)

SELECT	*
INTO	#tmpReportData
FROM	GPCustom.dbo.tmpEscrowReport
WHERE	EscrowTransactionId < 0

INSERT INTO #tmpReportData
EXECUTE NDS.dbo.USP_Report_ExpenseRecovery @Company, @Account, @DateIni, @DateEnd, 1

DECLARE curReportData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	ProNumber
FROM	(
		SELECT	ProNumber,
				Counter = (SELECT COUNT(TMP2.ProNumber) FROM #tmpReportData TMP2 WHERE TMP1.ProNumber = TMP2.ProNumber)
		FROM	#tmpReportData TMP1
		--WHERE	ProNumber = '96-71958'
		) DATA
WHERE	Counter = 1

OPEN curReportData 
FETCH FROM curReportData INTO @ProNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	@Amount = SUM(Amount),
			@Pros	= SUM(CASE WHEN ProNumber IS NOT Null THEN 1 ELSE 0 END),
			@Docs	= SUM(CASE WHEN SOPDocumentNumber IS NOT Null THEN 1 ELSE 0 END)
	FROM	View_EscrowTransactions
	WHERE	CompanyId = @Company
			AND AccountNumber = @Account
			AND (ProNumber = @ProNumber
			OR SOPDocumentNumber = @ProNumber)

	SELECT	@Amount1 = SUM(Amount)
	FROM	View_EscrowTransactions
	WHERE	CompanyId = @Company
			AND Fk_EscrowModuleId = 5
			AND AccountNumber = @Account
			AND (ProNumber = @ProNumber
			OR SOPDocumentNumber = @ProNumber)
			AND (ProNumber = SOPDocumentNumber
			OR SOPDocumentNumber IS Null)

	SELECT	@Amount2 = SUM(Amount)
	FROM	View_EscrowTransactions
	WHERE	CompanyId = @Company
			AND Fk_EscrowModuleId = 5
			AND AccountNumber = @Account
			AND (ProNumber = @ProNumber
			OR SOPDocumentNumber = @ProNumber)
			AND (ProNumber <> SOPDocumentNumber
			AND SOPDocumentNumber IS NOT Null)

	PRINT @Amount
	PRINT @Amount1
	PRINT @Amount2

	IF @Amount <> 0 AND ISNULL(@Amount1,0) = 0 AND @Amount2 = @Amount
	BEGIN
		UPDATE	EscrowTransactions
		SET		ProNumber = SOPDocumentNumber
		WHERE	CompanyId = @Company
				AND Fk_EscrowModuleId = 5
				AND AccountNumber = @Account
				AND (ProNumber = @ProNumber
				OR SOPDocumentNumber = @ProNumber)
				AND (ProNumber <> SOPDocumentNumber
				AND SOPDocumentNumber IS NOT Null)

		UPDATE	EscrowTransactionsHistory
		SET		ProNumber = SOPDocumentNumber
		WHERE	CompanyId = @Company
				AND Fk_EscrowModuleId = 5
				AND AccountNumber = @Account
				AND (ProNumber = @ProNumber
				OR SOPDocumentNumber = @ProNumber)
				AND (ProNumber <> SOPDocumentNumber
				AND SOPDocumentNumber IS NOT Null)
	END

	IF @Amount = 0 AND @Amount1= @Amount2 * -1
	BEGIN
		UPDATE	EscrowTransactions
		SET		ProNumber = SOPDocumentNumber
		WHERE	CompanyId = @Company
				AND Fk_EscrowModuleId = 5
				AND AccountNumber = @Account
				AND (ProNumber = @ProNumber
				OR SOPDocumentNumber = @ProNumber)
				AND (ProNumber <> SOPDocumentNumber
				AND SOPDocumentNumber IS NOT Null)

		UPDATE	EscrowTransactionsHistory
		SET		ProNumber = SOPDocumentNumber
		WHERE	CompanyId = @Company
				AND Fk_EscrowModuleId = 5
				AND AccountNumber = @Account
				AND (ProNumber = @ProNumber
				OR SOPDocumentNumber = @ProNumber)
				AND (ProNumber <> SOPDocumentNumber
				AND SOPDocumentNumber IS NOT Null)
	END

	FETCH FROM curReportData INTO @ProNumber
END

CLOSE curReportData
DEALLOCATE curReportData

--SELECT	*
--FROM	View_EscrowTransactions
--WHERE	CompanyId = 'NDS'
--		AND AccountNumber = @Account
--		AND (ProNumber = @ProNumber
--		OR SOPDocumentNumber = @ProNumber)

DROP TABLE #tmpReportData
/*
UPDATE	EscrowTransactions
SET		ProNumber = '96-72685'
WHERE	ESCROWTRANSACTIONID = 2007051

UPDATE	EscrowTransactions
SET		SOPDocumentNumber = Null
WHERE	ESCROWTRANSACTIONID = 1997042
*/