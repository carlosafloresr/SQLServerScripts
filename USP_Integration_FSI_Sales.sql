USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Integration_FSI_Sales]    Script Date: 1/24/2023 4:25:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE	USP_Integration_FSI_Sales 'IMC', '1FSI20220216_1030', 1
EXECUTE	USP_Integration_FSI_Sales 'GLSO', '9FSI20230122_1216', 1, 'C96-260023'
EXECUTE	USP_Integration_FSI_Sales 'GIS', '2FSI20211111_1611', 0
*/
ALTER PROCEDURE [dbo].[USP_Integration_FSI_Sales]
	@Company	Varchar(5),
	@BatchId	Varchar(25),
	@Status		Smallint = 0,
	@InvoiceNo	Varchar(25) = Null
AS
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
SELECT DISTINCT DetailId, AccCode FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND RecordType = 'VND' AND AccCode = @DemmurageAcc

INSERT INTO @tblParCodes VALUES ('FSISALESDEBACCT')
INSERT INTO @tblParCodes VALUES ('FSISALESCREACCT')
INSERT INTO @tblParCodes VALUES ('FSISUMMARYACCOUNT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AR_CREDIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AR_DEBIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_ADMINFEEACT')

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN (SELECT ParCode FROM @tblParCodes)
		AND Company = @Company

IF @BatchId LIKE '%_SUM%'
BEGIN
	PRINT 'Summary Batch'

	SELECT	DISTINCT FSI_ReceivedHeaderId
			,DetailId
			,Company
			,WeekEndDate
			,ReceivedOn
			,TotalTransactions
			,TotalSales
			,TotalVendorAccrual
			,TotalTruckAccrual
			,FSI_ReceivedDetailId
			,BatchId
			,VoucherNumber
			,VFSI.InvoiceNumber
			,Original_InvoiceNumber
			,CustomerNumber
			,ApplyTo
			,BillToRef
			,InvoiceDate
			,DeliveryDate
			,DueDate
			,AccessorialTotal
			,VendorPayTotal
			,FuelSurcharge
			,FuelRebateTotal
			,InvoiceTotal
			,DocumentType
			,ShipperName
			,ShipperCity
			,ConsigneeName
			,ConsigneeCity
			,BrokeredSale
			,TruckAccrualTotal
			,CompanyTruckAccrual
			,CompanyTruckDivision
			,CompanyTruckFuelRebate
			,CompanyDriverPay
			,InvoiceType
			,Division
			,RatingTable
			,Verification
			,Processed
			,Status
			,'NON' AS RecordType
			,Intercompany
			,Agent
			,RecordStatus
			,Equipment
			,CAST(0 AS Bit) AS WithIntercompany
			,ReceivedOn
			,IsDemurrage = CAST(0 AS Bit)
			,DebitAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSISUMMARYACCOUNT')
			,CreditAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSISUMMARYACCOUNT')
			,0 AS DemurrageAdminFeeAmount 
			,'' AS DemurrageAdminFeeAcct
			,'' AS DemurrageGLAccount
			,CAST(0 AS Bit) AS DemurrageError
			,0 AS DemurrageARAmnt
			,0 AS DemurrageAPAmnt
			,InvoiceTotal AS NonDemurrageAmount
			,CAST(0 AS Bit) AS WithDemurrage
			,CAST(0 AS Bit) AS WithAdminFee
	FROM	View_Integration_FSI VFSI
	WHERE	VFSI.Company = @Company
			AND VFSI.BatchId = @BatchId
			AND VFSI.Intercompany = 0
			AND VFSI.InvoiceTotal <> 0
			AND VFSI.DetailProcessed = @Status
	ORDER BY DetailId
END
ELSE
BEGIN
	PRINT 'Regular Batch'

	SELECT	*
	INTO	#tmpFSI_SalesData
	FROM	View_Integration_FSI
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Intercompany = 0
			AND InvoiceTotal <> 0
			AND ICB = 0
			AND (@InvoiceNo IS Null
			OR (@InvoiceNo IS NOT nULL AND InvoiceNumber = @InvoiceNo))

	DECLARE @tblFSISubDetails	Table (DetailId Varchar(10), RecordType Varchar(5), AccCode Varchar(5), ChargeAmount1 Numeric(10,2), DemurrageAdminFee Numeric(10,2))

	DECLARE	@WithPrePay			Bit = 0,
			@WithVendorPay		Bit = 0,
			@WithIntercompany	Bit = 0
	
	SET @WithPrePay			= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND RecordType = 'VND' AND PrePay = 1) THEN 1 ELSE 0 END) AS Bit)
	SET @WithVendorPay		= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND RecordType = 'VND' AND PrePay = 0) THEN 1 ELSE 0 END) AS Bit)
	SET @WithIntercompany	= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedDetails WHERE BatchId = @BatchId AND Intercompany = 1) OR EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND VndIntercompany = 1) THEN 1 ELSE 0 END) AS Bit)
	
	INSERT INTO @tblFSISubDetails
	SELECT	DetailId, RecordType, ISNULL(AccCode, RecordCode) AS AccCode, SUM(ChargeAmount1) AS ChargeAmount1, SUM(DemurrageAdminFee) AS DemurrageAdminFee
	FROM	FSI_ReceivedSubDetails
	WHERE	BatchId = @BatchId
			AND VndIntercompany = 0
			AND ICB = 0
			AND ((RecordType = 'ACC' AND RecordCode = @DemmurageAcc)
			OR (RecordType = 'VND' AND AccCode = @DemmurageAcc))
	GROUP BY DetailId, RecordType, ISNULL(AccCode, RecordCode)

	SELECT	DATA.*
			,DebitAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal = DemurrageARAmnt, IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'), IIF(InvoiceTotal < 0, 'FSISALESCREACCT', 'FSISALESDEBACCT')))
			,CreditAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal = DemurrageARAmnt, IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_DEBIT', 'DEMURRAGE_AR_CREDIT'), IIF(InvoiceTotal < 0, 'FSISALESDEBACCT', 'FSISALESCREACCT')))
			,DemurrageAdminFeeAmount = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0, DemurrageAdmFee, 0)
			,DemurrageAdminFeeAcct = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_ADMINFEEACT')
			,DemurrageGLAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_AR_CREDIT') --IIF(InvoiceTotal > 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'))
			,NonDemurrageAmount = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal <> DemurrageARAmnt, InvoiceTotal - DemurrageARAmnt, InvoiceTotal)
			,DemurrageError = CAST(0 AS Bit) --CAST(IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND DemurrageAPAmnt = 0 AND ComponentBill = 0, 1, 0) AS Bit)
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
					,IsDemurrage = IIF(EXISTS(SELECT DetailId FROM @tblFSISubDetails FS WHERE VFSI.DetailId = FS.DetailId AND FS.RecordType = 'ACC'), 1, 0) -- AND DET.AccCode IS NOT Null: Removed on 01/24/2023 by CFLORES
					,DemurrageAdmFee = ISNULL((SELECT DemurrageAdminFee FROM @tblFSISubDetails F2 WHERE VFSI.DetailId = F2.DetailId AND F2.RecordType = 'ACC'), 0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
					,DemurrageARAmnt = ISNULL((SELECT ChargeAmount1 FROM @tblFSISubDetails FS WHERE FS.DetailId = VFSI.DetailId AND FS.RecordType = 'ACC'),0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
					,DemurrageAPAmnt = ISNULL((SELECT ChargeAmount1 FROM @tblFSISubDetails F3 WHERE F3.DetailId = VFSI.DetailId AND F3.RecordType = 'VND'),0) -- AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
			FROM	#tmpFSI_SalesData VFSI
					LEFT JOIN @tblSubDetails DET ON VFSI.DetailId = DET.DetailId
			WHERE	(VFSI.PrePayType IS Null OR VFSI.PrePayType <> 'A')
					AND ((VFSI.DetailProcessed = @Status AND @Status <> 10)
					OR (VFSI.InvoiceType = 'C' AND @Status = 10))
			) DATA
	ORDER BY InvoiceNumber

	DROP TABLE #tmpFSI_SalesData

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

	DROP TABLE #tmpFsiSalesData	
END