USE [FI]
GO
/****** Object:  StoredProcedure [dbo].[USP_MSR_FI_AR_Batch]    Script Date: 7/22/2014 12:08:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_MSR_FI_AR_Batch 'AR_FI_140717'
*/
ALTER PROCEDURE [dbo].[USP_MSR_FI_AR_Batch] (@BatchId Varchar(20))
AS
SELECT	BatchID
		,DocNumber
		,Description
		,DocDate
		,Customer
		,DocType
		,Amount
		,Account
		,Depot
		,Credit
		,Debit
		,VoucherNumber
		,LineItem
		,CASE	WHEN GP.CustNmbr IS Null THEN 'Customer does not exists in GP' 
				WHEN GP.Inactive = 1 THEN 'Customer is inactive in GP' 
				WHEN GP.Hold = 1 THEN 'Customer is on hold in GP' 
				ELSE ''
			END AS Verification
		,ISNULL(Processed,0) AS Processed
		,Container
		,Chassis
		,Intercompany
		,InvoiceLoaded
		,Type
		,Counter = (SELECT COUNT(DISTINCT AR2.DocNumber) FROM MSR.FI_AR AR2 WHERE AR2.BatchID = AR1.BatchID AND AR2.Customer = AR1.Customer AND AR2.DocDate = AR1.DocDate AND AR2.Amount = AR1.Amount)
		,CM.BatchBilling
INTO	#tmpData
FROM	MSR.FI_AR AR1
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CM ON CM.CompanyId = 'FI' AND AR1.Customer = CM.CustNmbr
		LEFT JOIN ILSGP01.FI.dbo.RM00101 GP ON AR1.Customer = GP.CustNmbr
WHERE	BatchID = @BatchId
		AND Intercompany = 0

SELECT	*
		,ROW_NUMBER() OVER (PARTITION BY BatchId ORDER BY Customer, DocDate, Amount) AS RowId
INTO	#tmpZero
FROM	(
		SELECT	DISTINCT BatchId, Customer, DocDate, Amount
		FROM	#tmpData
		WHERE	Counter > 1
				AND Description = 'B0'
				AND BatchBilling = 1
				AND Processed = 0
		) SUMDATA

SELECT	BatchID,
		--CASE WHEN Description = 'B0' THEN 'B' + REPLACE(BatchId, 'AR_FI_', '') + '_'  ELSE Description END AS DocNumber,
		CASE WHEN BatchBilling = 0 THEN DocNumber ELSE CASE WHEN Description = 'B0' THEN 'B' + REPLACE(BatchId, 'AR_FI_', '') + '_' +  dbo.PADL(RowId, 3, '0') ELSE Description END END AS DocNumber,
		DocDate,
		Customer,
		DocType,
		Amount,
		Account,
		Depot,
		Processed,
		Type,
		Verification,
		SUM(Credit) AS Credit,
		SUM(Debit) AS Debit
FROM	(
		SELECT	DAT1.*, RowId
		FROM	#tmpData DAT1
				LEFT JOIN #tmpZero DAT2 ON DAT1.BatchID = DAT2.BatchID AND DAT1.Customer = DAT2.Customer AND DAT1.DocDate = DAT2.DocDate AND DAT1.Amount = DAT2.Amount
		WHERE	Processed = 0
		) DATA
GROUP BY
		BatchID,
		CASE WHEN BatchBilling = 0 THEN DocNumber ELSE CASE WHEN Description = 'B0' THEN 'B' + REPLACE(BatchId, 'AR_FI_', '') + '_' +  dbo.PADL(RowId, 3, '0') ELSE Description END END,
		DocDate,
		Customer,
		DocType,
		Amount,
		Account,
		Depot,
		Processed,
		Type,
		Verification

DROP TABLE #tmpData
DROP TABLE #tmpZero