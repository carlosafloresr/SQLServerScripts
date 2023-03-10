USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AgentsSettlements_Integration_AGST_Test]    Script Date: 6/16/2022 10:06:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AgentsSettlements_Integration_AGST_Test 'NDS20180922'
EXECUTE USP_AgentsSettlements_Integration_AGST_Test 'NDS20180922', '53'

UPDATE	AgentsSettlementsCommisions 
SET		Integrated = 0
		--,DEXSubmitted = 0
WHERE	BatchId = 'NDS20180922'
		AND BatchApproved = 1
		AND Integrated = 1
		AND Agent = '53'
*/
ALTER PROCEDURE [dbo].[USP_AgentsSettlements_Integration_AGST_Test]
		@BatchId			varchar(15),
		@Agent				varchar(3) = Null
AS
SET NOCOUNT ON

DECLARE	@Integration		varchar(6) = 'AGST', 
		@Company			varchar(5) = 'NDS', 
		@VCHNUMWK			varchar(17), 
		@VENDORID			varchar(15), 
		@DOCNUMBR			varchar(20), 
		@DOCTYPE			smallint = 1, 
		@DOCAMNT			numeric(18, 2), 
		@DOCDATE			datetime, 
		@PSTGDATE			datetime, 
		@CHRGAMNT			numeric(18, 2) = 0, 
		@TEN99AMNT			numeric(18, 2) = 0, 
		@PRCHAMNT			numeric(18, 2) = 0, 
		@TRXDSCRN			varchar(30), 
		@CURNCYID			varchar(15) = 'USD2', 
		@RATETPID			varchar(15) = 'AVERAGE', 
		@EXCHDATE			datetime = '01/01/2007', 
		@RATEEXPR			smallint = 0, 
		@CREATEDIST			smallint = 0, 
		@DISTTYPE			smallint = 6, 
		@ACTNUMST			varchar(75), 
		@DEBITAMT			numeric(18, 2), 
		@CRDTAMNT			numeric(18, 2), 
		@DISTREF			varchar(30), 
		@RecordId			bigint = 0, 
		@UserId				varchar(25) = 'Agent Settlement App', 
		@ProNumber			varchar(15) = null, 
		@Container			varchar(25) = null, 
		@Chassis			varchar(25) = null, 
		@DriverId			varchar(15) = null, 
		@PORDNMBR			varchar(20) = null, 
		@Division			varchar(3) = null, 
		@Failure			varchar(50) = null, 
		@RepairType			varchar(20) = null, 
		@InvoiceNumber		varchar(30) = null, 
		@Hold_AP			bit = 0, 
		@RefNum				varchar(100) = null, 
		@SOPInvoiceNumber	varchar(15) = null,
		@ETADate			date = null,
		@RepairDate			date = Null,
		@UnitNumber			varchar(90) = Null,
		@NewBatchId			Varchar(20),
		@WeekendDate		Date,
		@ReturnValue		Smallint = 0,
		@OriginalAmount		Numeric(10,2) = 0,
		@RecordsCounter		Int = 0

SET @NewBatchId	= REPLACE(@BatchId, 'NDS', @Integration + '-')
SET @WeekendDate =  (SELECT WeekendDate FROM AgentsSettlementsBatches WHERE BatchId = @BatchId)

DECLARE @tblAgents Table (Agent Varchar(3))

INSERT INTO @tblAgents
SELECT	Agent
FROM	AgentsSettlementsCommisions 
WHERE	Company = @Company 
		AND BatchId = @BatchId 
		AND BatchApproved = 1 
		AND Integrated = 0 
		AND (@Agent IS Null OR (@Agent IS NOT Null AND Agent = @Agent))

DECLARE @curData Table (
	[VCHNUMWK] [nvarchar](40) NULL,
	[VENDORID] [varchar](15) NULL,
	[DOCNUMBR] [varchar](50) NULL,
	[DOCAMNT] [numeric](38, 2) NULL,
	[DOCDATE] [date] NULL,
	[PSTGDATE] [date] NULL,
	[CHRGAMNT] [numeric](38, 2) NULL,
	[TEN99AMNT] [numeric](38, 2) NULL,
	[PRCHAMNT] [numeric](38, 2) NULL,
	[TRXDSCRN] [varchar](50) NULL,
	[DISTTYPE] [int] NOT NULL,
	[ACTNUMST] [varchar](100) NULL,
	[DEBITAMT] [numeric](10, 2) NOT NULL,
	[CRDTAMNT] [numeric](10, 2) NULL,
	[DISTREF] [varchar](50) NULL,
	[RecordId] [int] NOT NULL,
	[ProNumber] [varchar](100) NULL,
	[Agent] [varchar](3),
	[OriginalAmount] [numeric](10,2) NULL)

SELECT	*
INTO	#tmpData
FROM	(
		SELECT	VendorId,
				'WE_' + REPLACE(@BatchId, 'NDS', '') AS DOCNUMBR,
				ABS(NetCommission) AS DOCAMNT,
				WeekendDate AS DOCDATE,
				WeekendDate AS PSTGDATE,
				ABS(NetCommission) AS CHRGAMNT,
				ABS(NetCommission) AS TEN99AMNT,
				ABS(NetCommission) AS PRCHAMNT,
				'WE ' + CAST(@WeekendDate AS Varchar) AS TRXDSCRN,
				IIF(NetCommission > 0, 6, 2) AS DISTTYPE,
				CreditAccount AS ACTNUMST,
				IIF(NetCommission > 0, 0, DeductionAmount) AS DEBITAMT,
				IIF(NetCommission > 0, DeductionAmount, 0) AS CRDTAMNT,
				LEFT(RTRIM(DeductionDescription), 19) + ' ' + CAST(WeekendDate AS Varchar) AS DISTREF,
				0 AS RecordId,
				'WE_' + REPLACE(@BatchId, 'NDS', '') AS ProNumber,
				Agent,
				NetCommission AS OriginalAmount
		FROM	View_AgentsSettlements_WeeklyBatch
		WHERE	Company = @Company
				AND Hold = 0
				AND BatchId = @BatchId
				AND NetCommission IS NOT Null
				AND Agent IN (SELECT Agent FROM @tblAgents)
		UNION
		SELECT	VendorId,
				'WE_' + REPLACE(@BatchId, 'NDS', '') AS DOCNUMBR,
				ABS(NetCommission) AS DOCAMNT,
				WeekendDate AS DOCDATE,
				WeekendDate AS PSTGDATE,
				ABS(NetCommission) AS CHRGAMNT,
				ABS(NetCommission) AS TEN99AMNT,
				ABS(NetCommission) AS PRCHAMNT,
				'WE ' + CAST(WeekendDate AS Varchar) AS TRXDSCRN,
				IIF(NetCommission > 0, 6, 2) AS DISTTYPE,
				ISNULL(ACC.ACTNUMST, CASE WHEN AST.Agent = '22' THEN '22-11-6620' ELSE '' END) AS ACTNUMST,
				IIF(NetCommission > 0, 0, ChassisUsage) AS DEBITAMT,
				IIF(NetCommission > 0, ChassisUsage, 0) AS CRDTAMNT,
				'ChassisUsage WE ' + REPLACE(@BatchId, 'NDS', '') AS DISTREF,
				0 AS RecordId,
				'WE_' + REPLACE(@BatchId, 'NDS', '') AS ProNumber,
				AST.Agent,
				NetCommission AS OriginalAmount
		FROM	AgentsSettlementsCommisions AST
				INNER JOIN AgentsSettlementsBatches ASB ON AST.Company = ASB.Company AND AST.BatchId = ASB.BatchId
				LEFT JOIN (SELECT DISTINCT Agent, VendorId FROM Agents WHERE VendorId IS NOT Null) ASD ON AST.Agent = ASD.Agent
				LEFT JOIN (SELECT RTRIM(ACTNUMBR_1) AS Agent, RTRIM(ACTNUMBR_1) + '-' + RTRIM(ACTNUMBR_2) + '-' + RTRIM(ACTNUMBR_3) AS ACTNUMST FROM NDS.dbo.GL00100 WHERE ACTIVE = 1 AND ACTNUMBR_3 = '2100') ACC ON AST.Agent = ACC.Agent
		WHERE	AST.Company = @Company
				AND AST.BatchId = @BatchId
				AND AST.Agent IN (SELECT Agent FROM @tblAgents)
				AND AST.Agent NOT IN (SELECT Agent FROM Agents WHERE ChassisBillingDeferral = 0 GROUP BY Agent)
				AND AST.ChassisUsage <> 0
		UNION
		SELECT	ASD.VendorId,
				'WE_' + REPLACE(@BatchId, 'NDS', ''),
				ABS(AGC.NetCommission),
				@WeekendDate,
				AST.WeekendDate,
				ABS(AGC.NetCommission),
				ABS(AGC.NetCommission),
				ABS(AGC.NetCommission),
				'WE ' + CAST(@WeekendDate AS Varchar),
				IIF(NetCommission > 0, 6, 2) AS DISTTYPE,
				(SELECT	TOP 1 RTRIM(ACTNUMBR_1) + '-' + RTRIM(ACTNUMBR_2) + '-' + RTRIM(ACTNUMBR_3) FROM NDS.dbo.GL00100 WHERE ACTIVE = 1 AND ACTNUMBR_3 = '1107' AND ACTNUMBR_1 = AST.Agent),
				IIF(NetCommission > 0, 0, AST.Amount) AS DEBITAMT,
				IIF(NetCommission > 0, AST.Amount, 0) AS CRDTAMNT,
				AST.Description AS DISTREF,
				ROW_NUMBER() OVER(ORDER BY VendorId),
				AST.ProNumber,
				AST.Agent,
				NetCommission AS OriginalAmount
		FROM	AgentsSettlementsTransactions AST
				INNER JOIN AgentsSettlementsBatches ASB ON AST.Company = ASB.Company AND AST.WeekendDate = ASB.WeekendDate
				INNER JOIN AgentsSettlementsCommisions AGC ON AST.Agent = AGC.Agent AND AGC.BatchId = @BatchId
				LEFT JOIN (SELECT DISTINCT Agent, VendorId FROM Agents WHERE VendorId IS NOT Null) ASD ON AST.Agent = ASD.Agent
		WHERE	ASB.BatchId = @BatchId
				AND AST.Hold = 0
				AND AST.Amount <> 0
				AND AST.Agent IN (SELECT Agent FROM @tblAgents)
		UNION
		SELECT	VendorId,
				'WE_' + REPLACE(@BatchId, 'NDS', '') AS DOCNUMBR,
				ABS(NetCommission) AS DOCAMNT,
				WeekendDate AS DOCDATE,
				WeekendDate AS PSTGDATE,
				ABS(NetCommission) AS CHRGAMNT,
				ABS(NetCommission) AS TEN99AMNT,
				ABS(NetCommission) AS PRCHAMNT,
				'WE ' + CAST(@WeekendDate AS Varchar) AS TRXDSCRN,
				IIF(NetCommission > 0, 6, 2) AS DISTTYPE,
				ACC.ACTNUMST AS ACTNUMST,
				IIF(NetCommission > 0, Commission, 0) AS DEBITAMT,
				IIF(NetCommission > 0, 0, Commission) AS CRDTAMNT,
				'WE ' + REPLACE(@BatchId, 'NDS', '') AS DISTREF,
				0 AS RecordId,
				'WE_' + REPLACE(@BatchId, 'NDS', '') AS ProNumber,
				AST.Agent,
				NetCommission AS OriginalAmount
		FROM	AgentsSettlementsCommisions AST
				INNER JOIN AgentsSettlementsBatches ASB ON AST.Company = ASB.Company AND AST.BatchId = ASB.BatchId
				LEFT JOIN (SELECT DISTINCT Agent, VendorId FROM Agents WHERE VendorId IS NOT Null) ASD ON AST.Agent = ASD.Agent
				LEFT JOIN (SELECT RTRIM(ACTNUMBR_1) AS Agent, RTRIM(ACTNUMBR_1) + '-' + RTRIM(ACTNUMBR_2) + '-' + RTRIM(ACTNUMBR_3) AS ActNumst FROM NDS.dbo.GL00100 WHERE ACTNUMBR_3 = '6220' AND ACTIVE = 1) ACC ON AST.Agent = ACC.Agent
		WHERE	AST.Company = @Company
				AND AST.BatchId = @BatchId
				AND AST.Agent IN (SELECT Agent FROM @tblAgents)
		) DATA
ORDER BY VendorId

SELECT	TMP.VENDORID, 
		TMP.DOCNUMBR, 
		DOCAMNT = ABS((SELECT TOP 1 ISNULL(T2.DOCAMNT,0) FROM #tmpData T2 WHERE T2.VendorId = TMP.VendorId AND T2.ACTNUMST LIKE '%-6220')),
		@WeekendDate AS DOCDATE, 
		@WeekendDate AS PSTGDATE, 
		CHRGAMNT = ABS((SELECT TOP 1 ISNULL(T2.DOCAMNT,0) FROM #tmpData T2 WHERE T2.VendorId = TMP.VendorId AND T2.ACTNUMST LIKE '%-6220')),
		TEN99AMNT = ABS((SELECT TOP 1 ISNULL(T2.DOCAMNT,0) FROM #tmpData T2 WHERE T2.VendorId = TMP.VendorId AND T2.ACTNUMST LIKE '%-6220')),
		PRCHAMNT = ABS((SELECT TOP 1 ISNULL(T2.DOCAMNT,0) FROM #tmpData T2 WHERE T2.VendorId = TMP.VendorId AND T2.ACTNUMST LIKE '%-6220')),
		'WE ' + CAST(@WeekendDate AS Varchar) AS TRXDSCRN, 
		TMP.DISTTYPE, 
		TMP.ACTNUMST, 
		DEBITAMT,
		CRDTAMNT,
		TMP.DISTREF, 
		TMP.RecordId, 
		TMP.ProNumber,
		TMP.Agent,
		TMP.OriginalAmount
INTO	#tmpResult
FROM	#tmpData TMP

INSERT INTO @curData
SELECT	DISTINCT @Integration + SUBSTRING(@BatchId, 6, 8) + '_' + TMP.Agent AS VCHNUMWK,
		VENDORID, 
		DOCNUMBR, 
		ISNULL(DOCAMNT,TOTAMOUNT), 
		@WeekendDate, 
		@WeekendDate, 
		ISNULL(DOCAMNT,TOTAMOUNT) AS CHRGAMNT,  
		ISNULL(DOCAMNT,TOTAMOUNT) AS TEN99AMNT, 
		ISNULL(DOCAMNT,TOTAMOUNT) AS PRCHAMNT,  
		'WE ' + CAST(@WeekendDate AS Varchar), 
		IIF(OriginalAmount > 0, 2, 6) AS DISTTYPE,
		'00-00-2070' AS ACTNUMST, 
		CASE WHEN CHRGAMNT < 0 THEN ABS((SELECT SUM(T2.DEBITAMT - T2.CRDTAMNT) FROM #tmpResult T2 WHERE T2.VendorId = TMP.VendorId)) ELSE 0 END AS DEBITAMT, 
		CASE WHEN CHRGAMNT < 0 THEN 0 ELSE ABS((SELECT SUM(T2.DEBITAMT - T2.CRDTAMNT) FROM #tmpResult T2 WHERE T2.VendorId = TMP.VendorId)) END AS CRDTAMNT, 
		TRXDSCRN AS DISTREF, 
		0 AS RecordId, 
		DOCNUMBR AS ProNumber,
		TMP.Agent,
		OriginalAmount
FROM	#tmpResult TMP
		LEFT JOIN (SELECT Agent, MAX(DOCAMNT) AS TOTAMOUNT FROM #tmpResult GROUP BY Agent) TOT ON TMP.Agent = TOT.Agent
UNION
SELECT	DISTINCT @Integration + SUBSTRING(@BatchId, 6, 8) + '_' + Agent AS VCHNUMWK,* 
FROM	#tmpData

DROP TABLE #tmpData
DROP TABLE #tmpResult

SELECT	DISTINCT *
FROM	@curData TMP
ORDER BY VendorId, DISTREF

DECLARE curDeductions CURSOR LOCAL KEYSET OPTIMISTIC FOR	
SELECT	DISTINCT *
FROM	@curData TMP
WHERE	DEBITAMT + CRDTAMNT <> 0
ORDER BY VendorId, DISTREF

SET @RecordsCounter = @@ROWCOUNT

OPEN curDeductions 
FETCH FROM curDeductions INTO @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCAMNT, @DOCDATE, @PSTGDATE, @CHRGAMNT, @TEN99AMNT,
							  @PRCHAMNT, @TRXDSCRN, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DISTREF, @RecordId, @ProNumber, @Agent, @OriginalAmount

DELETE	DEX_ET_PopUps
WHERE	CompanyId = @Company
		AND BatchId = @NewBatchId

DELETE	[findata-intg-ms.imcc.com].Integrations.dbo.ReceivedIntegrations 
WHERE	Integration = @Integration
		AND Company = @Company
		AND BatchId = @NewBatchId

DELETE	[findata-intg-ms.imcc.com].Integrations.dbo.Integrations_AP 
WHERE	Integration = @Integration
		AND Company = @Company
		AND BatchId = @NewBatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @DOCAMNT	= ABS(@DOCAMNT)
	SET @CHRGAMNT	= @DOCAMNT
	SET @TEN99AMNT	= @DOCAMNT
	SET @PRCHAMNT	= @DOCAMNT
	SET @DOCTYPE	= IIF(@OriginalAmount > 0, 1, 5)

	EXECUTE [findata-intg-ms.imcc.com].Integrations.dbo.USP_Integrations_AP_Full @Integration, 
																@Company,
																@NewBatchId,
																@VCHNUMWK,
																@VENDORID,
																@DOCNUMBR,
																@DOCTYPE, 
																@DOCAMNT, 
																@DOCDATE, 
																@PSTGDATE, 
																@CHRGAMNT, 
																@TEN99AMNT, 
																@PRCHAMNT,
																@TRXDSCRN,
																@CURNCYID,
																@RATETPID,
																@EXCHDATE,
																@RATEEXPR,
																@CREATEDIST,
																@DISTTYPE,
																@ACTNUMST,
																@DEBITAMT,
																@CRDTAMNT, 
																@DISTREF, 
																@RecordId,
																@UserId,
																@ProNumber,
																@Container,
																@Chassis,
																@DriverId,
																@PORDNMBR,
																@Division,
																@Failure,
																@RepairType,
																@InvoiceNumber,
																@Hold_AP,
																@RefNum,
																@SOPInvoiceNumber,
																@ETADate,
																@RepairDate,
																@UnitNumber

	FETCH FROM curDeductions INTO @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCAMNT, @DOCDATE, @PSTGDATE, @CHRGAMNT, @TEN99AMNT,
								  @PRCHAMNT, @TRXDSCRN, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DISTREF, @RecordId, @ProNumber, @Agent, @OriginalAmount
END

CLOSE curDeductions
DEALLOCATE curDeductions

PRINT 'Records: ' + CAST(@RecordsCounter AS Varchar)

IF @@ERROR = 0 AND @RecordsCounter > 0
BEGIN
	EXECUTE [findata-intg-ms.imcc.com].Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @NewBatchId, 0

	UPDATE	AgentsSettlementsCommisions
	SET		Integrated = 1
			,DEXSubmitted = 0
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND BatchApproved = 1
			AND Integrated = 0
			AND Agent IN (SELECT Agent FROM @tblAgents)

	--DECLARE	@AgentsTotal		Int,
	--		@IntegratedAgents	Int

	--SELECT	@AgentsTotal		= COUNT(*), 
	--		@IntegratedAgents	= SUM(CASE WHEN Integrated = 1 THEN 1 ELSE 0 END)
	--FROM	AgentsSettlementsCommisions
	--WHERE	BatchId = @BatchId

	--IF @AgentsTotal = @IntegratedAgents
	--BEGIN
	--	UPDATE AgentsSettlementsBatches SET ClosedOn = GETDATE() WHERE Company = @Company AND BatchId = @BatchId
	--	SET @ReturnValue = 2
	--END

	RETURN @ReturnValue
END
ELSE
	RETURN 0