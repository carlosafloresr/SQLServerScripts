DECLARE	@VendorId		Varchar(12) = 'D50479',
		@Integration	varchar(6) = 'SBA', 
        @Company		varchar(5) = 'DNJ',
        @BatchId		varchar(15) = 'SBA_20220218',
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date = '02/18/2022',
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@SqncLine		int = 500,
		@Document		varchar(30)

SELECT	'Bonus Pay for Date ' + CONVERT(Char(10), PayDate, 101) AS Reference, 
		SUM(PeriodPay) AS PeriodPay 
INTO	#tmpBonusPay
FROM	GPCustom.dbo.SafetyBonus
WHERE	VendorId = @VendorId
		AND PayDate > '02/16/2022'
		AND SortColumn = 1
GROUP BY PayDate
ORDER BY 1

--UPDATE	#tmpBonusPay
--SET		PeriodPay = PeriodPay * 2

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		@TrxDate AS PSTGDATE,
		Reference,
		@TrxDate AS TRXDATE,
		2 AS Series,
		'CFLORES' AS UserId,
		'0-04-2200' AS ACTNUMST,
		0 AS Debit,
		PeriodPay AS Credit,
		Reference AS TRXDESCRIP,
		Reference AS Document
FROM	#tmpBonusPay
UNION
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		@TrxDate AS PSTGDATE,
		'Safety Bonus' AS Reference,
		@TrxDate AS TRXDATE,
		2 AS Series,
		'CFLORES' AS UserId,
		'1-26-6144' AS ACTNUMST,
		SUM(PeriodPay) AS Debit,
		0 AS Credit,
		'Safety Bonus' AS TRXDESCRIP,
		'Safety Bonus' AS Document
FROM	#tmpBonusPay

DELETE	PRISQL004P.Integrations.dbo.Integrations_GL
WHERE	Company = @Company
		AND BatchId = @BatchId
		AND Integration = @Integration

DELETE	PRISQL004P.Integrations.dbo.ReceivedIntegrations
WHERE	Company = @Company
		AND BatchId = @BatchId
		AND Integration = @Integration

OPEN curData 
FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
									  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @Document

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
											  @UserId, @ActNumSt, @DebitAmt, @CrdtAmnt, @Dscriptn, @VendorId, Null, @BatchId, Null, Null, Null, Null, @SqncLine

	SET @SqncLine = @SqncLine + 500

	FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
										  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @Document
END

CLOSE curData
DEALLOCATE curData

IF @@ERROR = 0
BEGIN
	EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
	EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
END

DROP TABLE #tmpBonusPay