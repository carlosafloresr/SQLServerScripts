/*
EXECUTE USP_EFS_DailyIntegration
*/
ALTER PROCEDURE USP_EFS_DailyIntegration
AS
DECLARE	@PopUpId		int,
		@EscrowType		int,
		@FormType		int,
		@Amount			numeric(12,2),
		@Code_Id		int,
		@InvoiceNumber	varchar(30),
		@Dscriptn		varchar(100),
		@TrxDate		date,
		@PstgDate		date,
		@ProNumber		varchar(15),
		@BatchId		varchar(20),
		@GPDesc			varchar(30)

SELECT	'FRA_' + REPLACE(CONVERT(Varchar, Activated_Timeissued_Date + 1, 102), '.', '') AS BatchId
INTO	#tmpBatches
FROM	EFS_DailyReport
WHERE	Processed = -5

DECLARE Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Code_Id, 
		Express_Code,
		Original_Amt,
		'Paid ' + RTRIM(Issued_To) + ' Check ' + RTRIM(Check_Num),
		CAST(Activated_Timeissued_Date AS Date),
		CAST(Activated_Timeissued_Date + 1 AS Date),
		PO_Number,
		'FRA_' + REPLACE(CONVERT(Varchar, Activated_Timeissued_Date + 1, 102), '.', ''),
		PopUpId,
		LEFT('Pro: ' + RTRIM(PO_Number) + ' Equip: ' + RTRIM(Trailer_Number), 30)
FROM	EFS_DailyReport
WHERE	Processed = 0

OPEN Transactions 
FETCH FROM Transactions INTO @Code_Id, @InvoiceNumber, @Amount, @Dscriptn, @TrxDate, @PstgDate, @ProNumber, @BatchId, @PopUpId, @GPDesc

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF NOT EXISTS(SELECT VendorId FROM LENSASQL001.[FI].dbo.PM00400 WHERE VendorId = '223R' AND DocNumbr = @InvoiceNumber)
	BEGIN
		IF @PopUpId = 0
		BEGIN
			EXECUTE @PopUpId = LENSASQL001.[GPCustom].dbo.USP_DEX_ET_PopUps @InvoiceNumber, 
																			'FI', 
																			5, 
																			'5-29-2104',
																			6,
																			'223R',
																			Null,
																			'29',
																			@Amount,
																			Null,
																			Null,
																			Null,
																			@Dscriptn,
																			'EFS_DailyImport',
																			Null,
																			Null,
																			'AP',
																			@TrxDate,
																			Null,
																			0,	-- Item
																			@ProNumber,
																			@PstgDate,
																			Null,
																			Null,
																			@BatchId,
																			@InvoiceNumber

			IF @PopUpId > 0
			BEGIN
				UPDATE	EFS_DailyReport
				SET		PopUpId	= @PopUpId
				WHERE	Code_Id = @Code_Id
			END
		END

		IF NOT EXISTS(SELECT TOP 1 BatchId FROM Integrations.dbo.Integrations_AP WHERE Integration = 'FRA' AND BatchId = @BatchId AND RecordId = @Code_Id)
		BEGIN
			INSERT INTO Integrations.dbo.Integrations_AP
					(Integration,
					Company,
					BatchId,
					VchNumWk,
					VendorId,
					DocNumbr,
					DocType,
					DocAmnt,
					DocDate,
					PstgDate,
					POrdNmbr,
					ChrgAmnt,
					Ten99Amnt,
					PrchAmnt,
					TrxDscrn,
					DistType,
					ActNumSt,
					DebitAmt,
					CrdtAmnt,
					DistRef,
					RecordId,
					ProNum,
					Container,
					GPPostingDate,
					VendorName,
					InvoiceNum,
					OutDate,
					InDate,
					FreeTime,
					BillToCustomer,
					SOPInvoiceNumber,
					CustAdmAcct,
					RefNum,
					Chassis,
					PopUpId)
			SELECT	'FRA' AS Integration,
					'FI' AS Company,
					@BatchId AS BatchId,
					'FRA_' + Code_Id AS VchNumWk,
					'223R' AS VendorId,
					@InvoiceNumber AS DocNumbr,
					1 AS DocType,
					@Amount AS DocAmnt,
					CAST(Bill_Date AS Date) AS DocDate,
					@PstgDate AS PstgDate,
					PO_Number AS POrdNmbr,
					@Amount AS ChrgAmnt,
					0 AS Ten99Amnt,
					@Amount AS PrchAmnt,
					@GPDesc AS TrxDscrn,
					6 AS DistType,
					'5-29-2104' AS ActNumSt,
					@Amount AS DebitAmt,
					0 AS CrdtAmnt,
					@GPDesc AS DistRef,
					Code_Id AS RecordId,
					PO_Number AS ProNum,
					Trailer_Number AS Container,
					CAST(Bill_Date + 1 AS Date) AS GPPostingDate,
					'EFS' AS VendorName,
					@InvoiceNumber AS InvoiceNumber,
					Null AS OutDate,
					Null AS InDate,
					Null AS FreeTime,
					Null AS BillToCustomer,
					Null AS SOPInvoiceNumber,
					Null AS CustAdmAcct,
					Null AS RefNum,
					Null AS Chassis,
					PopUpId AS PopUpId
			FROM	EFS_DailyReport
			WHERE	Code_Id = @Code_Id
			UNION
			SELECT	'FRA' AS Integration,
					'FI' AS Company,
					@BatchId AS BatchId,
					'FRA_' + Code_Id AS VchNumWk,
					'223R' AS VendorId,
					@InvoiceNumber AS DocNumbr,
					1 AS DocType,
					@Amount AS DocAmnt,
					CAST(Bill_Date AS Date) AS DocDate,
					@PstgDate AS PstgDate,
					PO_Number AS POrdNmbr,
					@Amount AS ChrgAmnt,
					0 AS Ten99Amnt,
					@Amount AS PrchAmnt,
					@GPDesc AS TrxDscrn,
					2 AS DistType,
					'0-00-2070' AS ActNumSt,
					0 AS DebitAmt,
					@Amount AS CrdtAmnt,
					@GPDesc AS DistRef,
					Code_Id AS RecordId,
					PO_Number AS ProNum,
					Trailer_Number AS Container,
					CAST(Bill_Date + 1 AS Date) AS GPPostingDate,
					'EFS' AS VendorName,
					@InvoiceNumber AS InvoiceNumber,
					Null AS OutDate,
					Null AS InDate,
					Null AS FreeTime,
					Null AS BillToCustomer,
					Null AS SOPInvoiceNumber,
					Null AS CustAdmAcct,
					Null AS RefNum,
					Null AS Chassis,
					0 AS PopUpId
			FROM	EFS_DailyReport
			WHERE	Code_Id = @Code_Id
			ORDER BY 17 DESC

			UPDATE	EFS_DailyReport
			SET		Processed = 1
			WHERE	Code_Id = @Code_Id

			INSERT INTO #tmpBatches (BatchId) VALUES (@BatchId)
		END
	END
	
	FETCH FROM Transactions INTO @Code_Id, @InvoiceNumber, @Amount, @Dscriptn, @TrxDate, @PstgDate, @ProNumber, @BatchId, @PopUpId, @GPDesc
END

CLOSE Transactions
DEALLOCATE Transactions

INSERT INTO Integrations.dbo.ReceivedIntegrations (Integration, BatchId, Company)
SELECT	DISTINCT 'FRA',
		BatchId,
		'FI'
FROM	#tmpBatches

DROP TABLE #tmpBatches
GO
/*
SELECT	*
FROM	Integrations.dbo.Integrations_AP
WHERE	Batchid = @BatchId

SELECT	*
FROM	EFS_DailyReport

UPDATE	EFS_DailyReport
SET		Processed = 0,
		PopUpId = 0
WHERE	Bill_Date > '01/23/2014'

DELETE	Integrations.dbo.Integrations_AP
WHERE	Batchid IN ('FRA_20140123','FRA_20140124')

DELETE	Integrations.dbo.ReceivedIntegrations
WHERE	Batchid IN ('FRA_20140123','FRA_20140124')
*/
-- TRUNCATE TABLE EFS_DailyReport