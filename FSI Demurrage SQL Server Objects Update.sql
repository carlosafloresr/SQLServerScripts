USE [Integrations]
GO

/****** Object:  View [dbo].[View_FSI_NonSale]    Script Date: 9/8/2021 10:28:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
SELECT	*
FROM	View_FSI_NonSale
WHERE	BatchId = '9FSI20210708_1547' --'9FSI20210629_1201'
		--AND IsDemurrage = 1
*/
ALTER VIEW [dbo].[View_FSI_NonSale]
AS
SELECT	DT.Company, 
		CAST(WeekEndDate AS Date) AS WeekEndDate, 
		BatchId, 
		InvoiceNumber,
		InvoiceDate,
		BillToRef, 
		InvoiceType, 
		Division, 
		RecordCode AS VendorId,
		Amount,
		VndIntercompany,
		CASE WHEN RecordType = 'ACC' THEN Equipment
			 ELSE VendorDocument END AS VendorDocument,
		VendorReference,
		AccCode,
		LEFT(CASE WHEN Company = 'GLSO' THEN InvoiceNumber + '|' + VendorDocument ELSE Equipment + '|' + InvoiceNumber END, 30) AS PrepayReference,
		CASE WHEN ICB_AP = 1 AND RecordType = 'VND' AND IsDemurrage = 0 THEN 'ICB' -- 4
			 WHEN ICB_AR = 1 AND RecordType <> 'VND' AND IsDemurrage = 0 THEN 'ICB' -- 4
			 WHEN ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P' AND PierPassType = 0 AND IsDemurrage = 0 THEN 'PREPAY' -- 3
			 WHEN PrePayType = 'A' AND IsDemurrage = 0 THEN 'ACCRUAL' -- 7
			 WHEN PierPassType = 1 AND IsDemurrage = 0 THEN 'PIERPASS' -- 5
			 WHEN VndIntercompany = 1 AND IsDemurrage = 0 THEN 'INTERCOMPANY' -- 2
			 WHEN PerDiemType = 1 AND IsDemurrage = 0 THEN 'PERDIEM' -- 6
			 WHEN IsDemurrage = 1 THEN 'DEMURRAGE' -- 8
			 ELSE 'VENDOR PAY' END AS TransType, -- 1
		CASE WHEN ICB_AP = 1 AND RecordType = 'VND' AND IsDemurrage = 0 THEN 4
			 WHEN ICB_AR = 1 AND RecordType <> 'VND' AND IsDemurrage = 0 THEN 4
			 WHEN ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P' AND PierPassType = 0 AND IsDemurrage = 0 THEN 3
			 WHEN PrePayType = 'A' AND IsDemurrage = 0 THEN 7
			 WHEN PierPassType = 1 AND IsDemurrage = 0 THEN 5
			 WHEN VndIntercompany = 1 AND IsDemurrage = 0 THEN 2
			 WHEN PerDiemType = 1 AND IsDemurrage = 0 THEN 6
			 WHEN IsDemurrage = 1 THEN 8
			 ELSE 1 END AS TransTypeId,
		CASE WHEN VndIntercompany = 1 OR ICB_AP = 1 THEN 'TIP'
			 WHEN (ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P') OR PierPassType = 1 OR PerDiemType = 1 OR PrePayType = 'A' OR IsDemurrage = 1 THEN 'FSIG'
			 ELSE 'FSIP' END AS IntegrationType,
		IsDemurrage,
		Equipment,
		FSI_ReceivedSubDetailId AS RecordId
FROM	(
		SELECT	FH.Company,
				FH.BatchId,
				WeekEndDate, 
				InvoiceNumber,
				InvoiceDate,
				CustomerNumber, 
				BillToRef, 
				InvoiceType, 
				Division, 
				ISNULL(RecordType, 'NONE') AS RecordType, 
				ISNULL(RecordCode, 'NONE') AS RecordCode,
				ChargeAmount1 AS Amount, 
				FS.VndIntercompany,
				CASE WHEN DEM.VarC IS NOT Null THEN CAST(COM.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE 
				CASE WHEN FD.InvoiceType IN ('C','D') AND FS.VendorReference IS NOT Null AND FS.VendorReference <> '' THEN FS.VendorReference
					 WHEN FD.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber ELSE
						RTRIM(LEFT(CASE WHEN VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FD.Equipment) THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
						WHEN Equipment IS NOT Null AND Equipment <> '' THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1)
						WHEN (LEN(RTRIM(ISNULL(FD.Equipment,''))) = 10 OR ISNULL(FD.Equipment,'') = 'FLATBED') AND ISNULL(FD.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FD.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
						ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
					END, 20)) END END AS VendorDocument,
				VendorReference,
				FD.Equipment,
				RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
				FS.PrePay,
				IIF(FS.PrePayType IN ('A','P'), FS.PrePayType, Null) AS PrePayType,
				ISNULL(IIF(FD.PrePayType IN ('A','P'), FD.PrePayType, Null),'') AS AR_PrePayType,
				FS.AccCode,
				FSI_ReceivedSubDetailId,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = FH.Company AND AR.Account = FD.CustomerNumber AND AR.RecordType = 'C'), 1, 0) AS ICB_AR,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = FH.Company AND AR.Account = FS.RecordCode AND AR.RecordType = 'V'), 1, 0) AS ICB_AP,
				CAST(CASE WHEN FS.RecordType IN ('ACC','VND') AND FS.AccCode = PAR.VarC AND VND.VendorId IS Null THEN 1 ELSE 0 END AS Bit) AS PerDiemType,
				PierPassType = CAST(IIF(VND.VendorId IS Null, 0, 1) AS Bit),
				IIF(DEM.VarC IS Null, 0, 1) AS IsDemurrage
		FROM    FSI_ReceivedDetails FD
				INNER JOIN FSI_ReceivedHeader FH ON FD.BatchID = FH.BatchId
				INNER JOIN FSI_ReceivedSubDetails FS ON FD.BatchID = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'VND'
				INNER JOIN PRISQL01P.GPCustom.dbo.Companies COM ON FH.Company = COM.CompanyId
				INNER JOIN PRISQL01P.GPCustom.dbo.Parameters PAR ON PAR.Company = 'ALL' AND PAR.ParameterCode = 'PRD_ACCESSORAILCODE'
				--LEFT JOIN PRISQL01P.GPCustom.dbo.CustomerMaster CMA ON FH.Company = CMA.CompanyId AND FD.CustomerNumber = CMA.CustNmbr
				LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters DEM ON DEM.Company = FH.Company AND DEM.ParameterCode = 'DEMURRAGE_ACCCODE' AND FS.AccCode = DEM.VarC --AND CMA.WithDemurrage = 1
				LEFT JOIN PRISQL01P.GPCustom.dbo.GPVendorMaster VND ON FH.Company = VND.Company AND FS.RecordCode = VND.VendorId AND VND.PierPassType = 1
		) DT
		
GO

USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Integration_FSI_Sales]    Script Date: 9/8/2021 10:31:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE	USP_Integration_FSI_Sales 'IMC', '1FSI20210712_0943_SUM', 1
EXECUTE	USP_Integration_FSI_Sales 'GLSO', '9FSI20210818_1637', 1
EXECUTE	USP_Integration_FSI_Sales 'GLSO', '9FSI20210826_1400', 1
*/
ALTER PROCEDURE [dbo].[USP_Integration_FSI_Sales]
	@Company	Varchar(5),
	@BatchId	Varchar(25),
	@Status		Smallint = 0
AS
DECLARE	@Intercompany	Bit,
		@DemmurageAcc	Varchar(5)
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

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		'DEM'
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

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

	DECLARE @tblFSISubDetails	Table (DetailId Varchar(10), RecordType Varchar(5), RecordCode Varchar(20), AccCode Varchar(5), ChargeAmount1 Numeric(10,2), DemurrageAdminFee Numeric(10,2), Invoice Varchar(20))

	DECLARE	@WithPrePay			Bit = 0,
			@WithVendorPay		Bit = 0,
			@WithIntercompany	Bit = 0
	
	SET @WithPrePay			= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM View_Integration_FSI_Full WHERE BatchId = @BatchId AND RecordType = 'VND' AND PrePay = 1) THEN 1 ELSE 0 END) AS Bit)
	SET @WithVendorPay		= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM View_Integration_FSI_Full WHERE BatchId = @BatchId AND RecordType = 'VND' AND PrePay = 0) THEN 1 ELSE 0 END) AS Bit)
	SET @WithIntercompany	= CAST((CASE WHEN EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedDetails WHERE BatchId = @BatchId AND Intercompany = 1) OR EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND VndIntercompany = 1) THEN 1 ELSE 0 END) AS Bit)

	INSERT INTO @tblFSISubDetails
	SELECT	SUB.DetailId, SUB.RecordType, SUB.RecordCode, SUB.AccCode, SUB.ChargeAmount1, SUB.DemurrageAdminFee, DET.InvoiceNumber
	FROM	FSI_ReceivedSubDetails SUB
			INNER JOIN FSI_ReceivedDetails DET ON SUB.BatchId = DET.BatchId AND SUB.DetailId = DET.DetailId
	WHERE	SUB.BatchId = @BatchId
			AND SUB.VndIntercompany = 0
			AND SUB.ICB = 0
			--AND PrePayType IS Null

	SELECT	DATA.*
			,DebitAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal = DemurrageARAmnt, IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'), IIF(InvoiceTotal < 0, 'FSISALESCREACCT', 'FSISALESDEBACCT')))
			,CreditAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND InvoiceTotal = DemurrageARAmnt, IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_DEBIT', 'DEMURRAGE_AR_CREDIT'), IIF(InvoiceTotal < 0, 'FSISALESDEBACCT', 'FSISALESCREACCT')))
			,DemurrageAdminFeeAmount = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND DemurrageAPAmnt = 0 AND ComponentBill = 0, 0, DemurrageAdmFee)
			,DemurrageAdminFeeAcct = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_ADMINFEEACT')
			,DemurrageGLAccount = (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceTotal > 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'))
			,NonDemurrageAmount = IIF(IsDemurrage = 1 AND DemurrageARAmnt <> 0 AND DemurrageAPAmnt <> 0 AND InvoiceTotal <> DemurrageARAmnt, InvoiceTotal - DemurrageARAmnt, InvoiceTotal)
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
					,IsDemurrage = IIF(EXISTS(SELECT TOP 1 BatchId FROM @tblFSISubDetails FS WHERE VFSI.DetailId = FS.DetailId AND FS.RecordType = 'ACC' AND FS.RecordCode = @DemmurageAcc), 1, 0) -- AND DET.AccCode IS NOT Null --AND VFSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
					,DemurrageAdmFee = ISNULL((SELECT SUM(DemurrageAdminFee) FROM @tblFSISubDetails F2 WHERE VFSI.DetailId = F2.DetailId AND F2.RecordType = 'ACC' AND F2.RecordCode = @DemmurageAcc), 0)
					,DemurrageARAmnt = ISNULL((SELECT SUM(ChargeAmount1) FROM @tblFSISubDetails FS WHERE FS.DetailId = VFSI.DetailId AND FS.RecordType = 'ACC' AND FS.RecordCode = @DemmurageAcc),0)
					,DemurrageAPAmnt = ISNULL((SELECT SUM(ChargeAmount1) FROM @tblFSISubDetails F3 WHERE VFSI.InvoiceNumber LIKE CASE WHEN dbo.IsSplitBill(VFSI.InvoiceNumber) = 1 THEN (F3.Invoice + '%') ELSE F3.Invoice END AND F3.RecordType = 'VND' AND F3.AccCode = @DemmurageAcc),0)
			FROM	View_Integration_FSI VFSI
					LEFT JOIN @tblSubDetails DET ON VFSI.DetailId = DET.DetailId
			WHERE	VFSI.BatchId = @BatchId
					AND VFSI.Intercompany = 0
					AND VFSI.InvoiceTotal <> 0
					AND VFSI.ICB = 0
					AND (VFSI.PrePayType IS Null OR VFSI.PrePayType <> 'A')
					AND ((VFSI.DetailProcessed = @Status AND @Status <> 10)
					OR (VFSI.InvoiceType = 'C' AND @Status = 10))
			) DATA
	ORDER BY InvoiceNumber

	SELECT	*,
			WithDemurrage = CAST(IIF((SELECT COUNT(*) FROM #tmpFsiSalesData WHERE IsDemurrage = 1 AND NonDemurrageAmount <> InvoiceTotal) > 0, 1, 0) AS Bit),
			WithAdminFee = CAST(IIF((SELECT SUM(DemurrageAdminFeeAmount) FROM #tmpFsiSalesData) > 0, 1, 0) AS Bit)
	FROM	#tmpFsiSalesData
	ORDER BY InvoiceNumber

	DROP TABLE #tmpFsiSalesData
END
GO

USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_GLIntegration_Records]    Script Date: 9/8/2021 10:33:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_GLIntegration_Records 'GLSO', '9FSI20210708_1547', 0
*/
ALTER PROCEDURE [dbo].[USP_FSI_GLIntegration_Records]
		@Company		Varchar(5), 
		@BatchId		Varchar(25),
		@Status			Smallint = 0
AS
SET NOCOUNT ON

DECLARE @CompanyNumber	Smallint
DECLARE @Demurrage		Varchar(10) = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')
DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = @Company)

INSERT INTO @tblVendors
SELECT	Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		'DEM'
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

SELECT	FSI.Company,
		FSI.BatchId,
		FSI.WeekEndDate,
		FSI.InvoiceNumber,
		FSI.InvoiceDate,
		FSI.Equipment,
		FSI.Division,
		FSI.FSI_ReceivedSubDetailId,
		FSI.PrePay,
		FSI.PrePayType,
		FSI.AR_PrePayType,
		FSI.PierPassType,
		FSI.ChargeAmount1,
		FSI.VendorDocument,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber + '|' + FSI.Equipment
			 WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber
			 ELSE FSI.PrepayReference END AS PrepayReference,
		FSI.RecordCode,
		FSI.AccCode,
		FSI.DetailId,
		FSI.ReceivedOn,
		FSI.PerDiemType,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AP_CREDIT', 'DEMURRAGE_AP_DEBIT'))
			 --WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORPREPAYDEBACCT', 'FSIVENDORDEBACCT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.AR_PrePayType = 'A', 'FSIACCRUDDEBIT','FSIACCRUDCREDIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'PIERPASS_ACCT_DEBIT')
			 WHEN FSI.PerDiemType = 1 THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_CREDITACCOUNT', 'PRD_DEBITACCOUNT'))
		ELSE 'Not Mapped' END AS DebitAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AP_DEBIT', 'DEMURRAGE_AP_CREDIT'))
			 --WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AR_DEBIT', 'DEMURRAGE_AR_CREDIT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORDEBACCT', 'FSIVENDORPREPAYDEBACCT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.AR_PrePayType = 'A', 'FSIACCRUDCREDIT','FSIACCRUDDEBIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'PIERPASS_ACCT_CREDIT')
			 WHEN FSI.PerDiemType = 1 THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_DEBITACCOUNT', 'PRD_CREDITACCOUNT'))
		ELSE 'Not Mapped' END AS CreditAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN 'DEMURRAGE'
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN 'PREPAY'
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN 'ACCRUAL'
			 WHEN FSI.AccCode <> @Demurrage AND FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN 'PIERPASS'
			 WHEN FSI.PerDiemType = 1 THEN 'PERDIEM'
		ELSE 'Unknow' END AS TransactionType,
		CASE WHEN RecordType = 'VND' THEN 'AP' ELSE 'AR' END AS SourceType
FROM	View_Integration_FSI_Full FSI
		LEFT JOIN @tblVendors VND ON FSI.Company = VND.Company AND FSI.RecordCode = VND.VendorCode AND VND.VndType = 'PP'
WHERE	FSI.BatchId = @BatchId 
		AND FSI.VndIntercompany = 0
		AND (((FSI.RecordType = 'VND' 
			AND ((FSI.PrePay = 1 AND ISNULL(FSI.PrePayType, '') IN ('','P')))
			OR FSI.PrePayType = 'A' 
			OR FSI.PerDiemType = 1 
			OR FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors)
			OR FSI.AccCode = @Demurrage)
			AND FSI.SubProcessed = @Status)
			OR ((ISNULL(FSI.AR_PrePayType, 'N') = 'A' 
			OR (FSI.RecordType = 'ACC' AND FSI.PerDiemType = 1)
			AND FSI.Processed = @Status)))
			AND NOT (FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage)
GO

USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_GLIntegration_Records]    Script Date: 9/8/2021 10:33:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_GLIntegration_Records_GLSO 'GLSO', '9FSI20210708_1547', 0
*/
ALTER PROCEDURE [dbo].[USP_FSI_GLIntegration_Records_GLSO]
		@Company		Varchar(5), 
		@BatchId		Varchar(25),
		@Status			Smallint = 0
AS
SET NOCOUNT ON

DECLARE @CompanyNumber	Smallint
DECLARE @Demurrage		Varchar(10) = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')
DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = @Company)

INSERT INTO @tblVendors
SELECT	Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		'DEM'
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

SELECT	FSI.Company,
		FSI.BatchId,
		FSI.WeekEndDate,
		FSI.InvoiceNumber,
		FSI.InvoiceDate,
		FSI.Equipment,
		FSI.Division,
		FSI.FSI_ReceivedSubDetailId,
		FSI.PrePay,
		FSI.PrePayType,
		FSI.AR_PrePayType,
		FSI.PierPassType,
		FSI.ChargeAmount1,
		FSI.VendorDocument,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber + '|' + FSI.Equipment
			 WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber
			 ELSE FSI.PrepayReference END AS PrepayReference,
		FSI.RecordCode,
		FSI.AccCode,
		FSI.DetailId,
		FSI.ReceivedOn,
		FSI.PerDiemType,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AP_CREDIT', 'DEMURRAGE_AP_DEBIT'))
			 --WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORPREPAYDEBACCT', 'FSIVENDORDEBACCT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.AR_PrePayType = 'A', 'FSIACCRUDDEBIT','FSIACCRUDCREDIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'PIERPASS_ACCT_DEBIT')
			 WHEN FSI.PerDiemType = 1 THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_CREDITACCOUNT', 'PRD_DEBITACCOUNT'))
		ELSE 'Not Mapped' END AS DebitAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AP_DEBIT', 'DEMURRAGE_AP_CREDIT'))
			 --WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'DEMURRAGE_AR_DEBIT', 'DEMURRAGE_AR_CREDIT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORDEBACCT', 'FSIVENDORPREPAYDEBACCT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = IIF(FSI.AR_PrePayType = 'A', 'FSIACCRUDCREDIT','FSIACCRUDDEBIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'PIERPASS_ACCT_CREDIT')
			 WHEN FSI.PerDiemType = 1 THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_DEBITACCOUNT', 'PRD_CREDITACCOUNT'))
		ELSE 'Not Mapped' END AS CreditAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN 'DEMURRAGE'
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN 'PREPAY'
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN 'ACCRUAL'
			 WHEN FSI.AccCode <> @Demurrage AND FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN 'PIERPASS'
			 WHEN FSI.PerDiemType = 1 THEN 'PERDIEM'
		ELSE 'Unknow' END AS TransactionType,
		CASE WHEN RecordType = 'VND' THEN 'AP' ELSE 'AR' END AS SourceType
FROM	View_Integration_FSI_Full FSI
		LEFT JOIN @tblVendors VND ON FSI.Company = VND.Company AND FSI.RecordCode = VND.VendorCode AND VND.VndType = 'PP'
WHERE	FSI.BatchId = @BatchId 
		AND FSI.VndIntercompany = 0
		AND (((FSI.RecordType = 'VND' 
			AND ((FSI.PrePay = 1 AND ISNULL(FSI.PrePayType, '') IN ('','P')))
			OR FSI.PrePayType = 'A' 
			OR FSI.PerDiemType = 1 
			OR FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors)
			OR FSI.AccCode = @Demurrage)
			AND FSI.SubProcessed = @Status)
			OR ((ISNULL(FSI.AR_PrePayType, 'N') = 'A' 
			OR (FSI.RecordType = 'ACC' AND FSI.PerDiemType = 1)
			AND FSI.Processed = @Status)))
			AND NOT (FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage)
GO

USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_APIntegration_Select]    Script Date: 9/8/2021 10:35:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_APIntegration_Select 'GLSO', '9FSI20210723_1149', 0
*/
ALTER PROCEDURE [dbo].[USP_FSI_APIntegration_Select]
		@Company	Varchar(5),
		@BatchId	Varchar(25),
		@Status		Smallint = 0
AS
DECLARE @CompanyNumber	Smallint
DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE @tblDocuments	Table (VndDoc Varchar(50), DocumentCounter Int)
DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))
DECLARE	@tblParameters	Table (ParameterCode Varchar(50), VarC Varchar(100))

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = @Company)

INSERT INTO @tblVendors
SELECT	Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblDocuments
SELECT	VendorDocument,
		COUNT(*)
FROM	View_Integration_FSI_Vendors
WHERE	Company = @Company
		AND BatchId =  @BatchId
GROUP BY VendorDocument

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		'DEM'
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

INSERT INTO @tblParameters
SELECT	ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN ('FSIVENDORDEBACCT','FSIVENDORCREACCT')
		AND Company = @Company

SELECT	DISTINCT *
FROM	(
SELECT	DISTINCT FSI.*,
		CASE WHEN LEN(VendorDocument) > 19 THEN LEFT(VendorDocument, 16) + '_' + RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 3) 
			 WHEN LEN(VendorDocument) <= 20 AND FSU.DocumentCounter > 1 THEN RTRIM(LEFT(VendorDocument, 16)) + '_' + RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 3)
			 ELSE VendorDocument END AS APDocument,
		CAST(ISNULL(PAR.ParBit, 0) AS Bit) AS FSIAP_Hold,
		FSU.DocumentCounter,
		DebitAccount = (SELECT VarC FROM @tblParameters WHERE ParameterCode = IIF(FSI.ChargeAmount1 > 0, 'FSIVENDORDEBACCT','FSIVENDORCREACCT')),
		CreditAccount = (SELECT VarC FROM @tblParameters WHERE ParameterCode = IIF(FSI.ChargeAmount1 > 0, 'FSIVENDORCREACCT','FSIVENDORDEBACCT'))
FROM	View_Integration_FSI_Vendors FSI
		INNER JOIN @tblDocuments FSU ON FSI.VendorDocument = FSU.VndDoc
		LEFT JOIN PRISQL01P.GPCustom.dbo.Companies_Parameters PAR ON FSI.Company = PAR.CompanyId AND PAR.ParameterCode = 'FSI_AP_Hold'
		LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PA2 ON PA2.Company = FSI.Company AND PA2.ParameterCode = 'DEMURRAGE_ACCCODE' AND FSI.AccCode = PA2.VarC
WHERE	FSI.Company = @Company
		AND BatchId =  @BatchId
		AND VndIntercompany = 0 
		AND RecordCode NOT IN (SELECT VendorCode FROM @tblVendors)
		AND Processed = @Status
		AND NOT (FSI.AccCode = PA2.VarC)
		--AND ((@Status = 0 
		--	AND FSI_ReceivedSubDetailId NOT IN (SELECT RecordId FROM FSI_PayablesRecords)
		--	AND Processed = @Status)
		--	OR @Status = 1)
		) DAT
ORDER BY APDocument
GO

USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_APIntegration_Select]    Script Date: 9/8/2021 10:35:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_APIntegration_Select_GLSO 'GLSO', '9FSI20210723_1149', 0
*/
ALTER PROCEDURE [dbo].[USP_FSI_APIntegration_Select_GLSO]
		@Company	Varchar(5),
		@BatchId	Varchar(25),
		@Status		Smallint = 0
AS
DECLARE @CompanyNumber	Smallint
DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE @tblDocuments	Table (VndDoc Varchar(50), DocumentCounter Int)
DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))
DECLARE	@tblParameters	Table (ParameterCode Varchar(50), VarC Varchar(100))

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = @Company)

INSERT INTO @tblVendors
SELECT	Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblDocuments
SELECT	VendorDocument,
		COUNT(*)
FROM	View_Integration_FSI_Vendors
WHERE	Company = @Company
		AND BatchId =  @BatchId
GROUP BY VendorDocument

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		'DEM'
FROM	PRISQL01P.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

INSERT INTO @tblParameters
SELECT	ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN ('FSIVENDORDEBACCT','FSIVENDORCREACCT')
		AND Company = @Company

SELECT	DISTINCT *
FROM	(
SELECT	DISTINCT FSI.*,
		CASE WHEN LEN(VendorDocument) > 19 THEN LEFT(VendorDocument, 16) + '_' + RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 3) 
			 WHEN LEN(VendorDocument) <= 20 AND FSU.DocumentCounter > 1 THEN RTRIM(LEFT(VendorDocument, 16)) + '_' + RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 3)
			 ELSE VendorDocument END AS APDocument,
		CAST(ISNULL(PAR.ParBit, 0) AS Bit) AS FSIAP_Hold,
		FSU.DocumentCounter,
		DebitAccount = (SELECT VarC FROM @tblParameters WHERE ParameterCode = IIF(FSI.ChargeAmount1 > 0, 'FSIVENDORDEBACCT','FSIVENDORCREACCT')),
		CreditAccount = (SELECT VarC FROM @tblParameters WHERE ParameterCode = IIF(FSI.ChargeAmount1 > 0, 'FSIVENDORCREACCT','FSIVENDORDEBACCT'))
FROM	View_Integration_FSI_Vendors FSI
		INNER JOIN @tblDocuments FSU ON FSI.VendorDocument = FSU.VndDoc
		LEFT JOIN PRISQL01P.GPCustom.dbo.Companies_Parameters PAR ON FSI.Company = PAR.CompanyId AND PAR.ParameterCode = 'FSI_AP_Hold'
		LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PA2 ON PA2.Company = FSI.Company AND PA2.ParameterCode = 'DEMURRAGE_ACCCODE' AND FSI.AccCode = PA2.VarC
WHERE	FSI.Company = @Company
		AND BatchId =  @BatchId
		AND VndIntercompany = 0 
		AND RecordCode NOT IN (SELECT VendorCode FROM @tblVendors)
		AND Processed = @Status
		AND NOT (FSI.AccCode = PA2.VarC)
		--AND ((@Status = 0 
		--	AND FSI_ReceivedSubDetailId NOT IN (SELECT RecordId FROM FSI_PayablesRecords)
		--	AND Processed = @Status)
		--	OR @Status = 1)
		) DAT
ORDER BY APDocument
GO


