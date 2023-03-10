/*
EXECUTE USP_Report_ExpenseRecovery 'GSA', '0-00-2104', '04/03/2016', '04/30/2016', 1
EXECUTE USP_Report_ExpenseRecovery 'GSA', '0-00-2104', '01/01/2005', '08/18/2016', 1

SELECT	*
FROM	GPCustom.dbo.EscrowTransactions
WHERE	CompanyId = 'GSA'
		AND AccountNumber = '0-00-2104'
		AND ProNumber IS Null
		AND PostingDate BETWEEN '5/04/2014' AND '10/30/2015'
		AND DeletedBy IS Null
*/
USE [GSA]
GO

ALTER PROCEDURE [dbo].[USP_Report_ExpenseRecovery]
		@CompanyId		Varchar(5), 
		@Account		Varchar(15),
		@DateIni		Date,
		@DateEnd		Date,
		@HideZeros		Bit = 1
AS
SELECT	CompanyId,
		AccountNumber,
		PeriodSummary,
		ProNumber,
		SUM(Balance) AS Balance,
		SUM(Amount) AS FinalBalance,
		0 AS EndBalance
INTO	#tmpBalances
FROM	(
		SELECT	CompanyId,
				AccountNumber,
				UPPER(RTRIM(ProNumber)) AS ProNumber,
				CASE WHEN PostingDate < @DateIni THEN 0 ELSE 1 END AS PeriodSummary,
				CASE WHEN PostingDate < @DateIni THEN Amount ELSE 0 END AS Balance,
				Amount
		FROM	GPCustom.dbo.View_EscrowTransactions
		WHERE	CompanyId = @CompanyId
				AND AccountNumber = @Account
				AND Fk_EscrowModuleId = 5
				AND PostingDate <= @DateEnd
				AND PostingDate IS NOT Null
				AND DeletedBy IS Null
		) DATA
GROUP BY
		CompanyId,
		AccountNumber,
		ProNumber,
		PeriodSummary

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
		,UPPER(RTRIM(ES.ProNumber)) AS ProNumber
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
		,UPPER(RTRIM(ES.SOPDocumentNumber)) AS SOPDocumentNumber
		,ES.UnitNumber
		,ES.RepairDate
		,CAST(REPLACE(ES.ETA, '-', '/') AS Datetime) AS ETA
		,ES.RecordType
		,ES.ChassisNumber
		,ES.TrailerNumber
		,BA.Balance
		,BA.FinalBalance AS EndBalance
		,BA.FinalBalance
		,BA.PeriodSummary
INTO	#tmpEscrow1
FROM	GPCustom.dbo.View_EscrowTransactions ES
		INNER JOIN #tmpBalances BA ON ES.AccountNumber = BA.AccountNumber AND UPPER(RTRIM(ES.ProNumber)) = BA.ProNumber
WHERE	ES.CompanyId = @CompanyId
		AND ES.AccountNumber = @Account
		AND ES.Fk_EscrowModuleId = 5
		AND ES.PostingDate BETWEEN @DateIni AND @DateEnd
		AND ES.PostingDate IS NOT Null
		AND ES.DeletedBy IS Null
		AND BA.PeriodSummary = 1

SELECT	*
INTO	#tmpFinalReportData
FROM	(
		SELECT	ET.*
				,LEFT(COALESCE(ET.Comments, G0.Refrence, G1.Refrence, P0.DistRef, P3.DistRef, P1.TrxDscrn, P2.TrxDscrn, ' '), 500) AS TransDescription
				,LEFT(CO.CmpnyNam, 50) AS CompanyName
				,LEFT(VendName, 50) AS VendName
				,UPPER(GL.ActDescr) AS ActDescr
				,ET.ProNumber AS ProNumberMain
				,LEFT(COALESCE(P1.DocNumbr, P2.DocNumbr, ET.InvoiceNumber, ' '), 20) AS DocNumber
				,ET.PostingDate AS PostDate
				,LEFT(EM.ModuleDescription, 50) AS Module
				,VEM.HireDate
				,VEM.TerminationDate
				,CASE WHEN VEM.SubType = 1 THEN 'CO' ELSE 'MYT' END AS DriverType
				,ROW_NUMBER() OVER (PARTITION BY ProNumber ORDER BY ProNumber) AS RowNumber
		FROM	#tmpEscrow1 ET
				INNER JOIN GPCustom.dbo.EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
				INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
				INNER JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID
				LEFT JOIN dbo.PM00200 VE ON ET.VendorId = VE.VendorId
				LEFT JOIN dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx
				LEFT JOIN GPCustom.dbo.VendorMaster VEM ON ET.CompanyId = VEM.Company AND ET.VendorId = VEM.VendorId
				LEFT JOIN dbo.PM10100 P0 ON ET.VoucherNumber = P0.Vchrnmbr AND ET.AccountType = P0.DistType AND ET.ItemNumber = P0.DstSqNum AND EA.AccountIndex = P0.DstIndx
				LEFT JOIN dbo.PM20000 P1 ON P0.Vchrnmbr = P1.Vchrnmbr AND (P0.VendorId = P1.VendorId OR ET.VendorId = P1.VendorId)
				LEFT JOIN dbo.PM30600 P3 ON ET.VoucherNumber = P3.Vchrnmbr AND ET.AccountType = P3.DistType AND ET.ItemNumber = P3.DstSqNum
				LEFT JOIN dbo.PM30200 P2 ON P3.Vchrnmbr = P2.Vchrnmbr AND (P3.VendorId = P2.VendorId OR ET.VendorId = P2.VendorId) AND P3.TrxSorce = P2.TrxSorce
				LEFT JOIN dbo.GL20000 G0 ON ET.VoucherNumber = CAST(G0.JrnEntry AS Varchar(20)) AND G0.SourcDoc <> 'PMTRX' AND EA.AccountIndex = G0.ActIndx AND ET.ItemNumber = G0.SeqNumbr
				LEFT JOIN dbo.GL30000 G1 ON ET.VoucherNumber = CAST(G1.JrnEntry AS Varchar(20)) AND G1.SourcDoc <> 'PMTRX' AND EA.AccountIndex = G1.ActIndx AND ET.ItemNumber = G1.SeqNumbr
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
				,'' AS TransDescription
				,LEFT(CO.CmpnyNam, 50) AS CompanyName
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
				INNER JOIN Dynamics.dbo.View_AllCompanies CO ON BA.CompanyID = CO.InterID
				INNER JOIN GPCustom.dbo.EscrowAccounts EA ON BA.AccountNumber = EA.AccountNumber AND BA.CompanyId = EA.CompanyId AND EA.Fk_EscrowModuleId = 5
				LEFT JOIN dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx
		WHERE	BA.PeriodSummary = 0
				AND BA.FinalBalance <> 0
		) EscrowData
ORDER BY ProNumber, PostingDate

SELECT	DATA.*
		,AccountStartBalance = (SELECT SUM(CASE WHEN TMP.RowNumber = 1 THEN TMP.Balance ELSE 0 END) FROM #tmpFinalReportData TMP WHERE TMP.AccountNumber = DATA.AccountNumber)
		,AccountEndingBalance = (SELECT SUM(CASE WHEN TMP.RowNumber = 1 THEN TMP.FinalBalance ELSE 0 END) FROM #tmpFinalReportData TMP WHERE TMP.AccountNumber = DATA.AccountNumber)
		,ReportEndingBalance = (SELECT SUM(CASE WHEN TMP.RowNumber = 1 THEN TMP.FinalBalance ELSE 0 END) FROM #tmpFinalReportData TMP)
		,CASE	WHEN DATA.Status = 5 THEN RTRIM(DATA.OtherStatus)
				WHEN DATA.Status = 0 THEN 'DM to be Procs. ' + ISNULL(DATA.DeductionPlan, '')
				WHEN DATA.Status = 1 THEN 'Driver to be Procs. ' + ISNULL(DATA.DeductionPlan, '')
				WHEN DATA.Status = 2 THEN 'Waiting on Approval'
				WHEN DATA.Status = 3 THEN 'Researching'
				ELSE 'Waiting on Casing Receipt' END AS RecordStatus
FROM	#tmpFinalReportData DATA
ORDER BY
		DATA.AccountNumber,
		DATA.ProNumber, 
		DATA.PostingDate

DROP TABLE #tmpEscrow1
DROP TABLE #tmpBalances
DROP TABLE #tmpFinalReportData