/*
EXECUTE USP_FSI_FindContainer 'DNJ', '36-110566'
EXECUTE USP_FSI_FindContainer 'DNJ', '36-111722'
*/
ALTER PROCEDURE [dbo].[USP_FSI_FindContainer]
	@Company	Varchar(5),
	@InvoiceNo	Varchar(20)
AS
SET NOCOUNT ON

SELECT	CAST(Null AS Varchar(20)) AS Container,
		CAST(Null AS Varchar(20)) AS ProNumber,
		CAST(Null AS Datetime) AS DeliveryDate
INTO	#tempInformation

TRUNCATE TABLE #tempInformation

INSERT INTO #tempInformation
	--SELECT	SUB.RecordCode AS Container
	--		,SUB.Reference AS ProNumber
	--		,DET.DeliveryDate
	--FROM	FSI_ReceivedDetails DET
	--		INNER JOIN FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId AND HED.Company = @Company
	--		INNER JOIN FSI_ReceivedSubDetails SUB ON DET.BatchId = SUB.BatchId AND DET.DetailId = SUB.DetailId
	--WHERE	DET.InvoiceNumber = @InvoiceNo
	--		AND SUB.RecordType = 'EQP'
	--UNION
	SELECT	SUB.RecordCode AS Container
			,SUB.Reference AS ProNumber
			,DET.DeliveryDate
	FROM	ILSINT02.Integrations.dbo.FSI_ReceivedDetails DET
			INNER JOIN ILSINT02.Integrations.dbo.FSI_ReceivedHeader HED ON DET.BatchId = HED.BatchId AND HED.Company = @Company
			INNER JOIN ILSINT02.Integrations.dbo.FSI_ReceivedSubDetails SUB ON DET.BatchId = SUB.BatchId AND DET.DetailId = SUB.DetailId
	WHERE	DET.InvoiceNumber = @InvoiceNo
			AND SUB.RecordType = 'EQP'
		
IF @@ROWCOUNT = 0
BEGIN
	DECLARE	@Query			Varchar(MAX),
			@Pro			Varchar(12),
			@Div			Varchar(2),
			@CompanyNumber	Varchar(2)

	SELECT	@CompanyNumber = CAST(CompanyNumber AS Varchar(2))
	FROM	Companies
	WHERE	CompanyId = @Company
		
	SET	@Query = 'SELECT DISTINCT Q.* FROM (SELECT A.tl_code AS Container, B.div_code || ''-'' || B.pro AS ProNumber, A.ddate AS DeliveryDate FROM trk.move A' +
		' INNER JOIN trk.order B ON A.or_no = B.no WHERE '

	SET	@Div	= LEFT(@InvoiceNo, dbo.AT('-', @InvoiceNo, 1) - 1)
	SET	@Pro	= REPLACE(@InvoiceNo, @Div + '-', '')
	SET	@Query	= @Query + 'B.pro = ''' + @Pro + ''' AND B.div_code = ''' + @Div + ''''
	SET	@Query	= @Query + ' AND A.cmpy_no = ' + @CompanyNumber
	SET	@Query	= @Query + ') Q'
	SET	@Query	= N'SELECT * FROM OPENQUERY(PostgreSQLPROD, ''' + REPLACE(@Query, '''', '''''') + ''')'
	
	INSERT INTO #tempInformation 
	EXECUTE(@Query)
END

SELECT	*
FROM	#tempInformation

DROP TABLE #tempInformation