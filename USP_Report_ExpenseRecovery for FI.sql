USE [FI]
GO
/****** Object:  StoredProcedure [dbo].[USP_Report_ExpenseRecovery]    Script Date: 10/14/2015 8:56:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Report_ExpenseRecovery 'FI', '5-29-2104', '1/04/2015', '10/03/2015', 1

SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'FI'
		AND AccountNumber = '5-29-2104'
		AND PostingDate BETWEEN '5/04/2014' AND '5/31/2014'
		AND DeletedBy IS Null
*/
ALTER PROCEDURE [dbo].[USP_Report_ExpenseRecovery]
		@CompanyId		Varchar(5), 
		@Account		Varchar(15),
		@DateIni		Date,
		@DateEnd		Date,
		@HideZeros		Bit = 1
AS
DECLARE	@ProType		Bit,
		@CompanyName	Varchar(75)

PRINT '1: ' + CONVERT(Varchar, GETDATE(), 109)
SELECT	@ProType = Trucking
FROM	GPCustom.dbo.Companies
WHERE	CompanyId = @CompanyId

SELECT	@CompanyName = RTRIM(LEFT(CmpnyNam, 50))
FROM	Dynamics.dbo.View_AllCompanies 
WHERE	InterID = @CompanyId

PRINT '2: ' + CONVERT(Varchar, GETDATE(), 109)
SELECT	CompanyId,
		AccountNumber,
		CASE WHEN @ProType = 0 THEN COALESCE(CASE WHEN ProNumber = '' THEN Null ELSE ProNumber END,SOPDocumentNumber,InvoiceNumber) ELSE ISNULL(SOPDocumentNumber,ProNumber) END AS ProNumber,
		SUM(CASE WHEN PostingDate < @DateIni THEN Amount ELSE 0 END) AS Balance,
		SUM(Amount) AS FinalBalance,
		0 AS EndBalance,
		SUM(CASE WHEN PostingDate BETWEEN @DateIni AND @DateEnd THEN 1 ELSE 0 END) AS PeriodSummary
INTO	#tmpBalances
FROM	GPCustom.dbo.View_EscrowTransactions
WHERE	CompanyId = @CompanyId
		AND AccountNumber = @Account
		AND Fk_EscrowModuleId = 5
		AND PostingDate <= @DateEnd
		AND PostingDate IS NOT Null
		AND DeletedBy IS Null
GROUP BY
		CompanyId,
		AccountNumber,
		CASE WHEN @ProType = 0 THEN COALESCE(CASE WHEN ProNumber = '' THEN Null ELSE ProNumber END,SOPDocumentNumber,InvoiceNumber) ELSE ISNULL(SOPDocumentNumber,ProNumber) END

PRINT '3: ' + CONVERT(Varchar, GETDATE(), 109)
SELECT	ES.EscrowTransactionId	
		,ES.Source
		,ES.VoucherNumber
		,ES.ItemNumber
		,ES.CompanyId
		,ES.Fk_EscrowModuleId
		,ES.AccountNumber
		,ES.AccountType
		,UPPER(ES.VendorId) AS VendorId
		,UPPER(ES.DriverId) AS DriverId
		,ES.Division
		,ES.Amount
		,ES.ClaimNumber
		,ES.DriverClass
		,ES.AccidentType
		,ES.Status
		,ES.DMSubmitted
		,ES.DeductionPlan
		,ES.Comments
		,ES.ProNumber
		,ES.TransactionDate
		,ES.PostingDate
		,ES.EnteredBy
		,ES.EnteredOn
		,ES.ChangedBy
		,ES.ChangedOn
		,ES.Void
		,ES.InvoiceNumber
		,ES.OtherStatus
		,ES.DeletedBy
		,ES.DeletedOn
		,ES.BatchId
		,ES.SOPDocumentNumber
		,ES.UnitNumber
		,ES.RepairDate
		,ES.ETA
		,ES.RecordType
		,ES.ChassisNumber
		,ES.TrailerNumber
		,BA.Balance
		,BA.FinalBalance AS EndBalance
		,BA.FinalBalance
		,BA.PeriodSummary
		,ROW_NUMBER() OVER (PARTITION BY BA.ProNumber ORDER BY BA.ProNumber) AS RowNumber	
INTO	#tmpEscrow1
FROM	GPCustom.dbo.View_EscrowTransactions ES
		INNER JOIN #tmpBalances BA ON ES.AccountNumber = BA.AccountNumber AND CASE WHEN ES.CompanyId = 'FI' THEN COALESCE(CASE WHEN ES.ProNumber = '' THEN Null ELSE ES.ProNumber END,ES.SOPDocumentNumber,ES.InvoiceNumber) ELSE ISNULL(ES.SOPDocumentNumber,ES.ProNumber) END = BA.ProNumber
WHERE	ES.CompanyId = @CompanyId
		AND ES.Fk_EscrowModuleId = 5
		AND ES.AccountNumber = @Account
		AND ES.PostingDate BETWEEN @DateIni AND @DateEnd
		AND BA.PeriodSummary <> 0

PRINT '4: ' + CONVERT(Varchar, GETDATE(), 109)
SELECT	ET.*
		,LEFT(COALESCE(ET.Comments, G0.Refrence, G1.Refrence, P0.DistRef, P3.DistRef, P1.TrxDscrn, P2.TrxDscrn, ' '), 500) AS TransDescription
		,@CompanyName AS CompanyName
		,LEFT(VendName, 50) AS VendName
		,UPPER(GL.ActDescr) AS ActDescr
		,ET.ProNumber AS ProNumberMain
		,LEFT(COALESCE(P1.DocNumbr, P2.DocNumbr, ET.InvoiceNumber, ' '), 20) AS DocNumber
		,ET.PostingDate AS PostDate
		,LEFT(EM.ModuleDescription, 50) AS Module
		,VEM.HireDate
		,VEM.TerminationDate
		,CASE WHEN VEM.SubType = 1 THEN 'CO' ELSE 'MYT' END AS DriverType
		,ET.RowNumber
FROM	#tmpEscrow1 ET
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
		INNER JOIN GPCustom.dbo.EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
		LEFT JOIN dbo.PM00200 VE ON ET.VendorId = VE.VendorId
		LEFT JOIN dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx
		LEFT JOIN GPCustom.dbo.VendorMaster VEM ON ET.CompanyId = VEM.Company AND ET.VendorId = VEM.VendorId
		LEFT JOIN dbo.PM10100 P0 ON ET.VoucherNumber = P0.Vchrnmbr AND ET.AccountType = P0.DistType AND ET.ItemNumber = P0.DstSqNum AND EA.AccountIndex = P0.DstIndx
		LEFT JOIN dbo.PM20000 P1 ON P0.Vchrnmbr = P1.Vchrnmbr AND (P0.VendorId = P1.VendorId OR ET.VendorId = P1.VendorId)
		LEFT JOIN dbo.PM30600 P3 ON ET.VoucherNumber = P3.Vchrnmbr AND ET.AccountType = P3.DistType AND ET.ItemNumber = P3.DstSqNum
		LEFT JOIN dbo.PM30200 P2 ON P3.Vchrnmbr = P2.Vchrnmbr AND (P3.VendorId = P2.VendorId OR ET.VendorId = P2.VendorId) AND P3.TrxSorce = P2.TrxSorce
		LEFT JOIN dbo.GL20000 G0 ON ET.VoucherNumber = CAST(G0.JrnEntry AS Varchar) AND G0.SourcDoc <> 'PMTRX' AND EA.AccountIndex = G0.ActIndx AND ET.ItemNumber = G0.SeqNumbr
		LEFT JOIN dbo.GL30000 G1 ON ET.VoucherNumber = CAST(G1.JrnEntry AS Varchar) AND G1.SourcDoc <> 'PMTRX' AND EA.AccountIndex = G1.ActIndx AND ET.ItemNumber = G1.SeqNumbr
WHERE	ET.PeriodSummary > 0
		AND ((@HideZeros = 1 AND ET.FinalBalance <> 0) 
		OR @HideZeros = 0)
UNION
SELECT	0 AS EscrowTransactionId
		,Null AS Source
		,Null AS VoucherNumber
		,Null AS ItemNumber
		,@CompanyId AS CompanyId
		,5 AS Fk_EscrowModuleId
		,BA.AccountNumber AS AccountNumber
		,Null AS AccountType
		,Null AS VendorId
		,Null AS DriverId
		,Null AS Division
		,Null AS Amount
		,Null AS ClaimNumber
		,Null AS DriverClass
		,Null AS AccidentType
		,Null AS Status
		,Null AS DMSubmitted
		,Null AS DeductionPlan
		,Null AS Comments
		,BA.ProNumber AS ProNumber
		,Null AS TransactionDate
		,Null AS PostingDate
		,Null AS EnteredBy
		,Null AS EnteredOn
		,Null AS ChangedBy
		,Null AS ChangedOn
		,Null AS Void
		,Null AS InvoiceNumber
		,Null AS OtherStatus
		,Null AS DeletedBy
		,Null AS DeletedOn
		,Null AS BatchId
		,Null AS SOPDocumentNumber
		,Null AS UnitNumber
		,Null AS RepairDate
		,Null AS ETA
		,Null AS RecordType
		,Null AS ChassisNumber
		,Null AS TrailerNumber
		,BA.Balance
		,(BA.FinalBalance + BA.Balance) AS EndBalance
		,BA.FinalBalance
		,BA.PeriodSummary
		,1 AS RowNumber
		,'' AS TransDescription
		,@CompanyName AS CompanyName
		,Null AS VendName
		,UPPER(GL.ActDescr) AS ActDescr
		,BA.ProNumber AS ProNumberMain
		,'' AS DocNumber
		,Null AS PostDate
		,'' AS Module
		,Null AS HireDate
		,Null AS TerminationDate
		,'NOT' AS DriverType
		,1 AS RowNumber
FROM	#tmpBalances BA
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON BA.AccountNumber = EA.AccountNumber AND BA.CompanyId = EA.CompanyId AND EA.Fk_EscrowModuleId = 5
		LEFT JOIN GL00100 GL ON EA.AccountIndex = GL.ActIndx
WHERE	BA.PeriodSummary = 0
		AND BA.FinalBalance <> 0
ORDER BY ET.ProNumber, ET.PostingDate

PRINT 'Done ' + CONVERT(Varchar, GETDATE(), 109)

DROP TABLE #tmpEscrow1
DROP TABLE #tmpBalances