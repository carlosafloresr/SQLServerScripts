USE [CollectIT]
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerStatementDetailsByNumber]    Script Date: 12/19/2016 4:34:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[GetCustomerStatementDetailsByNumber]    Script Date: 07/06/2013 04:13:39 p.m. ******/
--SET ANSI_NULLS ON
----GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================
-- Author:		<Author : Yobannys>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- execute GetCustomerStatementDetailsByNumber 22575
ALTER PROCEDURE [dbo].[GetCustomerStatementDetailsByNumber] 
	@CustomerId INT
AS
BEGIN

	DECLARE @Cur INT
	DECLARE @CurSymbol NVARCHAR(max)

	SET @Cur = (
			SELECT DefaultCurrencyId
			FROM CS_Settings
			)

	SET @CurSymbol = (
			SELECT cur.Symbol
			FROM cs_currency cur
			WHERE cur.CurrencyId = @Cur
			)

	CREATE TABLE #TempDetailsQuery (
			DocNumber			VARCHAR(255)
			,[DocDate]			DATETIME
			,[DueDate]			DATETIME null
			,Code				NVARCHAR(max)
			--,[Description]	NVARCHAR(max)
			,Invoice			NVARCHAR(max)
			--,Payment			NVARCHAR(max)
			,InvoiceRemaining	NVARCHAR(max)
			,Balance			NVARCHAR(max)
			,EquipmentNo		NVARCHAR(15) null)

	DECLARE @InvId INT;
	DECLARE @InvNumber NVARCHAR(max);
	DECLARE @DocType NVARCHAR(max);
	DECLARE @TransDesc NVARCHAR(max);
	DECLARE @DocDate DATETIME;
	DECLARE @DueDate DATETIME;
	DECLARE @Amount MONEY;
	DECLARE @AmountRemaining MONEY;
	DECLARE @Balance MONEY;
	DECLARE @InvCur int;
	DECLARE @EquipmentNo NVARCHAR(15);

	SET @Balance = 0;

	DECLARE invoice_cursor CURSOR
	FOR
	SELECT	CS_Invoice.InvoiceId
			,InvoiceNum
			,DocDate
			,DueDate
			,dbo.ConvertCurrency(Amount, CurrencyId, @cur)
			,dbo.ConvertCurrency(TotalAmountDue, CurrencyId, @Cur)
			,'INV' AS DocumentType
			,EquipmentNo
			--,TransactionDescription
	FROM	CS_Invoice
			LEFT JOIN UF_Invoice ON UF_Invoice.InvoiceId = CS_Invoice.InvoiceId
	WHERE	CustomerId = @CustomerId
			AND PaymentStatus = 2
	ORDER BY DocDate

	OPEN invoice_cursor

	FETCH NEXT
	FROM invoice_cursor
	INTO @InvId
		,@InvNumber
		,@DocDate
		,@DueDate
		,@Amount
		,@AmountRemaining
		,@DocType
		,@EquipmentNo
		--,@TransDesc;

	WHILE (@@fetch_status <> - 1)
	BEGIN
		SET @Balance += @AmountRemaining ; --@Amount;

		PRINT @Balance;

		INSERT INTO #TempDetailsQuery (
			DocNumber
			,[DocDate]
			,[DueDate]
			,Code
			,Invoice
			,InvoiceRemaining
			,Balance
			,EquipmentNo
			)
		VALUES (
			@InvNumber
			,@DocDate
			,@DueDate
			,@DocType
			,@CurSymbol + convert(VARCHAR, @Amount, 1)
			,@CurSymbol + convert(VARCHAR, @AmountRemaining, 1) 
			,@CurSymbol + convert(VARCHAR, @Balance, 1)
			,@EquipmentNo
			)


		FETCH NEXT
		FROM invoice_cursor
		INTO @InvId
			,@InvNumber
			,@DocDate
			,@DueDate
			,@Amount
			,@AmountRemaining
			,@DocType
			,@EquipmentNo
	END

	CLOSE invoice_cursor

	DEALLOCATE invoice_cursor

	/*
	INACTIVATED TO EXCLUDE CREDITS ON 12/19/2016 - Carlos A. Flores
	*/
	--	DECLARE invoice_cursor CURSOR
	--FOR
	--SELECT PaymentId
	--	,TransactionNum
	--	,PayDate
	--	,null
	--	,dbo.ConvertCurrency(OriginalAmount, CurrencyId, @cur)
	--	,dbo.ConvertCurrency(RemainingAmount, CurrencyId, @Cur)
	--	,DocumentType
	--	--,TransactionDescription
	--from CS_Payment
	--WHERE CustomerId = @CustomerId
	--AND RemainingAmount <> 0
	--ORDER BY PayDate

	--OPEN invoice_cursor

	--FETCH NEXT
	--FROM invoice_cursor
	--INTO @InvId
	--	,@InvNumber
	--	,@DocDate
	--	,@DueDate
	--	,@Amount
	--	,@AmountRemaining
	--	,@DocType
	--	--,@TransDesc;

	--WHILE (@@fetch_status <> - 1)
	--BEGIN
	--	SET @Balance -= @AmountRemaining ; --@Amount;

	--INSERT INTO #TempDetailsQuery (
	--		DocNumber
	--		,[DocDate]
	--		,[DueDate]
	--		,Code
	--		,Invoice
	--		,InvoiceRemaining
	--		,Balance
	--		)
	--	select 
	--		@InvNumber
	--		,@DocDate
	--		, null
	--		,@DocType
	--		,@CurSymbol + convert(VARCHAR, @Amount, 1)
	--		,@CurSymbol + convert(VARCHAR, @AmountRemaining, 1) 
	--		,@CurSymbol + convert(VARCHAR, @Balance, 1)

	--				FETCH NEXT
	--	FROM invoice_cursor
	--	INTO @InvId
	--		,@InvNumber
	--		,@DocDate
	--		,@DueDate
	--		,@Amount
	--		,@AmountRemaining
	--		,@DocType
	--END

	--CLOSE invoice_cursor

	--DEALLOCATE invoice_cursor



	SELECT *
	FROM #TempDetailsQuery
	--ORDER BY DueDate

	DROP TABLE #TempDetailsQuery
END
