/*
EXECUTE USP_MSRIntegration 'AR_FI_170111', 2, 1
EXECUTE USP_MSRIntegration 'AR_FI_170111', 2, 0
EXECUTE USP_MSRIntegration 'AR_FI_170111', Null, 0, 'MEMSCP'
*/
ALTER PROCEDURE USP_MSRIntegration
		@BatchId		varchar(20),
		@Status			int = Null,
		@JustDocList	bit = 0,
		@CustomerNo		varchar(20) = NULL,
		@Doc_Number		varchar(20) = NULL,
		@Doc_Date		date = NULL
AS		
DECLARE	@ImportDate					date,
		@inv_no						varchar(10),
		@inv_batch					varchar(10),
		@batch_total				numeric(18, 2),
		@batch_sale_tax				numeric(18, 2),
		@batch_labor				numeric(18, 2),
		@batch_parts				numeric(18, 2),
		@depot_loc					varchar(15),
		@MSR_ReceivedTransactions	int,
		@Company					char(6),
		@DocNumber					char(10),
		@Description				char(10),
		@DocDate					datetime,
		@Customer					char(10),
		@DocType					char(1),
		@Amount						money,
		@Account					char(12),
		@Credit						money,
		@Debit						money,
		@VoucherNumber				varchar(17),
		@LineItem					int,
		@Verification				varchar(50),
		@Processed					int,
		@Container					varchar(20),
		@Chassis					varchar(20),
		@Intercompany				bit,
		@InvoiceLoaded				bit,
		@RecordType					varchar(10),
		@RowNumber					int

SET		@ImportDate = CAST(SUBSTRING(@BatchId, 9, 2) + '/' + SUBSTRING(@BatchId, 11, 2) + '/20' + SUBSTRING(@BatchId, 7, 2) AS Date)

IF NOT EXISTS(SELECT TOP 1 import_date FROM staging.MSR_Import WHERE CAST(import_date AS Date) = @ImportDate)
	SET @CustomerNo = '-NONE-'

SELECT	MSR1.inv_no
		,MSR1.inv_batch
		,MSR1.inv_date
		,MSR1.acct_no
		,MSR1.inv_total
		,MSR1.inv_type
		,MSR1.inv_mech
		,MSR1.container
		,MSR1.chassis
		,MSR1.genset_no
		,MSR1.tir_no
		,MSR1.labor_hour
		,MSR1.parts
		,MSR1.consum
		,MSR1.labor
		,MSR1.sale_tax
		,MSR1.pur_price
		,MSR1.glarec
		,MSR1.storage
		,MSR1.inspec
		,MSR1.lifts
		,MSR1.depot_loc
		,MSR1.workorder
		,MSR1.job_order
		,MSR1.import_date
		,MSR2.batch_total
		,MSR2.batch_sale_tax
		,MSR2.batch_labor
		,MSR2.batch_parts
INTO	#tmpData
FROM	staging.MSR_Import MSR1
		LEFT JOIN (SELECT	inv_no,
							inv_batch,
							acct_no,
							depot_loc,
							SUM(inv_total) AS batch_total,
							SUM(sale_tax) AS batch_sale_tax,
							SUM(parts) AS batch_parts,
							SUM(labor) AS batch_labor
					FROM	staging.MSR_Import
					WHERE	CAST(import_date AS Date) = @ImportDate
					GROUP BY inv_no,
							inv_batch,
							acct_no,
							depot_loc
				  ) MSR2 ON MSR1.inv_batch = MSR2.inv_batch AND MSR1.inv_no = MSR2.inv_no AND MSR1.acct_no = MSR2.acct_no AND MSR1.depot_loc = MSR2.depot_loc
WHERE	CAST(MSR1.import_date AS Date) = @ImportDate
ORDER BY MSR1.inv_batch, MSR1.acct_no, MSR1.inv_no

SELECT	*,
		ROW_NUMBER() OVER(ORDER BY Description, DocNumber DESC) AS RowNumber
INTO	#tmpMSRData
FROM	(
		SELECT	DISTINCT MSR1.inv_no
				,MSR1.inv_batch
				,MSR1.batch_total
				,MSR1.batch_sale_tax
				,MSR1.batch_labor
				,MSR1.batch_parts
				,MSR0.MSR_ReceivedTransactions
				,MSR0.Company
				,MSR0.BatchId
				,MSR0.DocNumber
				,MSR0.Description
				,MSR0.DocDate
				,MSR0.Customer
				,MSR0.DocType
				,MSR0.Amount
				,MSR0.Account
				,MSR0.Credit
				,MSR0.Debit
				,MSR0.VoucherNumber
				,MSR0.LineItem
				,MSR0.Verification
				,MSR0.Processed
				,MSR0.Container
				,MSR0.Chassis
				,MSR0.Intercompany
				,MSR0.InvoiceLoaded
				,MSR1.depot_loc
				,'SINGLE' AS RecordType
		FROM	ILSINT02.Integrations.dbo.MSR_ReceviedTransactions MSR0
				LEFT JOIN #tmpData MSR1 ON MSR0.DocNumber = MSR1.inv_no --OR MSR0.Description = MSR1.inv_batch
		WHERE	MSR0.BatchId = @BatchId
				AND (@Status IS Null OR (@Status IS NOT Null AND MSR0.Processed = @Status))
				AND MSR0.Intercompany = 0
				AND MSR0.Credit + MSR0.Debit <> 0 
				AND MSR0.DocNumber <> 'B0'
				AND (@CustomerNo IS Null OR (@CustomerNo IS NOT Null AND MSR0.Customer = @CustomerNo))
		UNION
		SELECT	DISTINCT MSR1.inv_no
				,MSR1.inv_batch
				,MSR1.batch_total
				,MSR1.batch_sale_tax
				,MSR1.batch_labor
				,MSR1.batch_parts
				,MSR0.MSR_ReceivedTransactions
				,MSR0.Company
				,MSR0.BatchId
				,MSR0.DocNumber
				,MSR0.Description
				,MSR1.inv_date AS DocDate
				,MSR0.Customer
				,MSR0.DocType
				,MSR0.Amount
				,MSR0.Account
				,MSR0.Credit
				,MSR0.Debit
				,MSR0.VoucherNumber
				,MSR0.LineItem
				,MSR0.Verification
				,MSR0.Processed
				,MSR1.Container
				,MSR1.Chassis
				,MSR0.Intercompany
				,MSR0.InvoiceLoaded
				,MSR1.depot_loc
				,'BATCH' AS RecordType
		FROM	ILSINT02.Integrations.dbo.MSR_ReceviedTransactions MSR0
				LEFT JOIN #tmpData MSR1 ON MSR0.Description = MSR1.inv_batch AND MSR0.Customer = MSR1.acct_no
		WHERE	MSR0.BatchId = @BatchId
				AND (@Status IS Null OR (@Status IS NOT Null AND MSR0.Processed = @Status))
				AND MSR0.Intercompany = 0
				AND MSR0.Credit + MSR0.Debit <> 0 
				AND MSR0.DocNumber = 'B0'
				AND MSR0.Description = 'B0'
				AND (@CustomerNo IS Null OR (@CustomerNo IS NOT Null AND MSR0.Customer = @CustomerNo))
		) DATA

DECLARE curMSR_Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT *
	FROM	#tmpMSRData
	WHERE	RecordType = 'BATCH'

OPEN curMSR_Transactions 
FETCH FROM curMSR_Transactions INTO @inv_no, @inv_batch, @batch_total, @batch_sale_tax, @batch_labor, @batch_parts, @MSR_ReceivedTransactions, @Company,
									@BatchId, @DocNumber, @Description, @DocDate, @Customer, @DocType, @Amount, @Account, @Credit, @Debit, @VoucherNumber,
									@LineItem, @Verification, @Processed, @Container, @Chassis, @Intercompany, @InvoiceLoaded, @depot_loc, @RecordType, @RowNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE	#tmpMSRData
	SET		DocNumber = @inv_no,
			Amount = @batch_total
	WHERE	RowNumber = @RowNumber

	IF PATINDEX('%1050%', @Account) > 0 -- Accounts Receivable
		UPDATE	#tmpMSRData
		SET		Debit = @batch_total
		WHERE	RowNumber = @RowNumber

	IF PATINDEX('%2110%', @Account) > 0 -- Sales Tax
		UPDATE	#tmpMSRData
		SET		Credit = @batch_sale_tax
		WHERE	RowNumber = @RowNumber

	IF PATINDEX('%4013%', @Account) > 0 -- Parts
		UPDATE	#tmpMSRData
		SET		Credit = @batch_parts
		WHERE	RowNumber = @RowNumber

	IF PATINDEX('%4016%', @Account) > 0 -- Labor
		UPDATE	#tmpMSRData
		SET		Credit = @batch_labor
		WHERE	RowNumber = @RowNumber

	FETCH FROM curMSR_Transactions INTO @inv_no, @inv_batch, @batch_total, @batch_sale_tax, @batch_labor, @batch_parts, @MSR_ReceivedTransactions, @Company,
									@BatchId, @DocNumber, @Description, @DocDate, @Customer, @DocType, @Amount, @Account, @Credit, @Debit, @VoucherNumber,
									@LineItem, @Verification, @Processed, @Container, @Chassis, @Intercompany, @InvoiceLoaded, @depot_loc, @RecordType, @RowNumber
END

CLOSE curMSR_Transactions
DEALLOCATE curMSR_Transactions

IF @JustDocList = 0
BEGIN
	SELECT	MSR_ReceivedTransactions
			,Company
			,BatchId
			,DocNumber
			,Description
			,DocDate
			,Customer
			,DocType
			,Amount
			,Account
			,Credit
			,Debit
			,VoucherNumber
			,LineItem
			,Verification
			,Processed
			,Container
			,Chassis
			,Intercompany
			,InvoiceLoaded
			,depot_loc
			,RecordType
			,Null AS WorkOrder
	FROM	#tmpMSRData
	WHERE	(@CustomerNo IS Null OR (@CustomerNo IS NOT Null AND Customer = @CustomerNo))
			AND (@Doc_Number IS Null OR (@Doc_Number IS NOT Null AND DocNumber = @Doc_Number))
			AND (@Doc_Date IS Null OR (@Doc_Date IS NOT Null AND DocDate = @Doc_Date))
	ORDER BY Description, DocNumber
END
ELSE
BEGIN
	SELECT	DISTINCT DocNumber, 
			DocDate, 
			Customer, 
			DocType, 
			Amount, 
			Intercompany
	FROM	#tmpMSRData
	ORDER BY Intercompany, Customer, DocNumber
END

DROP TABLE #tmpData
DROP TABLE #tmpMSRData