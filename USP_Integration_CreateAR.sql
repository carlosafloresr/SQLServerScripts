CREATE PROCEDURE USP_Integration_CreateAR
	@WithInvalidData	Bit,
	@Company			Varchar(5),
	@BatchId			Varchar(25),
	@UserId				Varchar(25),
	@EmailAddrs			Varchar(50),
	@Subject			Varchar(50),
	@Message			Varchar(Max)
AS
DECLARE	@RecordId			Int,
		@DocNumbr			Varchar(30),
		@DocAmnt			Money,
		@DocDate			Datetime,
		@ApToDcnm			Varchar(30),
		@IntApToBal			Money,
		@GPAptoBal			Money,
		@CustNmbr			Varchar(15),
		@PONumber			Varchar(25),
		@Division			Char(2),
		@FileName			Varchar(50),
		@RmdTypal			Int,
		@DistType			Int,
		@ActNumSt			Varchar(75),
		@DebitAmt			Money,
		@CrdtAmnt			Money,
		@DistRef			Varchar(30),
		@AccountCrd			Varchar(12),
		@AccountDeb			Varchar(12)

IF @WithInvalidData = 0
BEGIN
	SET	@AccountCrd = dbo.ReadParameter_Char('FSISALESCREACCT', @Company)
	SET	@AccountDeb = dbo.ReadParameter_Char('FSISALESDEBACCT', @Company)

	DELETE dbo.Integrations_AR WHERE BatchId = @BatchId AND Company = @Company

	DECLARE curBatch CURSOR FOR
		SELECT	FSI_ReceivedDetailId AS RecordId
				,dbo.ValidateDocument('AR',InvoiceNumber,Null) AS DOCNUMBR
				,InvoiceTotal AS DOCAMNT
				,CASE WHEN WeekEndDate > ReceivedOn THEN ReceivedOn ELSE WeekEndDate END AS DOCDATE
				,ApplyTo AS APTODCNM
				,CASE WHEN InvoiceNumber = ApplyTo THEN 0 ELSE dbo.FindFSIApplySummary(@BatchId,InvoiceNumber,FSI_ReceivedDetailId) END AS IntegrationApplyTo
				,CASE WHEN InvoiceNumber = ApplyTo THEN 0 ELSE dbo.AR_DocumentBalance(CustomerNumber,InvoiceNumber) END AS GPDocBalance
				,CustomerNumber AS CUSTNMBR
				,BillToRef AS PONumber
				,Division
				,'FSI_' + dbo.PADL(ROW_NUMBER() OVER (ORDER BY FSI_ReceivedDetailId), 4, '0') + '.xml' AS FileName
		FROM	dbo.View_Integration_FSI 
		WHERE	BatchId = @BatchId 
				AND InvoiceTotal <> 0 
		ORDER BY FSI_ReceivedDetailId
	
	OPEN curBatch
	
	FETCH NEXT FROM curBatch 
	INTO @RecordId,
		@DocNumbr,
		@DocAmnt,
		@DocDate,
		@ApToDcnm,
		@IntApToBal,
		@GPAptoBal,
		@CustNmbr,
		@PONumber,
		@Division,
		@FileName
			
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @RmdTypal = CASE WHEN @DocAmnt > 0 THEN 1 ELSE 7 END

		IF @DocAmnt > 0
			SET @DistRef = 'FSI Credit PN: ' + RTRIM(@ApToDcnm)
		ELSE
			SET @DistRef = 'Ref # ' + RTRIM(@PONumber)

		-- Debit Input
		INSERT INTO dbo.Integrations_AR
			   (Integration
				,Company
				,BatchId
				,BACHNUMB
				,DOCNUMBR
				,CSTPONBR
				,CUSTNMBR
				,DOCDATE
				,DUEDATE
				,DOCAMNT
				,SLSAMNT
				,RMDTYPAL
				,ACTNUMST
				,DISTTYPE
				,DEBITAMT
				,CRDTAMNT
				,DistRef
				,DistRecords
				,IntApToBal
				,GPAptoBal
				,PTDUSRID)
		VALUES
			   ('FSI'
				,@Company
				,@BatchId
				,'FSI' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1)
				,@DocNumbr
				,@PONumber
				,@CustNmbr
				,@DocDate
				,@DocDate + 30
				,ABS(@DocAmnt)
				,ABS(@DocAmnt)
				,@RmdTypal
				,CASE WHEN @DocAmnt > 0 THEN @AccountDeb ELSE @AccountCrd END -- Account Number
				,CASE WHEN @DocAmnt > 0 THEN 3 ELSE 19 END -- Distribution Type
				,ABS(@DocAmnt)
				,0
				,@DistRef
				,2
				,@IntApToBal
				,@GPAptoBal
				,@UserId)

		-- Credit Input
		INSERT INTO dbo.Integrations_AR
			   (Integration
				,Company
				,BatchId
				,BACHNUMB
				,DOCNUMBR
				,CSTPONBR
				,CUSTNMBR
				,DOCDATE
				,DUEDATE
				,DOCAMNT
				,SLSAMNT
				,RMDTYPAL
				,ACTNUMST
				,DISTTYPE
				,DEBITAMT
				,CRDTAMNT
				,DistRef
				,DistRecords
				,IntApToBal
				,GPAptoBal
				,PTDUSRID)
		VALUES
			   ('FSI'
				,@Company
				,@BatchId
				,'FSI' + dbo.FormatDateYMD(GETDATE(), 1, 1, 1)
				,@DocNumbr
				,@PONumber
				,@CustNmbr
				,@DocDate
				,@DocDate + 30
				,ABS(@DocAmnt)
				,ABS(@DocAmnt)
				,@RmdTypal
				,CASE WHEN @DocAmnt < 0 THEN @AccountDeb ELSE @AccountCrd END -- Account Number
				,CASE WHEN @DocAmnt < 0 THEN 3 ELSE 19 END -- Distribution Type
				,0
				,ABS(@DocAmnt)
				,@DistRef
				,2
				,@IntApToBal
				,@GPAptoBal
				,@UserId)

		FETCH NEXT FROM curBatch 
		INTO @RecordId,
			@DocNumbr,
			@DocAmnt,
			@DocDate,
			@ApToDcnm,
			@IntApToBal,
			@GPAptoBal,
			@CustNmbr,
			@PONumber,
			@Division,
			@FileName
	END

	CLOSE curBatch
	DEALLOCATE curBatch

	EXECUTE dbo.USP_ReceivedIntegrations 'FSI', @Company, @BatchId, 1, @EmailAddrs, @Subject, @Message
END
ELSE
BEGIN
	EXECUTE dbo.USP_ReceivedIntegrations 'FSI', @Company, @BatchId, -1, @EmailAddrs, @Subject, @Message
END