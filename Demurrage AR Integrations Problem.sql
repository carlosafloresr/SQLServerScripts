DECLARE	@Company	Varchar(5) = 'AIS',
		@BatchId	Varchar(25) = '4FSI20230109_1613',
		@Status		Smallint = 1

SET NOCOUNT ON

DECLARE	@Intercompany	Bit,
		@DemmurageAcc	Varchar(5),
		@Counter		Int
DECLARE	@tblParCodes	Table (ParCode Varchar(50))
DECLARE	@tblParameters	Table (Company Varchar(5), ParameterCode Varchar(50), VarC Varchar(100))
DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))
DECLARE @tblSubDetails	Table (DetailId Char(10), AccCode Varchar(5))

SET @DemmurageAcc = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')

INSERT INTO @tblSubDetails
SELECT DISTINCT DetailId, AccCode FROM FSI_ReceivedSubDetails WITH (NOLOCK) WHERE BatchId = @BatchId AND RecordType = 'VND' AND AccCode = @DemmurageAcc

INSERT INTO @tblParCodes VALUES ('FSISALESDEBACCT')
INSERT INTO @tblParCodes VALUES ('FSISALESCREACCT')
INSERT INTO @tblParCodes VALUES ('FSISUMMARYACCOUNT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AR_CREDIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AR_DEBIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_ADMINFEEACT')

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters WITH (NOLOCK)
WHERE	ParameterCode IN (SELECT ParCode FROM @tblParCodes)
		AND Company = @Company

	PRINT 'Regular Batch'

	DECLARE @tblFSISubDetails	Table (DetailId Varchar(10), RecordType Varchar(5), RecordCode Varchar(20), AccCode Varchar(5), ChargeAmount1 Numeric(10,2), DemurrageAdminFee Numeric(10,2))

	DECLARE	@WithPrePay			Bit = 0,
			@WithVendorPay		Bit = 0,
			@WithIntercompany	Bit = 0
	
	SET @WithPrePay			= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM View_Integration_FSI_Full WHERE BatchId = @BatchId AND RecordType = 'VND' AND PrePay = 1) THEN 1 ELSE 0 END) AS Bit)
	SET @WithVendorPay		= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM View_Integration_FSI_Full WHERE BatchId = @BatchId AND RecordType = 'VND' AND PrePay = 0) THEN 1 ELSE 0 END) AS Bit)
	SET @WithIntercompany	= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedDetails WITH (NOLOCK) WHERE BatchId = @BatchId AND Intercompany = 1) OR EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND VndIntercompany = 1) THEN 1 ELSE 0 END) AS Bit)

	INSERT INTO @tblFSISubDetails
	SELECT	DetailId, RecordType, RecordCode, AccCode, ChargeAmount1, DemurrageAdminFee
	FROM	FSI_ReceivedSubDetails WITH (NOLOCK)
	WHERE	BatchId = @BatchId
			AND VndIntercompany = 0
			AND ICB = 0
			--AND PrePayType IS Null

	SELECT	DATA.*
			,DebitAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal = DemurrageARAmnt, IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'), IIF(InvoiceTotal < 0, 'FSISALESCREACCT', 'FSISALESDEBACCT')))
			,CreditAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal = DemurrageARAmnt, IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_DEBIT', 'DEMURRAGE_AR_CREDIT'), IIF(InvoiceTotal < 0, 'FSISALESDEBACCT', 'FSISALESCREACCT')))
			,DemurrageAdminFeeAmount = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND DemurrageAPAmnt = 0 AND ComponentBill = 0, 0, DemurrageAdmFee)
			,DemurrageAdminFeeAcct = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_ADMINFEEACT')
			,DemurrageGLAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_AR_CREDIT') --IIF(InvoiceTotal > 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'))
			,NonDemurrageAmount = IIF(IsDemurrage = 1 AND (DemurrageARAmnt <> 0 OR DemurrageAPAmnt <> 0) AND InvoiceTotal <> DemurrageARAmnt, InvoiceTotal - DemurrageARAmnt, InvoiceTotal)
			,DemurrageError = CAST(IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND DemurrageAPAmnt = 0 AND ComponentBill = 0, 1, 0) AS Bit)
	INTO	#tmpFsiSalesData
	FROM	(
			SELECT	Company
					,WeekEndDate
					,FSI_ReceivedDetailId
					,BatchId
					,VFSI.DetailId
					,VoucherNumber
					,InvoiceNumber
					,Original_InvoiceNumber
					,CustomerNumber
					,ApplyTo
					,BillToRef
					,InvoiceDate
					,InvoiceTotal
					,DocumentType
					,InvoiceType
					,Division
					,DetailProcessed AS Processed
					,Status
					,Agent
					,Equipment
					,@WithPrePay AS WithPrePay
					,@WithVendorPay AS WithVendorPay
					,@WithIntercompany AS WithIntercompany
					,ReceivedOn
					,ComponentBill
					,IsDemurrage = IIF(EXISTS(SELECT TOP 1 FS.DetailId FROM @tblFSISubDetails FS WHERE FS.DetailId = VFSI.DetailId AND FS.RecordType = 'ACC' AND FS.RecordCode = @DemmurageAcc), 1, 0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
					,DemurrageAdmFee = ISNULL((SELECT SUM(DemurrageAdminFee) FROM @tblFSISubDetails F2 WHERE VFSI.DetailId = F2.DetailId AND F2.RecordType = 'ACC' AND F2.RecordCode = @DemmurageAcc), 0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
					,DemurrageARAmnt = ISNULL((SELECT SUM(ChargeAmount1) FROM @tblFSISubDetails FS WHERE FS.DetailId = VFSI.DetailId AND FS.RecordType = 'ACC' AND FS.RecordCode = @DemmurageAcc),0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
					,DemurrageAPAmnt = ISNULL((SELECT SUM(ChargeAmount1) FROM @tblFSISubDetails F3 WHERE F3.DetailId = VFSI.DetailId AND F3.RecordType = 'VND' AND F3.AccCode = @DemmurageAcc),0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
			FROM	View_Integration_FSI VFSI WITH (NOLOCK)
					LEFT JOIN @tblSubDetails DET ON VFSI.DetailId = DET.DetailId
			WHERE	VFSI.BatchId = @BatchId
					AND VFSI.InvoiceNumber = '39-185300-A'
					AND VFSI.Intercompany = 0
					AND VFSI.InvoiceTotal <> 0
					AND VFSI.ICB = 0
					AND (VFSI.PrePayType IS Null OR VFSI.PrePayType <> 'A')
					AND ((VFSI.DetailProcessed = @Status AND @Status <> 10)
					OR (VFSI.InvoiceType = 'C' AND @Status = 10))
			) DATA
	ORDER BY InvoiceNumber

	SET @Counter = (SELECT COUNT(*) FROM #tmpFsiSalesData)

	PRINT @Counter

	SELECT	Company
			,WeekEndDate
			,FSI_ReceivedDetailId
			,BatchId
			,DetailId
			,VoucherNumber
			,InvoiceNumber
			,Original_InvoiceNumber
			,CustomerNumber
			,ApplyTo
			,BillToRef
			,InvoiceDate
			,InvoiceTotal
			,DocumentType
			,InvoiceType
			,Division
			,Processed
			,Status
			,Agent
			,Equipment
			,WithPrePay
			,WithVendorPay
			,WithIntercompany
			,ReceivedOn
			,ComponentBill
			,IsDemurrage
			--,IIF(IsDemurrage = 1 AND NonDemurrageAmount = InvoiceTotal, 0, IsDemurrage) AS IsDemurrage
			,DemurrageAdmFee * IIF(InvoiceTotal < 0, -1, 1) AS DemurrageAdmFee
			,DemurrageARAmnt
			,DemurrageAPAmnt
			,dbo.GLAccountDivision(Company, Division, DebitAccount) AS DebitAccount
			,dbo.GLAccountDivision(Company, Division, CreditAccount) AS CreditAccount
			,DemurrageAdminFeeAmount * IIF(InvoiceTotal < 0, -1, 1) AS DemurrageAdminFeeAmount
			,dbo.GLAccountDivision(Company, Division, DemurrageAdminFeeAcct) AS DemurrageAdminFeeAcct
			,dbo.GLAccountDivision(Company, Division, DemurrageGLAccount) AS DemurrageGLAccount
			,NonDemurrageAmount
			,DemurrageError
			,WithDemurrage = CAST(IIF((SELECT COUNT(*) FROM #tmpFsiSalesData WHERE IsDemurrage = 1 AND NonDemurrageAmount <> InvoiceTotal) > 0, 1, 0) AS Bit)
			,WithAdminFee = CAST(IIF((SELECT SUM(DemurrageAdminFeeAmount) FROM #tmpFsiSalesData) > 0, 1, 0) AS Bit)
	FROM	#tmpFsiSalesData
	ORDER BY InvoiceNumber

	--SELECT * FROM @tblFSISubDetails FS WHERE FS.DetailId = 441 AND FS.RecordType = 'ACC' AND FS.RecordCode = @DemmurageAcc

	DROP TABLE #tmpFsiSalesData

/*
SELECT	*
FROM	View_Integration_FSI_Full
WHERE	BatchId = '4FSI20230109_1613'
		AND InvoiceNumber IN ('39-185300-A','39-184836')
		--AND (AccCode = 'DEM'
		--OR (RecordType = 'ACC' AND RecordCode = 'DEM'))
*/