/*
EXECUTE USP_Integrations_AR_ShortPay 'GIS', '12190', '21-128441', 'C21-128441', '11/18/2014', 575.40, 'D', Null
*/
ALTER PROCEDURE USP_Integrations_AR_ShortPay
		@Company		Varchar(5),
		@CustomerNum	Varchar(15),
		@OriDocNumber	Varchar(30),
		@NewDocNumber	Varchar(30),
		@DocumentDate	Date,
		@DocAmount		Numeric(10,2),
		@TransType		Char(1),
		@DocDescript	Varchar(30) = Null
AS
DECLARE	@Integration	varchar(6) = 'SHP'
        ,@BatchId		varchar(25) = 'SHP' + CAST(CAST(YEAR(GETDATE()) AS Varchar) + dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + REPLACE(CONVERT(Char(5), GETDATE(), 14), ':', '') AS Varchar)
        ,@DOCNUMBR		varchar(20)
        ,@DUEDATE		datetime
        ,@DOCAMNT		money
        ,@SLSAMNT		money
        ,@RMDTYPAL		int
		,@DISTTYPE		int
        ,@ACTNUMST		varchar(15)
        ,@DEBITAMT		money
        ,@CRDTAMNT		money
        ,@DistRef		varchar(30)
		,@ApplyTo		varchar(30) = Null
		,@Division		varchar(3) = Null
        ,@ProNumber		varchar(12) = Null
        ,@VendorId		varchar(12) = Null
        ,@DistRecords	int = 0
        ,@IntApToBal	money = 0
        ,@GPAptoBal		money = 0
		,@UserId		varchar(25)
		,@Query			varchar(max)
		
DECLARE @tblAR TABLE (
		Integration		varchar(6),
		Company			varchar(5),
		BatchId			varchar(25),
		DOCNUMBR		varchar(20),
		DOCDESCR		varchar(30),
		CUSTNMBR		varchar(15),
		DOCDATE			datetime,
		DUEDATE			datetime,
		DOCAMNT			money,
		SLSAMNT			money,
		RMDTYPAL		int,
		ACTNUMST		varchar(75),
		DISTTYPE		int,
		DEBITAMT		money,
		CRDTAMNT		money,
		DistRef			varchar(30))

SET	@Query = N'SELECT ''SHP'' AS Integration,
		''' + RTRIM(@Company) + ''' AS Company,
		''' + @BatchId + ''' AS BatchId,
		''' + @NewDocNumber + ''' AS DOCNUMBR,
		ISNULL(' + CASE WHEN @DocDescript IS Null THEN 'Null' ELSE '''' + RTRIM(@DocDescript) + '''' END + ', HDR.TRXDSCRN) AS DOCDESCR,
		HDR.CUSTNMBR,
		''' + CONVERT(Varchar, @DocumentDate, 101) + ''' AS DOCDATE,
		''' + CONVERT(Varchar, DATEADD(dd, 30, @DocumentDate), 101) + ''' AS DUEDATE,
		' + CAST(@DocAmount AS Varchar) + ' AS DOCAMNT,
		' + CAST(@DocAmount AS Varchar) + ' AS SLSAMNT,
		' + CASE WHEN @TransType = 'D' THEN '3' ELSE '7' END + ' AS RMDTYPAL,
		GLA.ACTNUMST,
		' + CASE WHEN @TransType = 'D' THEN 'CASE WHEN DET.DEBITAMT > 0 THEN 3 ELSE 18 END'
			ELSE 'CASE WHEN DET.CRDTAMNT > 0 THEN 19 ELSE 3 END'
			END + ' AS DISTTYPE,
		' + CASE WHEN @TransType = 'D' THEN 'CASE WHEN DET.DEBITAMT > 0 THEN ' + CAST(@DocAmount AS Varchar) + ' ELSE 0 END'
			ELSE 'CASE WHEN DET.CRDTAMNT > 0 THEN ' + CAST(@DocAmount AS Varchar) + ' ELSE 0 END'
			END + ' AS DEBITAMT,
		' + CASE WHEN @TransType = 'C' THEN 'CASE WHEN DET.DEBITAMT > 0 THEN ' + CAST(@DocAmount AS Varchar) + ' ELSE 0 END'
			ELSE 'CASE WHEN DET.CRDTAMNT > 0 THEN ' + CAST(@DocAmount AS Varchar) + ' ELSE 0 END'
			END + ' AS CRDTAMNT,
		ISNULL(' + CASE WHEN @DocDescript IS Null THEN 'Null' ELSE '''' + RTRIM(@DocDescript) + '''' END + ', DET.DistRef) AS DistRef
FROM	LENSASQL001.' + RTRIM(@Company) + '.dbo.RM20101 HDR
		INNER JOIN LENSASQL001.' + RTRIM(@Company) + '.dbo.RM10101 DET ON HDR.DOCNUMBR = DET.DOCNUMBR AND HDR.TRXSORCE = DET.TRXSORCE
		INNER JOIN LENSASQL001.' + RTRIM(@Company) + '.dbo.GL00105 GLA ON DET.DSTINDX = GLA.ACTINDX
WHERE	HDR.CUSTNMBR = ''' + RTRIM(@CustomerNum) + '''
		AND HDR.DOCNUMBR = ''' + RTRIM(@OriDocNumber) + ''''

PRINT @Query
INSERT INTO @tblAR
EXECUTE(@Query)

DECLARE Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT * FROM @tblAR

OPEN Transactions 
FETCH FROM Transactions INTO @Integration, @Company, @BatchId, @DOCNUMBR, @DocDescript, @CustomerNum, @DocumentDate, @DUEDATE,
							 @DOCAMNT, @SLSAMNT, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DistRef

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_Integrations_AR @Integration, @Company, @BatchId, @DOCNUMBR, @DocDescript, @CustomerNum, @DocumentDate, @DUEDATE,
								 @DOCAMNT, @SLSAMNT, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DistRef

	FETCH FROM Transactions INTO @Integration, @Company, @BatchId, @DOCNUMBR, @DocDescript, @CustomerNum, @DocumentDate, @DUEDATE,
								 @DOCAMNT, @SLSAMNT, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DistRef
END

CLOSE Transactions
DEALLOCATE Transactions

IF @@ERROR = 0
BEGIN
	EXECUTE USP_ReceivedIntegrations @Integration, @Company, @BatchId, 0
END