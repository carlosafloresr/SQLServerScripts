USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_PopUp_DataInsert]    Script Date: 10/5/2022 9:26:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_PopUp_DataInsert 138008, 1, 'DM-A007223', 32768, 'CU151215101049R', 'CUINV'
*/
ALTER PROCEDURE [dbo].[USP_PopUp_DataInsert]
		@RecordId		Int,
		@RecordType		Int,
		@Voucher		Varchar(30),
		@ItemNumber		Int,
		@BatchId		Varchar(30),
		@Integration	Varchar(5) = 'DXP',
		@PostingDate	Date = Null,
		@Comments		Varchar(1000) = Null
AS
IF @RecordType = 1
BEGIN
	-- *** ESCROW TRANSACTIONS ***
	DECLARE	@CompanyId		Varchar(5),
			@Source			Varchar(5),
			@ClaimNumber	Varchar(15),
			@DocumentNumber	Varchar(30),
			@GLAccount		Varchar(15),
			@TransactionId	Int

	INSERT INTO EscrowTransactions
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
			,SOPDocumentNumber
			,BatchId
			,UnitNumber
			,RepairDate
			,ETA
			,PopUpId)
	SELECT	Source
			,ISNULL(@Voucher, VoucherNumber) AS VoucherNumber
			,@ItemNumber AS ItemNumber
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
			,ISNULL(Comments,@Comments)
			,ProNumber
			,TransactionDate
			,Null --ISNULL(@PostingDate, PostingDate)
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,CASE WHEN @Integration = 'CUINV' THEN InvoiceNumber ELSE Null END
			,@BatchId AS BatchId
			,UnitNumber
			,RepairDate
			,ETADate
			,DEX_ET_PopUpsId
	FROM	DEX_ET_PopUps
	WHERE	DEX_ET_PopUpsId = @RecordId

	SET @TransactionId = @@IDENTITY

	SELECT	@CompanyId		= RTRIM([CompanyId]),
			@Source			= [Source],
			@DocumentNumber	= RTRIM(DocNumber),
			@GLAccount		= RTRIM([AccountNumber])
	FROM	DEX_ET_PopUps 
	WHERE	DEX_ET_PopUpsId = @RecordId

	IF @Voucher = '<NOT_DEFINED>' AND @ItemNumber = 0 AND @TransactionId > 0
	BEGIN
		DECLARE	@Query		Varchar(Max)
		DECLARE	@tblData	Table (Journal	Int, [Sequence] Int)

		SET @Query = N'SELECT GLT.JRNENTRY, CAST(GLT.SQNCLINE AS Int) AS SQNCLINE FROM ' + @CompanyId + '.dbo.GL10001 GLT
		INNER JOIN ' + @CompanyId + '.dbo.GL00105 GLA ON GLT.ACTINDX = GLA.ACTINDX
		WHERE	GLT.DEBITAMT + GLT.CRDTAMNT <> 0
				AND GLT.BACHNUMB = ''' + @BatchId + ''' 
				AND GLT.ORDOCNUM = ''' + @DocumentNumber + '''
				AND GLA.ACTNUMST = ''' + @GLAccount + ''''
		
		INSERT INTO @tblData
		EXECUTE(@Query)

		IF @@ROWCOUNT > 0
		BEGIN
			SELECT	@Voucher	= CAST(Journal AS Varchar),
					@ItemNumber	= [Sequence]
			FROM	@tblData

			UPDATE	EscrowTransactions
			SET		VoucherNumber	= @Voucher,
					ItemNumber		= @ItemNumber
			WHERE	EscrowTransactionId = @TransactionId
		END
	END
END
ELSE
BEGIN
	-- *** M&R TO CUSTOMER EQUIPMENT ***
	INSERT INTO ExpenseRecovery
			(Company
			,VoucherNo
			,Vendor
			,ProNumber
			,Reference
			,Expense
			,Recovery
			,DocNumber
			,EffDate
			,InvDate
			,Trailer
			,Chassis
			,FailureReason
			,Recoverable
			,DriverId
			,DriverType
			,RepairType
			,GLAccount
			,RecoveryAction
			,Status
			,Notes
			,ItemNumber
			,Closed
			,Source
			,RepairTypeText
			,DriverTypeText
			,DriverName
			,RecoverableText
			,Division
			,StatusText
			,ATPAmount
			,ATPDeductions
			,StartingDate
			,CreationDate
			,PopUpId
			,DataUpdated)
	SELECT	POP.Company
			,@Voucher AS VoucherNo
			,LEFT(RTRIM(DEX.VendorId) + '-' + dbo.GetVendorName(POP.Company, DEX.VendorId), 30) AS Vendor
			,POP.ProNumber
			,POP.Reference
			,POP.Expense
			,POP.Recovery
			,POP.DocNumber
			,Null --ISNULL(@PostingDate, POP.EffDate)
			,POP.InvDate
			,POP.Trailer
			,POP.Chassis
			,ISNULL(POP.FailureReason, DEX.DistRef) AS FailureReason
			,POP.Recoverable
			,POP.DriverId
			,POP.DriverType
			,POP.RepairType
			,POP.GLAccount
			,POP.RecoveryAction
			,POP.Status
			,ISNULL(POP.Notes,@Comments)
			,@ItemNumber AS ItemNumber
			,POP.Closed
			,POP.Source
			,POP.RepairTypeText
			,POP.DriverTypeText
			,POP.DriverName
			,POP.RecoverableText
			,POP.Division
			,POP.StatusText
			,POP.ATPAmount
			,POP.ATPDeductions
			,POP.StartingDate
			,POP.CreationDate
			,@RecordId
			,1
	FROM	DEX_ER_PopUps POP
			LEFT JOIN IntegrationsDB.Integrations.dbo.Integrations_AP DEX ON DEX.Integration = @Integration AND POP.DEX_ER_PopUpsId = DEX.PopUpId
	WHERE	POP.DEX_ER_PopUpsId = @RecordId
END