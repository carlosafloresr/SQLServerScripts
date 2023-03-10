USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceiptSearch]    Script Date: 07/31/2009 14:59:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_CashReceiptSearch]
		@Company	Varchar(5),
		@Chassis	Varchar(12) = Null,
		@WorkOrder	Varchar(20) = Null
AS
IF @Company = 'FI'
BEGIN
	IF @Chassis IS NOT Null AND @WorkOrder IS NOT Null
	BEGIN
		SELECT	DISTINCT 'I' + CAST(INV.Inv_No AS Varchar(10)) AS Inv_No, 
				INV.Inv_Date AS [Inv Date], 
				INV.Inv_Total AS Amount, 
				INV.Chassis, 
				INV.WorkOrder,
				ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustNmbr,
				ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount,
				ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
		FROM	ILSINT01.FI_Data.dbo.Invoices INV
				LEFT JOIN FI.dbo.RM20101 RM1 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM1.DocNumbr
				LEFT JOIN FI.dbo.RM30101 RM2 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM2.DocNumbr
		WHERE	INV.Chassis = @Chassis
				OR INV.WorkOrder = @WorkOrder
		ORDER BY INV.Inv_Date, 1
	END
	ELSE
	BEGIN
		IF @Chassis IS NOT Null
		BEGIN
			SELECT	DISTINCT 'I' + CAST(INV.Inv_No AS Varchar(10)) AS Inv_No, 
					INV.Inv_Date AS [Inv Date], 
					INV.Inv_Total AS Amount, 
					INV.Chassis, 
					INV.WorkOrder,
					ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustNmbr,
					ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount,
					ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
			FROM	ILSINT01.FI_Data.dbo.Invoices INV
					LEFT JOIN FI.dbo.RM20101 RM1 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM1.DocNumbr
					LEFT JOIN FI.dbo.RM30101 RM2 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM2.DocNumbr
			WHERE	INV.Chassis = @Chassis
			ORDER BY INV.Inv_Date, 1
		END
		ELSE
		BEGIN
			SELECT	DISTINCT 'I' + CAST(INV.Inv_No AS Varchar(10)) AS Inv_No, 
					INV.Inv_Date AS [Inv Date], 
					INV.Inv_Total AS Amount, 
					INV.Chassis, 
					INV.WorkOrder,
					ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustNmbr,
					ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount,
					ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
			FROM	ILSINT01.FI_Data.dbo.Invoices INV
					LEFT JOIN FI.dbo.RM20101 RM1 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM1.DocNumbr
					LEFT JOIN FI.dbo.RM30101 RM2 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM2.DocNumbr
			WHERE	INV.WorkOrder = @WorkOrder
			ORDER BY INV.Inv_Date, 1
		END
	END
END

IF @Company = 'RCMR'
BEGIN
	IF @Chassis IS NOT Null AND @WorkOrder IS NOT Null
	BEGIN
		SELECT	DISTINCT 'I' + CAST(INV.Inv_No AS Varchar(10)) AS Inv_No, 
				INV.Inv_Date AS [Inv Date], 
				INV.Inv_Total AS Amount, 
				INV.Chassis, 
				INV.WorkOrder,
				ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustNmbr,
				ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount,
				ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
		FROM	ILSINT01.RCMR_Data.dbo.Invoices INV
				LEFT JOIN RCMR.dbo.RM20101 RM1 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM1.DocNumbr
				LEFT JOIN RCMR.dbo.RM30101 RM2 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM2.DocNumbr
		WHERE	INV.Chassis = @Chassis
				OR INV.WorkOrder = @WorkOrder
		ORDER BY INV.Inv_Date, 1
	END
	ELSE
	BEGIN
		IF @Chassis IS NOT Null
		BEGIN
			SELECT	DISTINCT 'I' + CAST(INV.Inv_No AS Varchar(10)) AS Inv_No, 
					INV.Inv_Date AS [Inv Date], 
					INV.Inv_Total AS Amount, 
					INV.Chassis, 
					INV.WorkOrder,
					ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustNmbr,
					ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount,
					ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
			FROM	ILSINT01.RCMR_Data.dbo.Invoices INV
					LEFT JOIN RCMR.dbo.RM20101 RM1 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM1.DocNumbr
					LEFT JOIN RCMR.dbo.RM30101 RM2 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM2.DocNumbr
			WHERE	INV.Chassis = @Chassis
			ORDER BY INV.Inv_Date, 1
		END
		ELSE
		BEGIN
			SELECT	DISTINCT 'I' + CAST(INV.Inv_No AS Varchar(10)) AS Inv_No, 
					INV.Inv_Date AS [Inv Date], 
					INV.Inv_Total AS Amount, 
					INV.Chassis, 
					INV.WorkOrder,
					ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustNmbr,
					ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount,
					ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
			FROM	ILSINT01.RCMR_Data.dbo.Invoices INV
					LEFT JOIN RCMR.dbo.RM20101 RM1 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM1.DocNumbr
					LEFT JOIN RCMR.dbo.RM30101 RM2 ON 'I' + CAST(INV.Inv_No AS Varchar(10)) = RM2.DocNumbr
			WHERE	INV.WorkOrder = @WorkOrder
			ORDER BY INV.Inv_Date, 1
		END
	END
END