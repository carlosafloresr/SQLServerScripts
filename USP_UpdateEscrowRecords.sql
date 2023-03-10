USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateEscrowRecords]    Script Date: 7/30/2015 1:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_UpdateEscrowRecords
*/
ALTER PROCEDURE [dbo].[USP_UpdateEscrowRecords]
AS
DECLARE	@CompanyId	Varchar(5),
		@TodayDate	Datetime,
		@Company	Varchar(5),
		@Query		Varchar(MAX)

SET		@TodayDate = CAST(CONVERT(Char(10), GETDATE(), 101) AS Datetime)

UPDATE	EscrowTransactions
SET		EscrowTransactions.InvoiceNumber	= RECS.DOCNUMBR,
		EscrowTransactions.Comments			= CASE WHEN EscrowTransactions.Comments IS Null THEN RECS.DISTREF ELSE EscrowTransactions.Comments END
FROM	(
		SELECT	ESC.EscrowTransactionId,
				DEX.DOCNUMBR,
				DEX.DISTREF,
				ESC.Comments
		FROM	EscrowTransactions ESC
				INNER JOIN ILSINT02.Integrations.dbo.Integrations_AP DEX ON ESC.VoucherNumber = DEX.VCHNUMWK AND ESC.CompanyId = DEX.Company AND ESC.AccountNumber = DEX.ACTNUMST AND DEX.Integration = 'DXP'
		WHERE	LEFT(ESC.BatchId, 3) = 'DEX'
				AND (ESC.InvoiceNumber IS Null
				OR (ESC.Comments IS Null AND ESC.Comments <> DEX.DISTREF))
		) RECS
WHERE	EscrowTransactions.EscrowTransactionId = RECS.EscrowTransactionId

UPDATE	ExpenseRecovery
SET		Division = LEFT(ProNumber, 2)
WHERE	Division IS Null
		AND ProNumber IS NOT Null
		
UPDATE	ExpenseRecovery
SET		StatusText = Status
WHERE	StatusText IS Null

UPDATE	ExpenseRecovery
SET		EffDate = CAST(InvDate AS Date)
WHERE	EffDate IS Null
		AND InvDate IS NOT Null
		AND Source = 'GL'
		AND ReceivedOn >= GETDATE() - 30

UPDATE	ExpenseRecovery 
SET		Closed = 1,
		Status = 'Closed',
		StatusText = 'Closed'
WHERE	((EffDate < GETDATE() - 45 AND ABS(Expense + Recovery) > 99.99 AND Closed = 0) --Status IN ('','Open','Pending')
		OR (EffDate < GETDATE() - 30 AND ABS(Expense + Recovery) < 100 AND Closed = 0)
		OR (Recovery < 0 AND Closed = 0))
		AND Reactivated = 0

EXECUTE USP_DeleteDuplicatedExpenseRecovery
EXECUTE USP_ExpenseRecovery_FixDriverInfo

DELETE	ILSINT02.Integrations.dbo.ReceivedIntegrations 
WHERE	Integration = 'VMA'

-- FIX ESCROW TRANSACTIONS
IF EXISTS(SELECT TOP 1 AccountNumber FROM EscrowTransactions WHERE PostingDate IS Null AND DeletedOn IS Null AND EnteredOn >= GETDATE() - 12) OR EXISTS(SELECT TOP 1 ExpenseRecoveryId FROM ExpenseRecovery WHERE EffDate IS Null)
BEGIN
	DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT CompanyId
	FROM	EscrowTransactions 
	WHERE	PostingDate IS Null 
			AND DeletedOn IS Null
			AND EnteredOn >= GETDATE() - 12

	OPEN Transaction_Companies 
	FETCH FROM Transaction_Companies INTO @Company

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Query = @Company + '.dbo.USP_UpdateEscrowTransactions'
		EXECUTE(@Query)

		FETCH FROM Transaction_Companies INTO @Company
	END

	CLOSE Transaction_Companies
	DEALLOCATE Transaction_Companies
END

-- FIX SALES OPEN BALANCES APPLY TO DATA
--DECLARE TruckingSalesCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
--SELECT	CompanyId
--FROM	Companies
--WHERE	Trucking = 1

--OPEN TruckingSalesCompanies 
--FETCH FROM TruckingSalesCompanies INTO @Company

--WHILE @@FETCH_STATUS = 0 
--BEGIN
--	EXECUTE USP_FixAROpenBalancesApplyTos @Company

--	FETCH FROM TruckingSalesCompanies INTO @Company
--END

--CLOSE TruckingSalesCompanies
--DEALLOCATE TruckingSalesCompanies

IF DATENAME(Weekday, GETDATE()) IN ('Tuesday','Wednesday','Thursday')
BEGIN
	DECLARE OOS_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	CompanyId
	FROM	Companies
	WHERE	Trucking = 1

	OPEN OOS_Companies 
	FETCH FROM OOS_Companies INTO @Company

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF EXISTS(SELECT TOP 1 Company FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company)
		BEGIN
			PRINT 'Checking company: ' + @Company
			SET @Query = @Company + '.dbo.USP_OOSEscrow'
			EXECUTE(@Query)
		END

		FETCH FROM OOS_Companies INTO @Company
	END

	CLOSE OOS_Companies
	DEALLOCATE OOS_Companies
END

EXECUTE USP_Fix_SOPEscrowRecords

-- ELIMINATE OOS DUPLICATE RECORDS
DELETE	EscrowTransactions
WHERE	EscrowTransactionId IN (
								SELECT	EscrowTransactionId
								FROM	(
										SELECT	VoucherNumber
												,MAX(EscrowTransactionId) AS EscrowTransactionId
										FROM	EscrowTransactions
										WHERE	VoucherNumber IN (	SELECT	VoucherNumber
																	FROM	(
																			SELECT	CompanyId
																					,Source
																					,VoucherNumber
																					,ItemNumber
																					,Fk_EscrowModuleId
																					,AccountNumber
																					,VendorId
																					,Amount
																					,COUNT(VoucherNumber) AS Counter
																			FROM	EscrowTransactions 
																			WHERE	TransactionDate > CAST(GETDATE() - 30 AS Date)
																			GROUP BY
																					CompanyId
																					,Source
																					,VoucherNumber
																					,ItemNumber
																					,Fk_EscrowModuleId
																					,AccountNumber
																					,VendorId
																					,Amount
																			HAVING	COUNT(VoucherNumber) > 1
																			) RECS
																	)
										GROUP BY VoucherNumber
										) RECS
								)

EXECUTE USP_FixExpenseRecoveryPostingDate
EXECUTE USP_FixExpenseRecoveryDocuments
EXECUTE USP_Fix_ExpenseRecovery_IntegrationAP