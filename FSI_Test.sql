USE [GPCustom]
GO
/****** Object:  View [dbo].[View_Integration_FSI_Vendors]    Script Date: 05/14/2008 16:46:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[View_Integration_FSI_Vendors]
AS
SELECT	FSI_ReceivedHeaderId, 
		Company, 
		FS.BatchId,
		WeekEndDate, 
		ReceivedOn, 
		TotalTransactions, 
		TotalSales, 
		TotalVendorAccrual, 
		TotalTruckAccrual,
		FSI_ReceivedSubDetailId, 
		FS.DetailId,
		FD.VoucherNumber,
		InvoiceNumber,
		CustomerNumber,
		BillToRef,
		RecordType, 
		RecordCode, 
		Reference, 
		ChargeAmount1, 
		ChargeAmount2, 
		ReferenceCode, 
		FS.Verification,
		FS.Processed
FROM    FSI_ReceivedSubDetails FS
		INNER JOIN FSI_ReceivedDetails FD ON FS.BatchID = FD.BatchId AND FS.DetailId = FD.DetailId
		INNER JOIN FSI_ReceivedHeader FH ON FS.BatchID = FH.BatchId
		LEFT JOIN (SELECT BatchId, DetailId, MAX(RecordCode) AS RecordCode FROM FSI_ReceivedSubDetails WHERE RecordType = 'EQP' GROUP BY BatchId, DetailId)
WHERE	FS.RecordType = 'VND'



