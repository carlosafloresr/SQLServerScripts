DECLARE	@BatchId	Varchar(25) = 'EFSMC_03292021',
		@Company	Varchar(5) = DB_NAME()

--INSERT INTO GPCustom.dbo.EscrowTransactions
--			(Source
--			,VoucherNumber
--			,ItemNumber
--			,CompanyId
--			,Fk_EscrowModuleId
--			,AccountNumber
--			,AccountType
--			,VendorId
--			,DriverId
--			,Division
--			,Amount
--			,ClaimNumber
--			,DriverClass
--			,AccidentType
--			,Status
--			,DMSubmitted
--			,DeductionPlan
--			,Comments
--			,ProNumber
--			,TransactionDate
--			,PostingDate
--			,EnteredBy
--			,EnteredOn
--			,ChangedBy
--			,ChangedOn
--			,Void
--			,InvoiceNumber
--			,BatchId)
	SELECT	Source
			,VCHRNMBR AS VoucherNumber
			,16384 AS ItemNumber
			,CompanyId
			,Fk_EscrowModuleId
			,AccountNumber
			,AccountType
			,DEX.VendorId
			,DriverId
			,Division
			,Amount
			,ClaimNumber
			,DriverClass
			,AccidentType
			,Status
			,DMSubmitted
			,DeductionPlan
			,Comments
			,ProNumber
			,TransactionDate 
			,PSTGDATE
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,BatchId
	FROM	GPCustom.dbo.DEX_ET_PopUps DEX
			INNER JOIN (
						SELECT	DISTINCT VCHRNMBR, DOCNUMBR, VENDORID, PSTGDATE
						FROM	PM20000
						WHERE	DOCNUMBR IN (SELECT DocNumber FROM GPCustom.dbo.DEX_ET_PopUps WHERE BatchId = @BatchId)
						UNION
						SELECT	DISTINCT VCHRNMBR, DOCNUMBR, VENDORID, PSTGDATE
						FROM	PM30200
						WHERE	DOCNUMBR IN (SELECT DocNumber FROM GPCustom.dbo.DEX_ET_PopUps WHERE BatchId = @BatchId)
						) APP ON DEX.DocNumber = APP.DOCNUMBR AND DEX.VendorId = APP.VENDORID
	WHERE	DEX.BatchId = @BatchId
			AND DEX.CompanyId = @Company
