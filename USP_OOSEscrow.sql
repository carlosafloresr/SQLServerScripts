/*
EXECUTE USP_OOSEscrow
*/
ALTER PROCEDURE USP_OOSEscrow
AS
DECLARE	@BatchId	Varchar(20),
		@Rundate	Date = GETDATE(),
		@Company	Varchar(5) = DB_NAME(),
		@Records	Int = -1,
		@GPCount	Int = 0,
		@ESCount	Int = 0

SET @BatchId = (SELECT TOP 1 BachNumb FROM PM20000 WHERE BachNumb LIKE 'OOS' + @Company + '%' AND DocDate BETWEEN GPCustom.dbo.DayFwdBack(@Rundate,'P','Monday') AND GPCustom.dbo.DayFwdBack(@Rundate,'N','Sunday'))
PRINT @BatchId
IF @BatchId IS NOT Null
BEGIN
	-- Find the number of OOS transactions to submit to the escrow system
	SELECT	@ESCount = COUNT(TR.BatchId)
	FROM	GPCustom.dbo.View_OOS_Transactions TR WITH (NOLOCK)
			INNER JOIN GPCustom.dbo.EscrowAccounts EA WITH (NOLOCK) ON TR.CreditAccount = EA.AccountNumber AND EA.CompanyId = DB_NAME() AND EA.Fk_EscrowModuleId <> 10
	WHERE	TR.BatchId = @BatchId
			AND TR.Processed = 1
	
	PRINT 'In OOS Batch: ' + CAST(@ESCount AS Varchar)
	
	-- Check if the escrow transactions have been submitted to the escrow system
	SET @Records = ISNULL((SELECT COUNT(*) FROM GPCustom.dbo.EscrowTransactions WITH (NOLOCK) WHERE CompanyId = @Company AND BatchId = @BatchId AND DeletedBy IS Null), 0)
	
	PRINT 'In Escrow System: ' + CAST(@Records AS Varchar)
	
	PRINT 'Escrow Records: ' + CAST(@Records AS Varchar) + ' / OOS Records: ' + CAST(@ESCount AS Varchar)
	IF @Records < @ESCount
	BEGIN
		SELECT	DISTINCT *
		INTO	#tmpData
		FROM	(
				SELECT	DISTINCT 'AP' AS Source,
						COALESCE(P1.VchrNmbr, TR.Voucher) AS VchrNmbr,
						ISNULL(P2.DSTSQNUM, 16384) AS DSTSQNUM,
						TR.Company AS Company,
						EA.Fk_EscrowModuleId,
						TR.CreditAccount,
						ISNULL(P2.DISTTYPE,6) AS DISTTYPE,
						TR.VendorId,
						TR.DedAmount,
						TR.Description,
						P1.DOCDATE,
						P1.PSTGDATE,
						TR.BatchId,
						TR.Trans_CreatedBy AS EnteredBy,
						TR.Trans_CreatedOn AS EnteredOn,
						TR.Trans_CreatedBy,
						TR.Trans_CreatedOn
				FROM	GPCustom.dbo.View_OOS_Transactions TR WITH (NOLOCK)
						INNER JOIN GPCustom.dbo.EscrowAccounts EA WITH (NOLOCK) ON TR.CreditAccount = EA.AccountNumber AND EA.CompanyId = @Company AND EA.Fk_EscrowModuleId <> 10
						LEFT JOIN dbo.PM20000 P1 WITH (NOLOCK) ON (TR.Invoice = P1.DocNumbr OR TR.Invoice = P1.VCHRNMBR) AND TR.VendorId = P1.VendorId
						LEFT JOIN dbo.PM10100 P2 WITH (NOLOCK) ON P1.VchrNmbr = P2.VchrNmbr AND P1.TrxSorce = P2.TrxSorce AND TR.CrdAcctIndex = P2.DstIndx AND TR.CreditAmount = P2.CrdtAmnt
				WHERE	TR.BatchId = @BatchId
						AND P1.VchrNmbr IS NOT NULL
						AND TR.CrdAccounts = 1
						AND TR.Processed = 1
				UNION
				SELECT	DISTINCT 'AP' AS Source,
						COALESCE(P1.VchrNmbr, TR.Voucher) AS VchrNmbr,
						ISNULL(P2.DSTSQNUM, 16384),
						TR.Company AS Company,
						EA.Fk_EscrowModuleId,
						TR.CreditAccount,
						ISNULL(P2.DISTTYPE, 6),
						TR.VendorId,
						TR.DedAmount,
						TR.Description,
						P1.DOCDATE,
						P1.PSTGDATE,
						TR.BatchId,
						TR.Trans_CreatedBy,
						TR.Trans_CreatedOn,
						TR.Trans_CreatedBy,
						TR.Trans_CreatedOn
				FROM	GPCustom.dbo.View_OOS_Transactions TR WITH (NOLOCK)
						INNER JOIN GPCustom.dbo.EscrowAccounts EA WITH (NOLOCK) ON TR.CreditAccount = EA.AccountNumber AND EA.CompanyId = @Company AND EA.Fk_EscrowModuleId <> 10
						LEFT JOIN dbo.PM20000 P1 WITH (NOLOCK) ON (TR.Invoice = P1.DocNumbr OR TR.Invoice = P1.VCHRNMBR) AND TR.VendorId = P1.VendorId
						LEFT JOIN dbo.PM10100 P2 WITH (NOLOCK) ON P1.VchrNmbr = P2.VchrNmbr AND P1.TrxSorce = P2.TrxSorce AND TR.CrdAcctIndex2 = P2.DstIndx AND TR.CreditAmount2 = P2.CrdtAmnt
				WHERE	TR.BatchId = @BatchId
						AND P1.VchrNmbr IS NOT NULL
						AND TR.CrdAccounts = 2
						AND TR.Processed = 1
				UNION
				SELECT	DISTINCT 'AP' AS Source,
						COALESCE(P1.VchrNmbr, TR.Voucher) AS VchrNmbr,
						ISNULL(P2.DSTSQNUM, 16384),
						TR.Company AS Company,
						EA.Fk_EscrowModuleId,
						TR.CreditAccount,
						ISNULL(P2.DISTTYPE,6),
						TR.VendorId,
						TR.DedAmount,
						TR.Description,
						P1.DOCDATE,
						P1.PSTGDATE,
						TR.BatchId,
						TR.Trans_CreatedBy AS EnteredBy,
						TR.Trans_CreatedOn AS EnteredOn,
						TR.Trans_CreatedBy,
						TR.Trans_CreatedOn
				FROM	GPCustom.dbo.View_OOS_Transactions TR WITH (NOLOCK)
						INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TR.CreditAccount = EA.AccountNumber AND EA.CompanyId = @Company AND EA.Fk_EscrowModuleId <> 10
						LEFT JOIN dbo.PM30200 P1 WITH (NOLOCK) ON (TR.Invoice = P1.DocNumbr OR TR.Invoice = P1.VCHRNMBR) AND TR.VendorId = P1.VendorId
						LEFT JOIN dbo.PM30600 P2 WITH (NOLOCK) ON P1.VchrNmbr = P2.VchrNmbr AND P1.TrxSorce = P2.TrxSorce AND TR.CrdAcctIndex = P2.DstIndx AND TR.CreditAmount = P2.CrdtAmnt
				WHERE	TR.BatchId = @BatchId
						AND P1.VchrNmbr IS NOT NULL
						AND TR.CrdAccounts = 1
						AND TR.Processed = 1
				) DATA
		ORDER BY Vendorid
		
		-- Count the number of transaction now under the open transactions in Great Plains
		SET @GPCount = (SELECT COUNT(*) FROM #tmpData)

		PRINT 'In Great Plains: ' + CAST(@GPCount AS Varchar)

		-- If all the expected transactions are now under the open transaction in Great Plains we proceed to insert into the escrow system
		IF @GPCount > @Records
		BEGIN
			INSERT INTO GPCustom.dbo.EscrowTransactions
					   (Source
					   ,VoucherNumber
					   ,ItemNumber
					   ,CompanyId
					   ,Fk_EscrowModuleId
					   ,AccountNumber
					   ,AccountType
					   ,VendorId
					   ,Amount
					   ,Comments
					   ,TransactionDate
					   ,PostingDate
					   ,BatchId
					   ,EnteredBy
					   ,EnteredOn
					   ,ChangedBy
					   ,ChangedOn)
			SELECT	T1.*
			FROM	#tmpData T1
					LEFT JOIN GPCustom.dbo.EscrowTransactions T2 WITH (NOLOCK) ON T1.Company = T2.CompanyId AND T1.VchrNmbr = T2.VoucherNumber AND T1.CreditAccount = T2.AccountNumber AND T1.Vendorid = T2.VendorId AND T1.DedAmount = T2.Amount
			WHERE	T2.CompanyId IS NULL
			ORDER BY Vendorid, Description

			DROP TABLE #tmpData
		END

		-- We save the OOS batch information
		IF EXISTS(SELECT BatchId FROM GPCustom.dbo.OOS_BatchEscrow WHERE Company = @Company AND BatchId = @BatchId)
			UPDATE	GPCustom.dbo.OOS_BatchEscrow
			SET		Records = @ESCount
			WHERE	Company = @Company 
					AND BatchId = @BatchId
		ELSE
			INSERT INTO GPCustom.dbo.OOS_BatchEscrow 
					(Company, BatchId, Records) 
			VALUES 
					(@Company, @BatchId, @ESCount)
	END
END