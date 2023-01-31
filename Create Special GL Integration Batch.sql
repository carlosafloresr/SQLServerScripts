DECLARE	@Integration	varchar(6) = 'SPCGL',
        @Company		varchar(5) = 'TISO',
		@TransDate		date = '10/18/2019',
		@CreditAcct		varchar(15) = '0-05-1101',
		@DebitAcct		varchar(15) = '0-00-1050',
        @BatchId		varchar(15),
		@DatePortion	Varchar(15) = dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date,
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@SqncLine		int

SET @BatchId = @Integration + @DatePortion

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		@TransDate,
		RTRIM(ProLd) + '/' + RTRIM(Invoice),
		@TransDate,
		2 AS SERIES,
		'CFLORES' AS UserId,
		IIF(Total_Invoiced > 0, @DebitAcct, @CreditAcct),
		IIF(Total_Invoiced > 0, 0, ABS(Total_Invoiced)) AS CRDTAMNT,
		IIF(Total_Invoiced > 0, ABS(Total_Invoiced), 0) AS DEBITAMT,
		RTRIM(ProLd) + '/' + RTRIM(Invoice),
		0 as RowNumber --ROW_NUMBER() OVER(PARTITION BY Invoice ORDER BY Invoice) * 500 AS RowNumber
FROM	TISCNI2
UNION
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		@TransDate,
		RTRIM(ProLd) + '/' + RTRIM(Invoice),
		@TransDate,
		2 AS SERIES,
		'CFLORES' AS UserId,
		IIF(Total_Invoiced > 0, @CreditAcct, @DebitAcct),
		IIF(Total_Invoiced > 0, ABS(Total_Invoiced), 0) AS CRDTAMNT,
		IIF(Total_Invoiced > 0, 0, ABS(Total_Invoiced)) AS DEBITAMT,
		RTRIM(ProLd) + '/' + RTRIM(Invoice),
		0 as RowNumber --ROW_NUMBER() OVER(PARTITION BY Invoice ORDER BY Invoice) * 500 AS RowNumber
FROM	TISCNI2

OPEN curData 
FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
									  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
										  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, Null, Null, Null, Null, Null, Null, Null, @SqncLine

	FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
										  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine
END

CLOSE curData
DEALLOCATE curData

IF @@ERROR = 0
BEGIN
	EXECUTE USP_ReceivedIntegrations @Integration, @Company, @BatchId
	EXECUTE USP_Integrations_GL_Select @Company, @BatchId, @Integration
END

GO