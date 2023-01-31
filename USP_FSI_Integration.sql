DECLARE	@Company	Varchar(5),
		@BatchId	Varchar(25),
		@UserId		Varchar(25)

SET		@Company	= 'AIS'
SET		@BatchId	= '4FSI081018_10172008_1251'
SET		@UserId		= 'CFLORES'

DECLARE	@CustomerNumber		Varchar(10),
		@WeekEndDate		Datetime,
		@ReceivedOn			Datetime,
		@Agent				Char(2),
		@TotalTransactions	Int,
		@TotalSales			Money,
		@TotalVendorAccrual	Money,
		@TotalTruckAccrual	Money,
		@Message			Varchar(Max),
		@CustomerLine		Varchar(1000),
		@WithInvalidData	Bit,
		@RecordId			Int,
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
		@AccountDeb			Varchar(12),
		@EmailAddrs			Varchar(50),
		@Subject			vARCHAR(50)
		
SET	@EmailAddrs		= dbo.ReadParameter_Char('FSI_EMAILADDRESS', 'ALL')
SET	@CustomerLine	= '<tr><td width="130" align="center" style="font-family: Arial; font-size: 10px; font-weight: bold" bgcolor="#C0C0C0">
			<font size="2">Customer Number</font></td><td align="left" style="font-family: Arial; font-size: 10px; color: #0000FF">
			<font size="2">CUSTNUMBER</font></td></tr>'
	
IF EXISTS(SELECT TOP 1 CustomerNumber FROM dbo.FSI_ReceivedDetails WHERE BatchId = @BatchId AND dbo.ValidateCustomer(CustomerNumber) = 0)
BEGIN
	SET @Subject = RTRIM(@Company) + '. Received Batch ' + RTRIM(@BatchId) + ' with invalid customer(s) in Great Plains'
	SET	@Message = '<div align="left"><b><font face="Arial" size="2">Invalid Customers in Great Plains:</font></b><table border="1" width="198" cellspacing="1" bordercolorlight="#000000" style="border-collapse: collapse">'
	SET	@WithInvalidData = 1
	
	DECLARE curCustomers CURSOR FOR
		SELECT	DISTINCT CustomerNumber
		FROM	dbo.FSI_ReceivedDetails
		WHERE	BatchId = @BatchId
				AND dbo.ValidateCustomer(CustomerNumber) = 0
				
	OPEN curCustomers
	
	FETCH NEXT FROM curCustomers INTO @CustomerNumber
			
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET	@Message = @Message + REPLACE(@CustomerLine, 'CUSTNUMBER', RTRIM(@CustomerNumber))
		
		FETCH NEXT FROM curCustomers INTO @CustomerNumber
	END
	
	SET	@Message = @Message + '</table></div>'
	
	CLOSE curCustomers
	DEALLOCATE curCustomers
END
ELSE
BEGIN
	SET @Subject = RTRIM(@Company) + '. Received Batch ' + RTRIM(@BatchId) + ' in Great Plains'
	SET	@Message = dbo.ReadParameter_Memo('FSIBATCHINFO', 'ALL')
	SET	@WithInvalidData = 0
	
	DECLARE curBatch CURSOR FOR
		SELECT	WeekEndDate
				,ReceivedOn
				,TotalTransactions
				,TotalSales
				,TotalVendorAccrual
				,TotalTruckAccrual
		FROM	dbo.FSI_ReceivedHeader
		WHERE	BatchId = @BatchId
		
	OPEN curBatch
	
	FETCH NEXT FROM curBatch 
	INTO @WeekEndDate
		,@ReceivedOn
		,@TotalTransactions
		,@TotalSales
		,@TotalVendorAccrual
		,@TotalTruckAccrual
			
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET	@Message = REPLACE(@Message, 'WEEKENDING', CONVERT(Char(10), @WeekEndDate, 101))
		SET	@Message = REPLACE(REPLACE(@Message, 'RECEIVEDON', CONVERT(Char(19), @ReceivedOn, 100)), '  ', ' ')
		SET	@Message = REPLACE(@Message, 'TOTALRECORDS', CONVERT(Varchar(12), @TotalTransactions))
		SET	@Message = REPLACE(@Message, 'TOTSALES', '$' + CONVERT(Varchar(12), @TotalSales, 1))
		SET	@Message = REPLACE(@Message, 'TOTVENDOR', '$' + CONVERT(Varchar(12), @TotalVendorAccrual, 1))
		SET	@Message = REPLACE(@Message, 'TOTTRUCK', '$' + CONVERT(Varchar(12), @TotalTruckAccrual, 1))
		
		FETCH NEXT FROM curBatch 
		INTO @WeekEndDate
			,@ReceivedOn
			,@TotalTransactions
			,@TotalSales
			,@TotalVendorAccrual
			,@TotalTruckAccrual
	END
	
	CLOSE curBatch
	DEALLOCATE curBatch
END

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

-- truncate table GPCustom.dbo.Integrations_AR 0xE0