USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceivePayment]    Script Date: 07/31/2009 14:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_CashReceivePayment] (@Company Varchar(5), @PaymentNum Varchar(20))
AS
IF @Company = 'FI'
BEGIN
	SELECT	DocNumbr AS PaymentNum, 
			DocDate, 
			OrTrxAmt AS Amount, 
			CurTrxAm AS Balance 
	FROM	FI.dbo.RM20101 
	WHERE	DocNumbr = @PaymentNum
	UNION
	SELECT	DocNumbr, 
			DocDate, 
			OrTrxAmt AS Amount, 
			CurTrxAm AS Balance 
	FROM	FI.dbo.RM30101 
	WHERE	DocNumbr = @PaymentNum
END

IF @Company = 'RCMR'
BEGIN
	SELECT	DocNumbr AS PaymentNum, 
			DocDate, 
			OrTrxAmt AS Amount, 
			CurTrxAm AS Balance 
	FROM	RCMR.dbo.RM20101 
	WHERE	DocNumbr = @PaymentNum
	UNION
	SELECT	DocNumbr, 
			DocDate, 
			OrTrxAmt AS Amount, 
			CurTrxAm AS Balance 
	FROM	RCMR.dbo.RM30101 
	WHERE	DocNumbr = @PaymentNum
END