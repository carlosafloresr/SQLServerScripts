DECLARE	@BatchId	Varchar(25) = 'EFSMC_09142020',
		@Company	Varchar(5) = DB_NAME()

INSERT INTO GPCustom.dbo.EscrowTransactions
			(Source
			,VoucherNumber
			,ItemNumber
			,CompanyId
			,Fk_EscrowModuleId
			,AccountNumber
			,AccountType
			,VendorId
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
			,PostingDate
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,BatchId)
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
						SELECT	AP.*,
								PM.PopUpId AS RecordId
						FROM	PM20000 AP
								LEFT JOIN PRISQL004P.Integrations.dbo.Integrations_AP PM ON AP.VCHRNMBR = PM.VCHNUMWK AND AP.VENDORID = PM.VENDORID
						WHERE	AP.BACHNUMB = 'EFSMC_09142020'
						) APP ON DEX.DEX_ET_PopUpsId = APP.RecordId
	WHERE	DEX.BatchId = @BatchId
			AND DEX.CompanyId = @Company
